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
