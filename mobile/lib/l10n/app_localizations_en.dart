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

  @override
  String get historyTitle => 'WORKOUT HISTORY';

  @override
  String get historyLoadMore => 'LOAD MORE';

  @override
  String get historyBucketToday => 'TODAY';

  @override
  String get historyBucketYesterday => 'YESTERDAY';

  @override
  String get historyBucketThisWeek => 'THIS WEEK';

  @override
  String get historyEmptyTitle => 'NO WORKOUTS YET';

  @override
  String get historyEmptyMessage =>
      'Your history will appear here once you complete your first workout.';

  @override
  String get historyStartWorkout => 'START WORKOUT';

  @override
  String get historyErrorTitle => 'COULD NOT LOAD HISTORY';

  @override
  String get workoutDetailTitle => 'WORKOUT';

  @override
  String workoutDetailCompleted(String date) {
    return 'COMPLETED · $date';
  }

  @override
  String get saveAsRoutineMenu => 'Save as routine';

  @override
  String get deleteWorkoutMenu => 'Delete workout';

  @override
  String get repeatWorkout => 'REPEAT WORKOUT';

  @override
  String get saveAsRoutineTitle => 'SAVE AS ROUTINE';

  @override
  String get routineNameHint => 'e.g. Upper Body Hypertrophy';

  @override
  String get savedToRoutines => 'Saved to your routines';

  @override
  String get couldNotSaveAsRoutine => 'Could not save as routine';

  @override
  String get deleteWorkoutTitle => 'DELETE WORKOUT';

  @override
  String get deleteWorkoutMessage =>
      'Delete this workout and all of its sets? This can\'t be undone.';

  @override
  String get deleteWorkoutConfirm => 'DELETE';

  @override
  String get deleteWorkoutCancel => 'KEEP';

  @override
  String get statDuration => 'DURATION';

  @override
  String get statPrs => 'PRS';

  @override
  String get noSetsLoggedDetail => 'No sets logged';

  @override
  String get noExercisesNote => 'This workout had no logged exercises.';

  @override
  String get workoutNotFoundTitle => 'WORKOUT NOT FOUND';

  @override
  String get workoutNotFoundMessage => 'This workout may have been deleted.';

  @override
  String get backToHistory => 'BACK TO HISTORY';

  @override
  String get exerciseDirectoryTitle => 'EXERCISE DIRECTORY';

  @override
  String get createCustomExerciseTooltip => 'Create Custom Exercise';

  @override
  String exerciseLoadError(String error) {
    return 'Failed to load exercises: $error';
  }

  @override
  String get exerciseEmptyFiltered =>
      'No exercises match the selected filters.';

  @override
  String get exerciseEmptyLibrary => 'No exercises found in local library.';

  @override
  String get exerciseEmptyHint =>
      'Try adjusting your search query or removing active muscle/equipment filters.';

  @override
  String get clearAllFilters => 'CLEAR ALL FILTERS';

  @override
  String get exerciseDetailTitle => 'EXERCISE DETAIL';

  @override
  String get exerciseNotFound => 'Exercise not found';

  @override
  String get backToDirectory => 'BACK TO DIRECTORY';

  @override
  String get instructionsCardTitle => 'INSTRUCTIONS & FORM NOTES';

  @override
  String get noInstructionsRecorded =>
      'No form instructions recorded for this exercise.';

  @override
  String get targetAnatomyTitle => 'TARGET ANATOMY';

  @override
  String get primaryDriverLabel => 'Primary Driver:';

  @override
  String get secondarySynergistsLabel => 'Secondary / Synergists:';

  @override
  String get performanceHistoryTitle => 'PERFORMANCE HISTORY & PRs';

  @override
  String get noLoggedSetsYet => 'No logged sets for this exercise yet.';

  @override
  String get performanceHistoryHint =>
      'Past weights, reps, estimated 1RM trends, and ghost suggestions will populate here automatically after logging sets in workout sessions.';

  @override
  String get deleteCustomExercise => 'DELETE CUSTOM EXERCISE';

  @override
  String get deleteExerciseTitle => 'Delete Exercise?';

  @override
  String get deleteExerciseMessage =>
      'This will permanently delete this custom exercise. Previously logged workout sessions and historical records will remain intact.';

  @override
  String get deleteExerciseConfirm => 'DELETE';

  @override
  String get customBadge => 'CUSTOM';

  @override
  String get createCustomExerciseTitle => 'CREATE CUSTOM EXERCISE';

  @override
  String get exerciseNameLabel => 'EXERCISE NAME *';

  @override
  String get exerciseNameHint => 'e.g. Landmine Press, Swiss Bar Bench';

  @override
  String get exerciseNameRequired => 'Please enter an exercise name';

  @override
  String get primaryMuscleDriverLabel => 'PRIMARY MUSCLE DRIVER *';

  @override
  String get secondaryMusclesLabel =>
      'SECONDARY MUSCLES / STABILIZERS (OPTIONAL)';

  @override
  String get equipmentLabel => 'EQUIPMENT *';

  @override
  String get categoryLabel => 'CATEGORY *';

  @override
  String get instructionsFormLabel => 'INSTRUCTIONS / FORM NOTES (OPTIONAL)';

  @override
  String get instructionsFormHint =>
      'Cues, setup notes, bench angle, attachments...';

  @override
  String get timeBasedLabel => 'Time-based';

  @override
  String get cardioLabel => 'Cardio';

  @override
  String get saveCustomExercise => 'SAVE CUSTOM EXERCISE';

  @override
  String get primaryMuscleRequired => 'Please select a primary muscle group.';

  @override
  String get searchExercisesHint => 'Search exercises (e.g. bench, squat)...';

  @override
  String get favouritesChip => '★ Favourites';

  @override
  String get routinesTitle => 'ROUTINES';

  @override
  String get routinesSubtitle => 'Workout splits & templates';

  @override
  String get searchRoutinesHint => 'Search routines by name or muscle...';

  @override
  String get newRoutine => 'NEW ROUTINE';

  @override
  String get editRoutine => 'EDIT ROUTINE';

  @override
  String get editRoutineMenu => 'Edit Routine';

  @override
  String get duplicateMenu => 'Duplicate';

  @override
  String get deleteMenu => 'Delete';

  @override
  String get deleteRoutineMenu => 'Delete Routine';

  @override
  String routineDuplicated(String name) {
    return 'Duplicated \"$name\"';
  }

  @override
  String get deleteRoutineTitle => 'Delete Routine?';

  @override
  String deleteRoutineMessage(String name) {
    return 'Are you sure you want to delete \"$name\"? Historical workouts logged from this routine will remain intact.';
  }

  @override
  String get routineEmptyTitle => 'NO ROUTINES YET';

  @override
  String get routineEmptyMessage =>
      'Create unlimited custom routines and workout splits to streamline your gym sessions.';

  @override
  String get createRoutine => 'CREATE ROUTINE';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String noRoutinesMatching(String query) {
    return 'No routines matching \"$query\"';
  }

  @override
  String get clearSearch => 'CLEAR SEARCH';

  @override
  String get routineDetailTitle => 'ROUTINE DETAIL';

  @override
  String get routineDetailsLabel => 'ROUTINE DETAILS';

  @override
  String get totalSetsLabel => 'TOTAL SETS';

  @override
  String get estDurationLabel => 'EST. DURATION';

  @override
  String get estTimeLabel => 'EST. TIME';

  @override
  String get plannedExercisesLabel => 'PLANNED EXERCISES';

  @override
  String get noExercisesInRoutine => 'No exercises added to this routine yet.';

  @override
  String get targetWeightColumn => 'TARGET WEIGHT';

  @override
  String get targetRepsColumn => 'TARGET REPS';

  @override
  String get targetRpeColumn => 'TARGET RPE';

  @override
  String get routineNotFoundTitle => 'Routine Not Found';

  @override
  String get routineNotFoundMessage => 'This routine may have been deleted.';

  @override
  String get backToRoutines => 'BACK TO ROUTINES';

  @override
  String get dragToReorder => 'Drag handle to reorder';

  @override
  String get noExercisesAdded => 'No exercises added yet';

  @override
  String get noExercisesAddedHint =>
      'Tap below to browse the catalog and add exercises to your routine.';

  @override
  String get routineNameLabel => 'Routine Name *';

  @override
  String get descriptionLabel => 'Description (Optional)';

  @override
  String get descriptionHint =>
      'e.g. 4-week strength block focusing on bench and OHP';

  @override
  String get routineNameEmpty => 'Routine name cannot be empty';

  @override
  String get removeExerciseTitle => 'Remove Exercise?';

  @override
  String removeExerciseMessage(String name) {
    return 'Remove \"$name\" from this routine?';
  }

  @override
  String get removeExerciseConfirm => 'REMOVE';

  @override
  String get exerciseTargetsTitle => 'Exercise Targets';

  @override
  String get plannedSetsLabel => 'PLANNED SETS';

  @override
  String get targetWeightKgLabel => 'TARGET WEIGHT (KG)';

  @override
  String get targetRepsLabel => 'TARGET REPS';

  @override
  String get restDurationLabel => 'REST DURATION';

  @override
  String get targetRpeLabel => 'TARGET RPE (OPTIONAL: 6-10)';

  @override
  String get notesCuesLabel => 'NOTES & CUES (OPTIONAL)';

  @override
  String get notesHint => 'e.g. Pause 1s at chest, focus on leg drive';

  @override
  String get rpeHint => 'e.g. 8.5';

  @override
  String get confirmTargets => 'CONFIRM TARGETS';

  @override
  String get foodDatabaseTitle => 'FOOD DATABASE';

  @override
  String get foodVegOnlyChip => 'VEG ONLY';

  @override
  String get foodSatvikChip => 'SATVIK';

  @override
  String get searchFoodsHint => 'Search foods (e.g. dal, paneer, roti)...';

  @override
  String get foodEmptyFiltered => 'No foods match your search.';

  @override
  String get foodEmptyCatalog => 'The food catalog is empty.';

  @override
  String get foodEmptyHint =>
      'Try a shorter query — \"dal\", \"paneer\", \"roti\" — or clear the veg/satvik filters.';

  @override
  String get foodClearFilters => 'CLEAR FILTERS';

  @override
  String foodLoadError(String error) {
    return 'Failed to load foods: $error';
  }

  @override
  String get foodDetailTitle => 'FOOD DETAIL';

  @override
  String get foodNotFoundTitle => 'FOOD NOT FOUND';

  @override
  String get backToFoodSearch => 'BACK TO SEARCH';

  @override
  String get servingLabel => 'SERVING';

  @override
  String get unitLabel => 'UNIT';

  @override
  String get nutritionLabel => 'NUTRITION';

  @override
  String get kcalUnit => 'kcal';

  @override
  String get proteinLabel => 'PROTEIN';

  @override
  String get carbsLabel => 'CARBS';

  @override
  String get fatLabel => 'FAT';

  @override
  String get fiberLabel => 'FIBER';

  @override
  String get addToMealLabel => 'ADD TO MEAL';

  @override
  String get foodLogging => 'LOGGING…';

  @override
  String logToMeal(String meal) {
    return 'LOG TO $meal';
  }

  @override
  String customQuantityTitle(String unit) {
    return 'Custom quantity ($unit)';
  }

  @override
  String get customQuantityHint => 'e.g. 1.5';

  @override
  String get applyAction => 'APPLY';

  @override
  String get nutritionTitle => 'NUTRITION';

  @override
  String get caloriesOverTarget => 'CALORIES OVER TARGET';

  @override
  String get caloriesRemaining => 'CALORIES REMAINING';

  @override
  String get dailyTotalsLabel => 'DAILY TOTALS';

  @override
  String get removeItemTitle => 'Remove item?';

  @override
  String removeItemMessage(String name) {
    return 'Remove \"$name\" from this meal?';
  }

  @override
  String get removeItemConfirm => 'REMOVE';

  @override
  String get mealNothingLogged => 'Nothing logged yet.';

  @override
  String get addFood => 'ADD FOOD';

  @override
  String get authWordmark => 'AVEN FIT';

  @override
  String get authLoginSubtitle => 'Train offline. Track everything.';

  @override
  String get authPhoneHint => '98765 43210';

  @override
  String get authSendOtp => 'SEND OTP';

  @override
  String get authContinueWithGoogle => 'CONTINUE WITH GOOGLE';

  @override
  String get authContinueAsGuest => 'CONTINUE AS GUEST';

  @override
  String get authOrDivider => 'OR';

  @override
  String get authDpdpNotice =>
      'By continuing you agree to our Terms of Service and Privacy Policy. Your data stays on this device until you sign in.';

  @override
  String get authVerifyOtpTitle => 'VERIFY OTP';

  @override
  String get authOtpSentTo => 'We sent a 6-digit code to';

  @override
  String get authChangeNumber => 'Change number';

  @override
  String get authVerifying => 'VERIFYING…';

  @override
  String get authInvalidCodeFallback => 'Invalid code. Try again.';

  @override
  String get authCodeExpiredFallback => 'That code expired. Send a new one.';

  @override
  String get authResendCode => 'RESEND CODE';

  @override
  String authResendCodeIn(int seconds) {
    return 'RESEND CODE IN ${seconds}s';
  }

  @override
  String get authCodeExpiredNotice => 'Code expired — resend to continue.';

  @override
  String authCodeExpiresIn(String time) {
    return 'Code expires in $time';
  }

  @override
  String get authVerifyAndContinue => 'VERIFY & CONTINUE';

  @override
  String get authOtpManualEntryNotice =>
      'No SMS permission needed — the code can also be typed in manually.';
}
