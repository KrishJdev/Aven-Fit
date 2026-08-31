package com.avenfit.aven_fit

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat

/**
 * Foreground service for active workout sessions (WU-3.10, FEATURES.md §8.1).
 *
 * Shows the single persistent notification while a session is live: the
 * elapsed session time and, when resting, the live rest countdown — both
 * re-rendered every second from epoch values (L8: pure arithmetic, no
 * accumulation drift). The Flutter/Dart side is the single source of truth:
 * it pushes epoch fields through the `com.avenfit.aven_fit/workout_service`
 * channel on every state change, and this service only renders them and
 * ticks the clock. This keeps the timer alive on the lock screen and shields
 * the process from background throttling/OEM app killers while training.
 *
 * Actions mirror app state:
 * - [+15s] appears only while resting; it extends the rendered countdown
 *   immediately (optimistic, epoch-based) and forwards to Dart so
 *   [RestTimerController] stays authoritative.
 * - [Finish Workout] forwards to Dart, which completes the session
 *   (write-through to SQLite, L7) and calls back with ACTION_STOP.
 *
 * Android 14+ compliance: declared with `foregroundServiceType="specialUse"`
 * (workout timer subtype) and FOREGROUND_SERVICE_SPECIAL_USE permission.
 */
class WorkoutForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "avenfit_workout_service"
        const val CHANNEL_NAME = "Workout Session"
        const val CHANNEL_DESCRIPTION =
            "Persistent elapsed-time and rest countdown while a workout is active"
        const val NOTIFICATION_ID = 2001

        const val ACTION_START = "com.avenfit.aven_fit.workout.START"
        const val ACTION_UPDATE = "com.avenfit.aven_fit.workout.UPDATE"
        const val ACTION_UPDATE_REST = "com.avenfit.aven_fit.workout.UPDATE_REST"
        const val ACTION_STOP = "com.avenfit.aven_fit.workout.STOP"
        const val ACTION_ADD_15 = "com.avenfit.aven_fit.workout.ADD_15"
        const val ACTION_FINISH = "com.avenfit.aven_fit.workout.FINISH"

        const val EXTRA_WORKOUT_NAME = "workoutName"
        const val EXTRA_STARTED_AT_MS = "startedAtMs"
        const val EXTRA_IS_PAUSED = "isPaused"
        const val EXTRA_PAUSED_DURATION_MS = "pausedDurationMs"
        const val EXTRA_LAST_RESUMED_AT_MS = "lastResumedAtMs"
        /** ≥ 0 sets the rest deadline epoch; -1 clears the countdown. */
        const val EXTRA_REST_ENDS_AT_MS = "restEndsAtMs"

        internal const val REST_CLEAR_SENTINEL = -1L
        private const val ADD_15_MS = 15_000L
    }

    private var workoutName: String = "Workout"
    private var startedAtMs: Long = 0L
    private var isPaused: Boolean = false
    private var pausedDurationMs: Long = 0L
    private var lastResumedAtMs: Long = 0L
    private var restEndsAtMs: Long? = null

    private val mainHandler = Handler(Looper.getMainLooper())

    /** One-second UI tick only — every value is recomputed from epoch fields. */
    private val ticker = object : Runnable {
        override fun run() {
            render()
            mainHandler.postDelayed(this, 1_000L)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                startedAtMs = intent.getLongExtra(EXTRA_STARTED_AT_MS, System.currentTimeMillis())
                isPaused = intent.getBooleanExtra(EXTRA_IS_PAUSED, false)
                pausedDurationMs = intent.getLongExtra(EXTRA_PAUSED_DURATION_MS, 0L)
                lastResumedAtMs = intent.getLongExtra(EXTRA_LAST_RESUMED_AT_MS, 0L)
                restEndsAtMs = if (intent.hasExtra(EXTRA_REST_ENDS_AT_MS)) {
                    val value = intent.getLongExtra(EXTRA_REST_ENDS_AT_MS, REST_CLEAR_SENTINEL)
                    if (value == REST_CLEAR_SENTINEL) null else value
                } else {
                    null
                }
                workoutName = intent.getStringExtra(EXTRA_WORKOUT_NAME) ?: "Workout"
                startForegroundWithType(buildNotification())
                startTicking()
            }

            ACTION_UPDATE -> {
                if (intent.hasExtra(EXTRA_WORKOUT_NAME)) {
                    workoutName = intent.getStringExtra(EXTRA_WORKOUT_NAME) ?: workoutName
                }
                if (intent.hasExtra(EXTRA_STARTED_AT_MS)) {
                    startedAtMs = intent.getLongExtra(EXTRA_STARTED_AT_MS, startedAtMs)
                }
                if (intent.hasExtra(EXTRA_IS_PAUSED)) {
                    isPaused = intent.getBooleanExtra(EXTRA_IS_PAUSED, isPaused)
                }
                if (intent.hasExtra(EXTRA_PAUSED_DURATION_MS)) {
                    pausedDurationMs = intent.getLongExtra(EXTRA_PAUSED_DURATION_MS, pausedDurationMs)
                }
                if (intent.hasExtra(EXTRA_LAST_RESUMED_AT_MS)) {
                    lastResumedAtMs = intent.getLongExtra(EXTRA_LAST_RESUMED_AT_MS, lastResumedAtMs)
                }
                render()
            }

            ACTION_UPDATE_REST -> {
                if (intent.hasExtra(EXTRA_REST_ENDS_AT_MS)) {
                    val value = intent.getLongExtra(EXTRA_REST_ENDS_AT_MS, REST_CLEAR_SENTINEL)
                    restEndsAtMs = if (value == REST_CLEAR_SENTINEL) null else value
                }
                render()
            }

            ACTION_ADD_15 -> {
                // Optimistic native extend so the button feels instant even if
                // the Dart engine is momentarily busy; the authoritative value
                // arrives back via ACTION_UPDATE_REST.
                restEndsAtMs = restEndsAtMs?.plus(ADD_15_MS)
                render()
                forwardToDart("onAdd15")
            }

            ACTION_FINISH -> forwardToDart("onFinish")

            ACTION_STOP -> stopSelf()

            else -> {
                // Restarted after process death without a START intent —
                // nothing meaningful to render; the Dart side re-pushes state
                // on restore.
                stopSelf()
                return START_NOT_STICKY
            }
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        mainHandler.removeCallbacks(ticker)
        super.onDestroy()
    }

    private fun startTicking() {
        mainHandler.removeCallbacks(ticker)
        render()
        mainHandler.postDelayed(ticker, 1_000L)
    }

    private fun render() {
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.notify(NOTIFICATION_ID, buildNotification())
    }

    private fun elapsedSeconds(): Long {
        val referenceMs = if (isPaused && lastResumedAtMs > 0) lastResumedAtMs else System.currentTimeMillis()
        val elapsed = (referenceMs - startedAtMs - pausedDurationMs) / 1_000L
        return if (elapsed < 0) 0L else elapsed
    }

    private fun remainingRestSeconds(): Long? {
        val endsAt = restEndsAtMs ?: return null
        val remaining = (endsAt - System.currentTimeMillis()) / 1_000L
        return if (remaining < 0) 0L else remaining
    }

    private fun buildNotification(): Notification {
        val elapsedText = formatClock(elapsedSeconds())
        val restText = remainingRestSeconds()?.let { " · Rest ${formatClock(it)}" } ?: ""

        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            ?: Intent(this, MainActivity::class.java)
        val contentIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val add15Pending = PendingIntent.getService(
            this,
            1,
            Intent(this, WorkoutForegroundService::class.java).setAction(ACTION_ADD_15),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val finishPending = PendingIntent.getService(
            this,
            2,
            Intent(this, WorkoutForegroundService::class.java).setAction(ACTION_FINISH),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(workoutName)
            .setContentText("Elapsed $elapsedText$restText")
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setCategory(Notification.CATEGORY_WORKOUT)
            .addAction(0, "Finish Workout", finishPending)

        if (restEndsAtMs != null) {
            builder.addAction(0, "+15s", add15Pending)
        }

        return builder.build()
    }

    private fun startForegroundWithType(notification: Notification) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    /** Best-effort native → Dart callback; a dead engine simply ignores it. */
    private fun forwardToDart(method: String) {
        try {
            MainActivity.workoutServiceChannel?.invokeMethod(method, null)
        } catch (_: Exception) {
            // The Flutter engine is gone — the notification keeps ticking from
            // epoch values and Dart re-pushes state on the next launch.
        }
    }

    private fun createChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = CHANNEL_DESCRIPTION
            setShowBadge(false)
        }
        val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        manager.createNotificationChannel(channel)
    }

    private fun formatClock(totalSeconds: Long): String {
        val hours = totalSeconds / 3_600L
        val minutes = (totalSeconds % 3_600L) / 60L
        val seconds = totalSeconds % 60L
        return if (hours > 0) {
            String.format("%d:%02d:%02d", hours, minutes, seconds)
        } else {
            String.format("%02d:%02d", minutes, seconds)
        }
    }
}
