// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navWorkouts => 'Workouts';

  @override
  String get navProgress => 'Progress';

  @override
  String get navNutrition => 'Nutrition';

  @override
  String get homeResumeBannerTitle => 'WORKOUT IN PROGRESS';

  @override
  String homeResumeBannerSubtitle(
    String name,
    String elapsed,
    int done,
    int total,
  ) {
    return '$name · $elapsed elapsed · $done/$total sets';
  }

  @override
  String get homeStartFirstWorkout => 'START FIRST WORKOUT';

  @override
  String get homeStartNewSession => 'START NEW SESSION';

  @override
  String get homeProfileTooltip => 'Profile';

  @override
  String get homeSuggestedRoutineTitle => 'SUGGESTED ROUTINE';

  @override
  String homeSuggestedRoutineMeta(int exercises, int sets, int minutes) {
    return '$exercises exercises · $sets sets · ~$minutes min';
  }

  @override
  String get glanceThisWeek => 'THIS WEEK';

  @override
  String get glanceVolume => 'VOLUME';

  @override
  String get glanceSets => 'SETS';

  @override
  String get glanceStreak => 'STREAK';

  @override
  String get glanceCaloriesLeft => 'CALORIES LEFT';

  @override
  String get glanceVolumeNew => '▲ NEW';

  @override
  String get homeRecentWorkouts => 'RECENT WORKOUTS';

  @override
  String get viewAll => 'VIEW ALL';

  @override
  String get homeHistoryEmptyTitle => 'YOUR HISTORY WILL APPEAR HERE';

  @override
  String get homeHistoryEmptyMessage => 'No account needed. Works offline.';

  @override
  String get homeHistoryEmptyMessageShort => 'Your history will appear here.';

  @override
  String homeRecentCardMeta(
    int exercises,
    int sets,
    String volume,
    String duration,
  ) {
    return '$exercises exercises · $sets sets · $volume kg · $duration';
  }

  @override
  String get dateToday => 'TODAY';

  @override
  String get dateYesterday => 'YESTERDAY';

  @override
  String dateDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String prCountChip(int count) {
    return '$count PR';
  }

  @override
  String get profileTitle => 'PROFILE';

  @override
  String get profileLoading => 'Loading…';

  @override
  String get profileGuest => 'Guest';

  @override
  String get profileLocalSubtitle => 'Local profile';

  @override
  String get profileSignedIn => 'Signed in';

  @override
  String get profileAthlete => 'Athlete';

  @override
  String get profileBannerTitle => 'LOCAL PROFILE';

  @override
  String get profileBannerMessage =>
      'Sign in to back up your data and sync across devices.';

  @override
  String get profileSignIn => 'SIGN IN';

  @override
  String get statsWorkouts => 'WORKOUTS';

  @override
  String get statsWorkingVolume => 'WORKING VOLUME (KG)';

  @override
  String get statsSets => 'SETS LOGGED';

  @override
  String get statsMemberSince => 'MEMBER SINCE';

  @override
  String get linkSettings => 'SETTINGS';

  @override
  String get settingsComingSoon => 'Settings is coming in a future update.';

  @override
  String get linkDataExport => 'DATA EXPORT';

  @override
  String get dataExportComingSoon =>
      'Data export is coming in a future update.';

  @override
  String get linkAbout => 'ABOUT';

  @override
  String get aboutMessage =>
      'Offline-first gym & nutrition tracker. Your data lives on this device — no account needed, no cloud required.';

  @override
  String get signOutTitle => 'SIGN OUT?';

  @override
  String get signOutMessage =>
      'Your workouts, routines and nutrition history stay safely on this device. You can sign in again anytime to pick up where you left off.';

  @override
  String get signOutConfirm => 'SIGN OUT';

  @override
  String get dialogCancel => 'CANCEL';

  @override
  String get dialogOk => 'OK';

  @override
  String get progressTitle => 'PROGRESS';

  @override
  String get prVaultTitle => 'PR VAULT';

  @override
  String get progressPrEmpty =>
      'No records yet — confirm a working set and the vault fills itself.';

  @override
  String get streakZeroWeeks => '0 weeks';

  @override
  String get vaultFilterAllExercises => 'ALL EXERCISES';

  @override
  String get vaultSortNewest => 'NEWEST';

  @override
  String get vaultSortBestValue => 'BEST VALUE';

  @override
  String get prVaultEmptyTitle => 'NO RECORDS YET';

  @override
  String get prVaultEmptyMessage =>
      'Confirm a working set — records are detected automatically.';

  @override
  String progressRecentCardMeta(
    String date,
    int exercises,
    int sets,
    String volume,
  ) {
    return '$date · $exercises exercises · $sets sets · $volume kg';
  }

  @override
  String get linkBodyWeight => 'BODY WEIGHT';

  @override
  String get bodyWeightPlaceholder =>
      'Trend tracking arrives in a future update.';

  @override
  String get activeWorkoutTitle => 'ACTIVE WORKOUT';

  @override
  String get resumeSessionTooltip => 'Resume session timer';

  @override
  String get pauseSessionTooltip => 'Pause session timer';

  @override
  String get startRestTooltip => 'Start rest timer';

  @override
  String get finish => 'FINISH';

  @override
  String get discardWorkout => 'Discard Workout';

  @override
  String get noActiveWorkoutTitle => 'NO ACTIVE WORKOUT';

  @override
  String get noActiveWorkoutMessage =>
      'Start a quick session or pick a routine from your library.';

  @override
  String get startEmptyWorkout => 'START EMPTY WORKOUT';

  @override
  String get couldNotLoadWorkout => 'COULD NOT LOAD WORKOUT';

  @override
  String get retry => 'RETRY';

  @override
  String get addYourFirstExercise => 'ADD YOUR FIRST EXERCISE';

  @override
  String get addYourFirstExerciseMessage =>
      'Search from 55+ built-in exercises or create your own custom exercise.';

  @override
  String get addExercise => 'ADD EXERCISE';

  @override
  String workoutResumedBanner(String elapsed) {
    return 'WORKOUT RESUMED · $elapsed ELAPSED';
  }

  @override
  String get dismiss => 'Dismiss';

  @override
  String get statSets => 'SETS';

  @override
  String get statWorkingVolume => 'WORKING VOLUME';

  @override
  String get statExercises => 'EXERCISES';

  @override
  String get statPaused => 'PAUSED';

  @override
  String get statElapsed => 'ELAPSED';

  @override
  String get lockScreenCountdownTitle => 'LOCK-SCREEN COUNTDOWN';

  @override
  String get lockScreenCountdownMessage =>
      'See your rest countdown on the lock screen — with a +15s action — while you train. You can keep the timer inside the app too.';

  @override
  String get notNow => 'NOT NOW';

  @override
  String get allow => 'ALLOW';

  @override
  String get finishSaveError =>
      'Could not save workout — your sets are safe on this device.';

  @override
  String get renameWorkoutTitle => 'RENAME WORKOUT';

  @override
  String get workoutNameHint => 'Workout name...';

  @override
  String get dialogSave => 'SAVE';

  @override
  String get dialogResume => 'RESUME';

  @override
  String get finishAndSave => 'FINISH & SAVE';

  @override
  String get finishWorkoutTitle => 'FINISH WORKOUT';

  @override
  String get finishWorkoutMessage =>
      'Are you ready to complete and save this workout session?';

  @override
  String get discardWorkoutTitle => 'DISCARD WORKOUT';

  @override
  String get discardWorkoutMessage =>
      'Are you sure you want to discard this workout? All sets logged in this session will be removed.';

  @override
  String get discard => 'DISCARD';

  @override
  String get exerciseFallbackName => 'Exercise';

  @override
  String get setColumn => 'SET';

  @override
  String get prevColumn => 'PREV';

  @override
  String get kgColumn => 'KG';

  @override
  String get repsColumn => 'REPS';

  @override
  String get noSetsLogged => 'No sets logged yet. Tap + ADD SET below.';

  @override
  String get addSet => 'ADD SET';

  @override
  String get warmupPyramidTooltip => 'Warm-up Pyramid';

  @override
  String get warmupPyramidMenu => 'Warm-up Pyramid';

  @override
  String get removeExerciseMenu => 'Remove Exercise';

  @override
  String get quickInfoMuscles => 'MUSCLES';

  @override
  String get quickInfoLastPerformance => 'LAST PERFORMANCE';

  @override
  String get quickInfoNoHistory =>
      'No history yet — this session sets the baseline.';

  @override
  String get restTimerLabel => 'REST TIMER:';

  @override
  String get restartRestTooltip => 'Restart rest';

  @override
  String get skipRestTooltip => 'Skip rest';

  @override
  String get somethingWentWrong => 'SOMETHING WENT WRONG';
}
