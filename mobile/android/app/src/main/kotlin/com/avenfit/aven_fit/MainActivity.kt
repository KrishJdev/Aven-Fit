package com.avenfit.aven_fit

import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        /**
         * Live platform channel to the Dart side, held for
         * [WorkoutForegroundService] so notification actions can reach
         * Flutter while the engine is alive (best-effort; a dead engine
         * simply ignores them). Dart is the single source of truth for all
         * timer state (L8) — the service only forwards and renders.
         */
        var workoutServiceChannel: MethodChannel? = null
    }

    private val channelName = "com.avenfit.aven_fit/workout_service"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "startSession" -> {
                    val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
                    val intent = Intent(this, WorkoutForegroundService::class.java).apply {
                        action = WorkoutForegroundService.ACTION_START
                        putExtra(WorkoutForegroundService.EXTRA_WORKOUT_NAME, args["workoutName"] as? String)
                        putExtra(WorkoutForegroundService.EXTRA_STARTED_AT_MS, (args["startedAtMs"] as? Number)?.toLong() ?: 0L)
                        putExtra(WorkoutForegroundService.EXTRA_IS_PAUSED, args["isPaused"] as? Boolean ?: false)
                        putExtra(WorkoutForegroundService.EXTRA_PAUSED_DURATION_MS, (args["pausedDurationMs"] as? Number)?.toLong() ?: 0L)
                        putExtra(WorkoutForegroundService.EXTRA_LAST_RESUMED_AT_MS, (args["lastResumedAtMs"] as? Number)?.toLong() ?: 0L)
                        (args["restEndsAtMs"] as? Number)?.let {
                            putExtra(WorkoutForegroundService.EXTRA_REST_ENDS_AT_MS, it.toLong())
                        }
                    }
                    startServiceCompat(intent)
                    result.success(null)
                }

                "updateSession" -> {
                    val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
                    val intent = Intent(this, WorkoutForegroundService::class.java).apply {
                        action = WorkoutForegroundService.ACTION_UPDATE
                        (args["workoutName"] as? String)?.let {
                            putExtra(WorkoutForegroundService.EXTRA_WORKOUT_NAME, it)
                        }
                        (args["startedAtMs"] as? Number)?.let {
                            putExtra(WorkoutForegroundService.EXTRA_STARTED_AT_MS, it.toLong())
                        }
                        (args["isPaused"] as? Boolean)?.let {
                            putExtra(WorkoutForegroundService.EXTRA_IS_PAUSED, it)
                        }
                        (args["pausedDurationMs"] as? Number)?.let {
                            putExtra(WorkoutForegroundService.EXTRA_PAUSED_DURATION_MS, it.toLong())
                        }
                        (args["lastResumedAtMs"] as? Number)?.let {
                            putExtra(WorkoutForegroundService.EXTRA_LAST_RESUMED_AT_MS, it.toLong())
                        }
                    }
                    startServiceCompat(intent)
                    result.success(null)
                }

                "updateRest" -> {
                    val args = call.arguments as? Map<*, *> ?: emptyMap<Any, Any>()
                    // Absent argument (or the explicit sentinel) clears the countdown.
                    val restEndsAtMs = (args["restEndsAtMs"] as? Number)?.toLong()
                        ?: WorkoutForegroundService.REST_CLEAR_SENTINEL
                    val intent = Intent(this, WorkoutForegroundService::class.java).apply {
                        action = WorkoutForegroundService.ACTION_UPDATE_REST
                        putExtra(WorkoutForegroundService.EXTRA_REST_ENDS_AT_MS, restEndsAtMs)
                    }
                    startServiceCompat(intent)
                    result.success(null)
                }

                "stop" -> {
                    val intent = Intent(this, WorkoutForegroundService::class.java).apply {
                        action = WorkoutForegroundService.ACTION_STOP
                    }
                    startServiceCompat(intent)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
        workoutServiceChannel = channel
    }

    private fun startServiceCompat(intent: Intent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        workoutServiceChannel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
