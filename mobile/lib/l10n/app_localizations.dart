import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get navWorkouts;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navNutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get navNutrition;

  /// No description provided for @homeResumeBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT IN PROGRESS'**
  String get homeResumeBannerTitle;

  /// No description provided for @homeResumeBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {elapsed} elapsed · {done}/{total} sets'**
  String homeResumeBannerSubtitle(
    String name,
    String elapsed,
    int done,
    int total,
  );

  /// No description provided for @homeStartFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'START FIRST WORKOUT'**
  String get homeStartFirstWorkout;

  /// No description provided for @homeStartNewSession.
  ///
  /// In en, this message translates to:
  /// **'START NEW SESSION'**
  String get homeStartNewSession;

  /// No description provided for @homeProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfileTooltip;

  /// No description provided for @homeSuggestedRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTED ROUTINE'**
  String get homeSuggestedRoutineTitle;

  /// No description provided for @homeSuggestedRoutineMeta.
  ///
  /// In en, this message translates to:
  /// **'{exercises} exercises · {sets} sets · ~{minutes} min'**
  String homeSuggestedRoutineMeta(int exercises, int sets, int minutes);

  /// No description provided for @glanceThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get glanceThisWeek;

  /// No description provided for @glanceVolume.
  ///
  /// In en, this message translates to:
  /// **'VOLUME'**
  String get glanceVolume;

  /// No description provided for @glanceSets.
  ///
  /// In en, this message translates to:
  /// **'SETS'**
  String get glanceSets;

  /// No description provided for @glanceStreak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get glanceStreak;

  /// No description provided for @glanceCaloriesLeft.
  ///
  /// In en, this message translates to:
  /// **'CALORIES LEFT'**
  String get glanceCaloriesLeft;

  /// No description provided for @glanceVolumeNew.
  ///
  /// In en, this message translates to:
  /// **'▲ NEW'**
  String get glanceVolumeNew;

  /// No description provided for @homeRecentWorkouts.
  ///
  /// In en, this message translates to:
  /// **'RECENT WORKOUTS'**
  String get homeRecentWorkouts;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get viewAll;

  /// No description provided for @homeHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'YOUR HISTORY WILL APPEAR HERE'**
  String get homeHistoryEmptyTitle;

  /// No description provided for @homeHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No account needed. Works offline.'**
  String get homeHistoryEmptyMessage;

  /// No description provided for @homeHistoryEmptyMessageShort.
  ///
  /// In en, this message translates to:
  /// **'Your history will appear here.'**
  String get homeHistoryEmptyMessageShort;

  /// No description provided for @homeRecentCardMeta.
  ///
  /// In en, this message translates to:
  /// **'{exercises} exercises · {sets} sets · {volume} kg · {duration}'**
  String homeRecentCardMeta(
    int exercises,
    int sets,
    String volume,
    String duration,
  );

  /// No description provided for @dateToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get dateYesterday;

  /// No description provided for @dateDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String dateDaysAgo(int days);

  /// No description provided for @prCountChip.
  ///
  /// In en, this message translates to:
  /// **'{count} PR'**
  String prCountChip(int count);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileTitle;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get profileLoading;

  /// No description provided for @profileGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuest;

  /// No description provided for @profileLocalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Local profile'**
  String get profileLocalSubtitle;

  /// No description provided for @profileSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get profileSignedIn;

  /// No description provided for @profileAthlete.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get profileAthlete;

  /// No description provided for @profileBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'LOCAL PROFILE'**
  String get profileBannerTitle;

  /// No description provided for @profileBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to back up your data and sync across devices.'**
  String get profileBannerMessage;

  /// No description provided for @profileSignIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get profileSignIn;

  /// No description provided for @statsWorkouts.
  ///
  /// In en, this message translates to:
  /// **'WORKOUTS'**
  String get statsWorkouts;

  /// No description provided for @statsWorkingVolume.
  ///
  /// In en, this message translates to:
  /// **'WORKING VOLUME (KG)'**
  String get statsWorkingVolume;

  /// No description provided for @statsSets.
  ///
  /// In en, this message translates to:
  /// **'SETS LOGGED'**
  String get statsSets;

  /// No description provided for @statsMemberSince.
  ///
  /// In en, this message translates to:
  /// **'MEMBER SINCE'**
  String get statsMemberSince;

  /// No description provided for @linkSettings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get linkSettings;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Settings is coming in a future update.'**
  String get settingsComingSoon;

  /// No description provided for @linkDataExport.
  ///
  /// In en, this message translates to:
  /// **'DATA EXPORT'**
  String get linkDataExport;

  /// No description provided for @dataExportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Data export is coming in a future update.'**
  String get dataExportComingSoon;

  /// No description provided for @linkAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get linkAbout;

  /// No description provided for @aboutMessage.
  ///
  /// In en, this message translates to:
  /// **'Offline-first gym & nutrition tracker. Your data lives on this device — no account needed, no cloud required.'**
  String get aboutMessage;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'SIGN OUT?'**
  String get signOutTitle;

  /// No description provided for @signOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Your workouts, routines and nutrition history stay safely on this device. You can sign in again anytime to pick up where you left off.'**
  String get signOutMessage;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'SIGN OUT'**
  String get signOutConfirm;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get dialogCancel;

  /// No description provided for @dialogOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogOk;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get progressTitle;

  /// No description provided for @prVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'PR VAULT'**
  String get prVaultTitle;

  /// No description provided for @progressPrEmpty.
  ///
  /// In en, this message translates to:
  /// **'No records yet — confirm a working set and the vault fills itself.'**
  String get progressPrEmpty;

  /// No description provided for @streakZeroWeeks.
  ///
  /// In en, this message translates to:
  /// **'0 weeks'**
  String get streakZeroWeeks;

  /// No description provided for @vaultFilterAllExercises.
  ///
  /// In en, this message translates to:
  /// **'ALL EXERCISES'**
  String get vaultFilterAllExercises;

  /// No description provided for @vaultSortNewest.
  ///
  /// In en, this message translates to:
  /// **'NEWEST'**
  String get vaultSortNewest;

  /// No description provided for @vaultSortBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get vaultSortBestValue;

  /// No description provided for @prVaultEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'NO RECORDS YET'**
  String get prVaultEmptyTitle;

  /// No description provided for @prVaultEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm a working set — records are detected automatically.'**
  String get prVaultEmptyMessage;

  /// No description provided for @progressRecentCardMeta.
  ///
  /// In en, this message translates to:
  /// **'{date} · {exercises} exercises · {sets} sets · {volume} kg'**
  String progressRecentCardMeta(
    String date,
    int exercises,
    int sets,
    String volume,
  );

  /// No description provided for @linkBodyWeight.
  ///
  /// In en, this message translates to:
  /// **'BODY WEIGHT'**
  String get linkBodyWeight;

  /// No description provided for @bodyWeightPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Trend tracking arrives in a future update.'**
  String get bodyWeightPlaceholder;

  /// No description provided for @activeWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE WORKOUT'**
  String get activeWorkoutTitle;

  /// No description provided for @resumeSessionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Resume session timer'**
  String get resumeSessionTooltip;

  /// No description provided for @pauseSessionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Pause session timer'**
  String get pauseSessionTooltip;

  /// No description provided for @startRestTooltip.
  ///
  /// In en, this message translates to:
  /// **'Start rest timer'**
  String get startRestTooltip;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'FINISH'**
  String get finish;

  /// No description provided for @discardWorkout.
  ///
  /// In en, this message translates to:
  /// **'Discard Workout'**
  String get discardWorkout;

  /// No description provided for @noActiveWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'NO ACTIVE WORKOUT'**
  String get noActiveWorkoutTitle;

  /// No description provided for @noActiveWorkoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Start a quick session or pick a routine from your library.'**
  String get noActiveWorkoutMessage;

  /// No description provided for @startEmptyWorkout.
  ///
  /// In en, this message translates to:
  /// **'START EMPTY WORKOUT'**
  String get startEmptyWorkout;

  /// No description provided for @couldNotLoadWorkout.
  ///
  /// In en, this message translates to:
  /// **'COULD NOT LOAD WORKOUT'**
  String get couldNotLoadWorkout;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No description provided for @addYourFirstExercise.
  ///
  /// In en, this message translates to:
  /// **'ADD YOUR FIRST EXERCISE'**
  String get addYourFirstExercise;

  /// No description provided for @addYourFirstExerciseMessage.
  ///
  /// In en, this message translates to:
  /// **'Search from 55+ built-in exercises or create your own custom exercise.'**
  String get addYourFirstExerciseMessage;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'ADD EXERCISE'**
  String get addExercise;

  /// No description provided for @workoutResumedBanner.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT RESUMED · {elapsed} ELAPSED'**
  String workoutResumedBanner(String elapsed);

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @statSets.
  ///
  /// In en, this message translates to:
  /// **'SETS'**
  String get statSets;

  /// No description provided for @statWorkingVolume.
  ///
  /// In en, this message translates to:
  /// **'WORKING VOLUME'**
  String get statWorkingVolume;

  /// No description provided for @statExercises.
  ///
  /// In en, this message translates to:
  /// **'EXERCISES'**
  String get statExercises;

  /// No description provided for @statPaused.
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get statPaused;

  /// No description provided for @statElapsed.
  ///
  /// In en, this message translates to:
  /// **'ELAPSED'**
  String get statElapsed;

  /// No description provided for @lockScreenCountdownTitle.
  ///
  /// In en, this message translates to:
  /// **'LOCK-SCREEN COUNTDOWN'**
  String get lockScreenCountdownTitle;

  /// No description provided for @lockScreenCountdownMessage.
  ///
  /// In en, this message translates to:
  /// **'See your rest countdown on the lock screen — with a +15s action — while you train. You can keep the timer inside the app too.'**
  String get lockScreenCountdownMessage;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'NOT NOW'**
  String get notNow;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'ALLOW'**
  String get allow;

  /// No description provided for @finishSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save workout — your sets are safe on this device.'**
  String get finishSaveError;

  /// No description provided for @renameWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'RENAME WORKOUT'**
  String get renameWorkoutTitle;

  /// No description provided for @workoutNameHint.
  ///
  /// In en, this message translates to:
  /// **'Workout name...'**
  String get workoutNameHint;

  /// No description provided for @dialogSave.
  ///
  /// In en, this message translates to:
  /// **'SAVE'**
  String get dialogSave;

  /// No description provided for @dialogResume.
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get dialogResume;

  /// No description provided for @finishAndSave.
  ///
  /// In en, this message translates to:
  /// **'FINISH & SAVE'**
  String get finishAndSave;

  /// No description provided for @finishWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'FINISH WORKOUT'**
  String get finishWorkoutTitle;

  /// No description provided for @finishWorkoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you ready to complete and save this workout session?'**
  String get finishWorkoutMessage;

  /// No description provided for @discardWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'DISCARD WORKOUT'**
  String get discardWorkoutTitle;

  /// No description provided for @discardWorkoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard this workout? All sets logged in this session will be removed.'**
  String get discardWorkoutMessage;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'DISCARD'**
  String get discard;

  /// No description provided for @exerciseFallbackName.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseFallbackName;

  /// No description provided for @setColumn.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get setColumn;

  /// No description provided for @prevColumn.
  ///
  /// In en, this message translates to:
  /// **'PREV'**
  String get prevColumn;

  /// No description provided for @kgColumn.
  ///
  /// In en, this message translates to:
  /// **'KG'**
  String get kgColumn;

  /// No description provided for @repsColumn.
  ///
  /// In en, this message translates to:
  /// **'REPS'**
  String get repsColumn;

  /// No description provided for @noSetsLogged.
  ///
  /// In en, this message translates to:
  /// **'No sets logged yet. Tap + ADD SET below.'**
  String get noSetsLogged;

  /// No description provided for @addSet.
  ///
  /// In en, this message translates to:
  /// **'ADD SET'**
  String get addSet;

  /// No description provided for @warmupPyramidTooltip.
  ///
  /// In en, this message translates to:
  /// **'Warm-up Pyramid'**
  String get warmupPyramidTooltip;

  /// No description provided for @warmupPyramidMenu.
  ///
  /// In en, this message translates to:
  /// **'Warm-up Pyramid'**
  String get warmupPyramidMenu;

  /// No description provided for @removeExerciseMenu.
  ///
  /// In en, this message translates to:
  /// **'Remove Exercise'**
  String get removeExerciseMenu;

  /// No description provided for @quickInfoMuscles.
  ///
  /// In en, this message translates to:
  /// **'MUSCLES'**
  String get quickInfoMuscles;

  /// No description provided for @quickInfoLastPerformance.
  ///
  /// In en, this message translates to:
  /// **'LAST PERFORMANCE'**
  String get quickInfoLastPerformance;

  /// No description provided for @quickInfoNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No history yet — this session sets the baseline.'**
  String get quickInfoNoHistory;

  /// No description provided for @restTimerLabel.
  ///
  /// In en, this message translates to:
  /// **'REST TIMER:'**
  String get restTimerLabel;

  /// No description provided for @restartRestTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restart rest'**
  String get restartRestTooltip;

  /// No description provided for @skipRestTooltip.
  ///
  /// In en, this message translates to:
  /// **'Skip rest'**
  String get skipRestTooltip;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'SOMETHING WENT WRONG'**
  String get somethingWentWrong;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT HISTORY'**
  String get historyTitle;

  /// No description provided for @historyLoadMore.
  ///
  /// In en, this message translates to:
  /// **'LOAD MORE'**
  String get historyLoadMore;

  /// No description provided for @historyBucketToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get historyBucketToday;

  /// No description provided for @historyBucketYesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get historyBucketYesterday;

  /// No description provided for @historyBucketThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get historyBucketThisWeek;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'NO WORKOUTS YET'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your history will appear here once you complete your first workout.'**
  String get historyEmptyMessage;

  /// No description provided for @historyStartWorkout.
  ///
  /// In en, this message translates to:
  /// **'START WORKOUT'**
  String get historyStartWorkout;

  /// No description provided for @historyErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'COULD NOT LOAD HISTORY'**
  String get historyErrorTitle;

  /// No description provided for @workoutDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT'**
  String get workoutDetailTitle;

  /// No description provided for @workoutDetailCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED · {date}'**
  String workoutDetailCompleted(String date);

  /// No description provided for @saveAsRoutineMenu.
  ///
  /// In en, this message translates to:
  /// **'Save as routine'**
  String get saveAsRoutineMenu;

  /// No description provided for @deleteWorkoutMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete workout'**
  String get deleteWorkoutMenu;

  /// No description provided for @repeatWorkout.
  ///
  /// In en, this message translates to:
  /// **'REPEAT WORKOUT'**
  String get repeatWorkout;

  /// No description provided for @saveAsRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'SAVE AS ROUTINE'**
  String get saveAsRoutineTitle;

  /// No description provided for @routineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Upper Body Hypertrophy'**
  String get routineNameHint;

  /// No description provided for @savedToRoutines.
  ///
  /// In en, this message translates to:
  /// **'Saved to your routines'**
  String get savedToRoutines;

  /// No description provided for @couldNotSaveAsRoutine.
  ///
  /// In en, this message translates to:
  /// **'Could not save as routine'**
  String get couldNotSaveAsRoutine;

  /// No description provided for @deleteWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'DELETE WORKOUT'**
  String get deleteWorkoutTitle;

  /// No description provided for @deleteWorkoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this workout and all of its sets? This can\'t be undone.'**
  String get deleteWorkoutMessage;

  /// No description provided for @deleteWorkoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteWorkoutConfirm;

  /// No description provided for @deleteWorkoutCancel.
  ///
  /// In en, this message translates to:
  /// **'KEEP'**
  String get deleteWorkoutCancel;

  /// No description provided for @statDuration.
  ///
  /// In en, this message translates to:
  /// **'DURATION'**
  String get statDuration;

  /// No description provided for @statPrs.
  ///
  /// In en, this message translates to:
  /// **'PRS'**
  String get statPrs;

  /// No description provided for @noSetsLoggedDetail.
  ///
  /// In en, this message translates to:
  /// **'No sets logged'**
  String get noSetsLoggedDetail;

  /// No description provided for @noExercisesNote.
  ///
  /// In en, this message translates to:
  /// **'This workout had no logged exercises.'**
  String get noExercisesNote;

  /// No description provided for @workoutNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT NOT FOUND'**
  String get workoutNotFoundTitle;

  /// No description provided for @workoutNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This workout may have been deleted.'**
  String get workoutNotFoundMessage;

  /// No description provided for @backToHistory.
  ///
  /// In en, this message translates to:
  /// **'BACK TO HISTORY'**
  String get backToHistory;

  /// No description provided for @exerciseDirectoryTitle.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE DIRECTORY'**
  String get exerciseDirectoryTitle;

  /// No description provided for @createCustomExerciseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create Custom Exercise'**
  String get createCustomExerciseTooltip;

  /// No description provided for @exerciseLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load exercises: {error}'**
  String exerciseLoadError(String error);

  /// No description provided for @exerciseEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No exercises match the selected filters.'**
  String get exerciseEmptyFiltered;

  /// No description provided for @exerciseEmptyLibrary.
  ///
  /// In en, this message translates to:
  /// **'No exercises found in local library.'**
  String get exerciseEmptyLibrary;

  /// No description provided for @exerciseEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search query or removing active muscle/equipment filters.'**
  String get exerciseEmptyHint;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL FILTERS'**
  String get clearAllFilters;

  /// No description provided for @exerciseDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE DETAIL'**
  String get exerciseDetailTitle;

  /// No description provided for @exerciseNotFound.
  ///
  /// In en, this message translates to:
  /// **'Exercise not found'**
  String get exerciseNotFound;

  /// No description provided for @backToDirectory.
  ///
  /// In en, this message translates to:
  /// **'BACK TO DIRECTORY'**
  String get backToDirectory;

  /// No description provided for @instructionsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'INSTRUCTIONS & FORM NOTES'**
  String get instructionsCardTitle;

  /// No description provided for @noInstructionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No form instructions recorded for this exercise.'**
  String get noInstructionsRecorded;

  /// No description provided for @targetAnatomyTitle.
  ///
  /// In en, this message translates to:
  /// **'TARGET ANATOMY'**
  String get targetAnatomyTitle;

  /// No description provided for @primaryDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary Driver:'**
  String get primaryDriverLabel;

  /// No description provided for @secondarySynergistsLabel.
  ///
  /// In en, this message translates to:
  /// **'Secondary / Synergists:'**
  String get secondarySynergistsLabel;

  /// No description provided for @performanceHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE HISTORY & PRs'**
  String get performanceHistoryTitle;

  /// No description provided for @noLoggedSetsYet.
  ///
  /// In en, this message translates to:
  /// **'No logged sets for this exercise yet.'**
  String get noLoggedSetsYet;

  /// No description provided for @performanceHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Past weights, reps, estimated 1RM trends, and ghost suggestions will populate here automatically after logging sets in workout sessions.'**
  String get performanceHistoryHint;

  /// No description provided for @deleteCustomExercise.
  ///
  /// In en, this message translates to:
  /// **'DELETE CUSTOM EXERCISE'**
  String get deleteCustomExercise;

  /// No description provided for @deleteExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise?'**
  String get deleteExerciseTitle;

  /// No description provided for @deleteExerciseMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this custom exercise. Previously logged workout sessions and historical records will remain intact.'**
  String get deleteExerciseMessage;

  /// No description provided for @deleteExerciseConfirm.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteExerciseConfirm;

  /// No description provided for @customBadge.
  ///
  /// In en, this message translates to:
  /// **'CUSTOM'**
  String get customBadge;

  /// No description provided for @createCustomExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'CREATE CUSTOM EXERCISE'**
  String get createCustomExerciseTitle;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE NAME *'**
  String get exerciseNameLabel;

  /// No description provided for @exerciseNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Landmine Press, Swiss Bar Bench'**
  String get exerciseNameHint;

  /// No description provided for @exerciseNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an exercise name'**
  String get exerciseNameRequired;

  /// No description provided for @primaryMuscleDriverLabel.
  ///
  /// In en, this message translates to:
  /// **'PRIMARY MUSCLE DRIVER *'**
  String get primaryMuscleDriverLabel;

  /// No description provided for @secondaryMusclesLabel.
  ///
  /// In en, this message translates to:
  /// **'SECONDARY MUSCLES / STABILIZERS (OPTIONAL)'**
  String get secondaryMusclesLabel;

  /// No description provided for @equipmentLabel.
  ///
  /// In en, this message translates to:
  /// **'EQUIPMENT *'**
  String get equipmentLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY *'**
  String get categoryLabel;

  /// No description provided for @instructionsFormLabel.
  ///
  /// In en, this message translates to:
  /// **'INSTRUCTIONS / FORM NOTES (OPTIONAL)'**
  String get instructionsFormLabel;

  /// No description provided for @instructionsFormHint.
  ///
  /// In en, this message translates to:
  /// **'Cues, setup notes, bench angle, attachments...'**
  String get instructionsFormHint;

  /// No description provided for @timeBasedLabel.
  ///
  /// In en, this message translates to:
  /// **'Time-based'**
  String get timeBasedLabel;

  /// No description provided for @cardioLabel.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardioLabel;

  /// No description provided for @saveCustomExercise.
  ///
  /// In en, this message translates to:
  /// **'SAVE CUSTOM EXERCISE'**
  String get saveCustomExercise;

  /// No description provided for @primaryMuscleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a primary muscle group.'**
  String get primaryMuscleRequired;

  /// No description provided for @searchExercisesHint.
  ///
  /// In en, this message translates to:
  /// **'Search exercises (e.g. bench, squat)...'**
  String get searchExercisesHint;

  /// No description provided for @favouritesChip.
  ///
  /// In en, this message translates to:
  /// **'★ Favourites'**
  String get favouritesChip;

  /// No description provided for @routinesTitle.
  ///
  /// In en, this message translates to:
  /// **'ROUTINES'**
  String get routinesTitle;

  /// No description provided for @routinesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Workout splits & templates'**
  String get routinesSubtitle;

  /// No description provided for @searchRoutinesHint.
  ///
  /// In en, this message translates to:
  /// **'Search routines by name or muscle...'**
  String get searchRoutinesHint;

  /// No description provided for @newRoutine.
  ///
  /// In en, this message translates to:
  /// **'NEW ROUTINE'**
  String get newRoutine;

  /// No description provided for @editRoutine.
  ///
  /// In en, this message translates to:
  /// **'EDIT ROUTINE'**
  String get editRoutine;

  /// No description provided for @editRoutineMenu.
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get editRoutineMenu;

  /// No description provided for @duplicateMenu.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicateMenu;

  /// No description provided for @deleteMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteMenu;

  /// No description provided for @deleteRoutineMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete Routine'**
  String get deleteRoutineMenu;

  /// No description provided for @routineDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Duplicated \"{name}\"'**
  String routineDuplicated(String name);

  /// No description provided for @deleteRoutineTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Routine?'**
  String get deleteRoutineTitle;

  /// No description provided for @deleteRoutineMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? Historical workouts logged from this routine will remain intact.'**
  String deleteRoutineMessage(String name);

  /// No description provided for @routineEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'NO ROUTINES YET'**
  String get routineEmptyTitle;

  /// No description provided for @routineEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create unlimited custom routines and workout splits to streamline your gym sessions.'**
  String get routineEmptyMessage;

  /// No description provided for @createRoutine.
  ///
  /// In en, this message translates to:
  /// **'CREATE ROUTINE'**
  String get createRoutine;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @noRoutinesMatching.
  ///
  /// In en, this message translates to:
  /// **'No routines matching \"{query}\"'**
  String noRoutinesMatching(String query);

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'CLEAR SEARCH'**
  String get clearSearch;

  /// No description provided for @routineDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'ROUTINE DETAIL'**
  String get routineDetailTitle;

  /// No description provided for @routineDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'ROUTINE DETAILS'**
  String get routineDetailsLabel;

  /// No description provided for @totalSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL SETS'**
  String get totalSetsLabel;

  /// No description provided for @estDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'EST. DURATION'**
  String get estDurationLabel;

  /// No description provided for @estTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'EST. TIME'**
  String get estTimeLabel;

  /// No description provided for @plannedExercisesLabel.
  ///
  /// In en, this message translates to:
  /// **'PLANNED EXERCISES'**
  String get plannedExercisesLabel;

  /// No description provided for @noExercisesInRoutine.
  ///
  /// In en, this message translates to:
  /// **'No exercises added to this routine yet.'**
  String get noExercisesInRoutine;

  /// No description provided for @targetWeightColumn.
  ///
  /// In en, this message translates to:
  /// **'TARGET WEIGHT'**
  String get targetWeightColumn;

  /// No description provided for @targetRepsColumn.
  ///
  /// In en, this message translates to:
  /// **'TARGET REPS'**
  String get targetRepsColumn;

  /// No description provided for @targetRpeColumn.
  ///
  /// In en, this message translates to:
  /// **'TARGET RPE'**
  String get targetRpeColumn;

  /// No description provided for @routineNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Routine Not Found'**
  String get routineNotFoundTitle;

  /// No description provided for @routineNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This routine may have been deleted.'**
  String get routineNotFoundMessage;

  /// No description provided for @backToRoutines.
  ///
  /// In en, this message translates to:
  /// **'BACK TO ROUTINES'**
  String get backToRoutines;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag handle to reorder'**
  String get dragToReorder;

  /// No description provided for @noExercisesAdded.
  ///
  /// In en, this message translates to:
  /// **'No exercises added yet'**
  String get noExercisesAdded;

  /// No description provided for @noExercisesAddedHint.
  ///
  /// In en, this message translates to:
  /// **'Tap below to browse the catalog and add exercises to your routine.'**
  String get noExercisesAddedHint;

  /// No description provided for @routineNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Routine Name *'**
  String get routineNameLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 4-week strength block focusing on bench and OHP'**
  String get descriptionHint;

  /// No description provided for @routineNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Routine name cannot be empty'**
  String get routineNameEmpty;

  /// No description provided for @removeExerciseTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Exercise?'**
  String get removeExerciseTitle;

  /// No description provided for @removeExerciseMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from this routine?'**
  String removeExerciseMessage(String name);

  /// No description provided for @removeExerciseConfirm.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get removeExerciseConfirm;

  /// No description provided for @exerciseTargetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Targets'**
  String get exerciseTargetsTitle;

  /// No description provided for @plannedSetsLabel.
  ///
  /// In en, this message translates to:
  /// **'PLANNED SETS'**
  String get plannedSetsLabel;

  /// No description provided for @targetWeightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'TARGET WEIGHT (KG)'**
  String get targetWeightKgLabel;

  /// No description provided for @targetRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'TARGET REPS'**
  String get targetRepsLabel;

  /// No description provided for @restDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'REST DURATION'**
  String get restDurationLabel;

  /// No description provided for @targetRpeLabel.
  ///
  /// In en, this message translates to:
  /// **'TARGET RPE (OPTIONAL: 6-10)'**
  String get targetRpeLabel;

  /// No description provided for @notesCuesLabel.
  ///
  /// In en, this message translates to:
  /// **'NOTES & CUES (OPTIONAL)'**
  String get notesCuesLabel;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pause 1s at chest, focus on leg drive'**
  String get notesHint;

  /// No description provided for @rpeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 8.5'**
  String get rpeHint;

  /// No description provided for @confirmTargets.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM TARGETS'**
  String get confirmTargets;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
