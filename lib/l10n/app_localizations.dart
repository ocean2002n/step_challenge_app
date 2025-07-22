import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';
import 'app_localizations_zh.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Step Challenge'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning!'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon!'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening!'**
  String get goodEvening;

  /// No description provided for @stayActive.
  ///
  /// In en, this message translates to:
  /// **'Stay active today!'**
  String get stayActive;

  /// No description provided for @todaySteps.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Steps'**
  String get todaySteps;

  /// No description provided for @weeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Progress'**
  String get weeklyProgress;

  /// No description provided for @goalProgress.
  ///
  /// In en, this message translates to:
  /// **'Goal Progress'**
  String get goalProgress;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// No description provided for @setGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Goal'**
  String get setGoal;

  /// No description provided for @challengeActivities.
  ///
  /// In en, this message translates to:
  /// **'Challenge Activities'**
  String get challengeActivities;

  /// No description provided for @personalSettings.
  ///
  /// In en, this message translates to:
  /// **'Personal Settings'**
  String get personalSettings;

  /// No description provided for @personalProfile.
  ///
  /// In en, this message translates to:
  /// **'Personal Profile'**
  String get personalProfile;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @healthDataPermission.
  ///
  /// In en, this message translates to:
  /// **'Health Data Permission'**
  String get healthDataPermission;

  /// No description provided for @dataSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Data sync complete!'**
  String get dataSyncComplete;

  /// No description provided for @setDailyStepGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Daily Step Goal'**
  String get setDailyStepGoal;

  /// No description provided for @goalSteps.
  ///
  /// In en, this message translates to:
  /// **'Goal Steps'**
  String get goalSteps;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get steps;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @createChallengeInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Create challenge feature in development...'**
  String get createChallengeInDevelopment;

  /// No description provided for @healthDataAuthorized.
  ///
  /// In en, this message translates to:
  /// **'Health data permission authorized'**
  String get healthDataAuthorized;

  /// No description provided for @pleaseEnableHealthData.
  ///
  /// In en, this message translates to:
  /// **'Please enable health data permission in settings'**
  String get pleaseEnableHealthData;

  /// No description provided for @initializingApp.
  ///
  /// In en, this message translates to:
  /// **'Initializing app...'**
  String get initializingApp;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @pleaseEnterNickname.
  ///
  /// In en, this message translates to:
  /// **'Please enter nickname'**
  String get pleaseEnterNickname;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @pleaseSelectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Please select birth date'**
  String get pleaseSelectBirthDate;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @enterValidHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid height (1-300cm)'**
  String get enterValidHeight;

  /// No description provided for @enterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid weight (1-500kg)'**
  String get enterValidWeight;

  /// No description provided for @savePersonalProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Personal Profile'**
  String get savePersonalProfile;

  /// No description provided for @personalProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Personal profile saved'**
  String get personalProfileSaved;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFailed;

  /// No description provided for @imageSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Image selection error'**
  String get imageSelectionError;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @traditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get traditionalChinese;

  /// No description provided for @khmer.
  ///
  /// In en, this message translates to:
  /// **'Khmer'**
  String get khmer;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @restartRequired.
  ///
  /// In en, this message translates to:
  /// **'Restart required to apply language changes'**
  String get restartRequired;

  /// No description provided for @weekendWalkingChallenge.
  ///
  /// In en, this message translates to:
  /// **'Weekend Walking Challenge'**
  String get weekendWalkingChallenge;

  /// No description provided for @weekendWalkingDescription.
  ///
  /// In en, this message translates to:
  /// **'Let\'s walk together this weekend, aiming for 8000 steps daily!'**
  String get weekendWalkingDescription;

  /// No description provided for @tenThousandStepChallenge.
  ///
  /// In en, this message translates to:
  /// **'10K Steps Master Challenge'**
  String get tenThousandStepChallenge;

  /// No description provided for @tenThousandStepDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach 10,000 steps every day for a whole month. Do you dare to challenge?'**
  String get tenThousandStepDescription;

  /// No description provided for @oneMillionStepChallenge.
  ///
  /// In en, this message translates to:
  /// **'1 Million Steps Team Challenge'**
  String get oneMillionStepChallenge;

  /// No description provided for @oneMillionStepDescription.
  ///
  /// In en, this message translates to:
  /// **'Work together as a team to reach the goal of 1 million steps!'**
  String get oneMillionStepDescription;

  /// No description provided for @noActiveChallenges.
  ///
  /// In en, this message translates to:
  /// **'No active challenges currently'**
  String get noActiveChallenges;

  /// No description provided for @createNewChallengePrompt.
  ///
  /// In en, this message translates to:
  /// **'Create a new challenge and invite friends to exercise together!'**
  String get createNewChallengePrompt;

  /// No description provided for @remainingTime.
  ///
  /// In en, this message translates to:
  /// **'Remaining time'**
  String get remainingTime;

  /// No description provided for @ended.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get ended;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @challengeProgress.
  ///
  /// In en, this message translates to:
  /// **'Challenge Progress'**
  String get challengeProgress;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'participants'**
  String get participants;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @endingSoon.
  ///
  /// In en, this message translates to:
  /// **'Ending soon'**
  String get endingSoon;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// No description provided for @totalGoal.
  ///
  /// In en, this message translates to:
  /// **'Total goal'**
  String get totalGoal;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @stepsUnit.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get stepsUnit;

  /// No description provided for @achieved.
  ///
  /// In en, this message translates to:
  /// **'Achieved'**
  String get achieved;

  /// No description provided for @goalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Goal achieved!'**
  String get goalAchieved;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @exceededGoal.
  ///
  /// In en, this message translates to:
  /// **'Exceeded goal'**
  String get exceededGoal;

  /// No description provided for @remainingSteps.
  ///
  /// In en, this message translates to:
  /// **'Remaining steps'**
  String get remainingSteps;

  /// No description provided for @goalAchievedCongrats.
  ///
  /// In en, this message translates to:
  /// **'Excellent! You\'ve achieved today\'s goal. Keep up the healthy lifestyle!'**
  String get goalAchievedCongrats;

  /// No description provided for @nearGoalMessage.
  ///
  /// In en, this message translates to:
  /// **'Almost there! Just a little more walking and you\'ll succeed. Keep it up!'**
  String get nearGoalMessage;

  /// No description provided for @halfwayMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re halfway there! Keep pushing, the goal is within reach!'**
  String get halfwayMessage;

  /// No description provided for @goodStartMessage.
  ///
  /// In en, this message translates to:
  /// **'Great start! Every step brings you closer to your health goal.'**
  String get goodStartMessage;

  /// No description provided for @newDayMessage.
  ///
  /// In en, this message translates to:
  /// **'A new day begins! Take the first step towards your goal!'**
  String get newDayMessage;

  /// No description provided for @thisWeekWalkingRecord.
  ///
  /// In en, this message translates to:
  /// **'This Week\'s Walking Record'**
  String get thisWeekWalkingRecord;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @weeklyTotal.
  ///
  /// In en, this message translates to:
  /// **'Weekly total'**
  String get weeklyTotal;

  /// No description provided for @dailyAverageSteps.
  ///
  /// In en, this message translates to:
  /// **'Daily average steps'**
  String get dailyAverageSteps;

  /// No description provided for @daysGoalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Days goal achieved'**
  String get daysGoalAchieved;

  /// No description provided for @stepGoalReminder.
  ///
  /// In en, this message translates to:
  /// **'Step Goal Reminder'**
  String get stepGoalReminder;

  /// No description provided for @stepGoalReminderBody.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t reached your step goal today. Let\'s get walking!'**
  String get stepGoalReminderBody;

  /// No description provided for @challengeInvitation.
  ///
  /// In en, this message translates to:
  /// **'Challenge Invitation'**
  String get challengeInvitation;

  /// No description provided for @challengeProgressUpdate.
  ///
  /// In en, this message translates to:
  /// **'Challenge Progress Update'**
  String get challengeProgressUpdate;

  /// No description provided for @clickedChallenge.
  ///
  /// In en, this message translates to:
  /// **'Selected challenge: {challengeTitle}'**
  String clickedChallenge(Object challengeTitle);

  /// No description provided for @joinedChallenge.
  ///
  /// In en, this message translates to:
  /// **'Joined challenge: {challengeTitle}'**
  String joinedChallenge(Object challengeTitle);

  /// No description provided for @shareChallenge.
  ///
  /// In en, this message translates to:
  /// **'Share challenge: {challengeTitle}'**
  String shareChallenge(Object challengeTitle);

  /// No description provided for @goalWith.
  ///
  /// In en, this message translates to:
  /// **'Goal: {goal} steps'**
  String goalWith(Object goal);

  /// No description provided for @remainingStepsToGoal.
  ///
  /// In en, this message translates to:
  /// **'Need {remaining} more steps to reach goal'**
  String remainingStepsToGoal(Object remaining);

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @addFriends.
  ///
  /// In en, this message translates to:
  /// **'Add Friends'**
  String get addFriends;

  /// No description provided for @myQrCode.
  ///
  /// In en, this message translates to:
  /// **'My QR Code'**
  String get myQrCode;

  /// No description provided for @shareInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Share Invite Link'**
  String get shareInviteLink;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @friendsList.
  ///
  /// In en, this message translates to:
  /// **'Friends List'**
  String get friendsList;

  /// No description provided for @monthlySteps.
  ///
  /// In en, this message translates to:
  /// **'Monthly Steps'**
  String get monthlySteps;

  /// No description provided for @friendsStepsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Friends\' Steps This Month'**
  String get friendsStepsThisMonth;

  /// No description provided for @noFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriendsYet;

  /// No description provided for @addFriendsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Add friends to see their step progress and compete together!'**
  String get addFriendsPrompt;

  /// No description provided for @scanToAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code or share the link to add me as a friend'**
  String get scanToAddFriend;

  /// No description provided for @friendInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Join me on Step Challenge!'**
  String get friendInviteTitle;

  /// No description provided for @friendInviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m using Step Challenge to track my daily steps. Join me and let\'s motivate each other to stay active!'**
  String get friendInviteMessage;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriend;

  /// No description provided for @friendAdded.
  ///
  /// In en, this message translates to:
  /// **'Friend added successfully!'**
  String get friendAdded;

  /// No description provided for @friendRemoved.
  ///
  /// In en, this message translates to:
  /// **'Friend removed'**
  String get friendRemoved;

  /// No description provided for @friendAddError.
  ///
  /// In en, this message translates to:
  /// **'Error adding friend'**
  String get friendAddError;

  /// No description provided for @invalidQrCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get invalidQrCode;

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get shareLink;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopied;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @stepsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps this month'**
  String stepsThisMonth(Object steps);

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank}'**
  String rank(Object rank);

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @friendsRanking.
  ///
  /// In en, this message translates to:
  /// **'Friends Ranking'**
  String get friendsRanking;

  /// No description provided for @appleHealth.
  ///
  /// In en, this message translates to:
  /// **'Apple Health'**
  String get appleHealth;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get notConnected;

  /// No description provided for @syncHealthData.
  ///
  /// In en, this message translates to:
  /// **'Sync Health Data'**
  String get syncHealthData;

  /// No description provided for @reauthorizeHealthData.
  ///
  /// In en, this message translates to:
  /// **'Re-authorize Health Data'**
  String get reauthorizeHealthData;

  /// No description provided for @syncingHealthData.
  ///
  /// In en, this message translates to:
  /// **'Syncing health data from Apple Health...'**
  String get syncingHealthData;

  /// No description provided for @syncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync Complete'**
  String get syncComplete;

  /// No description provided for @todayStepsCount.
  ///
  /// In en, this message translates to:
  /// **'✅ Today\'s Steps: {steps}'**
  String todayStepsCount(Object steps);

  /// No description provided for @monthlyStepsCount.
  ///
  /// In en, this message translates to:
  /// **'📊 Monthly Steps: {steps}'**
  String monthlyStepsCount(Object steps);

  /// No description provided for @weeklyAverageSteps.
  ///
  /// In en, this message translates to:
  /// **'Weekly Average: {steps}'**
  String weeklyAverageSteps(Object steps);

  /// No description provided for @goalAchievedDays.
  ///
  /// In en, this message translates to:
  /// **'Goal Achieved: {days} days'**
  String goalAchievedDays(Object days);

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(Object error);

  /// No description provided for @checkSettings.
  ///
  /// In en, this message translates to:
  /// **'Check Settings'**
  String get checkSettings;

  /// No description provided for @reauthorizeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Re-authorization successful!'**
  String get reauthorizeSuccess;

  /// No description provided for @reauthorizeFailed.
  ///
  /// In en, this message translates to:
  /// **'Re-authorization failed, please check health app settings'**
  String get reauthorizeFailed;

  /// No description provided for @reauthorizationFailed.
  ///
  /// In en, this message translates to:
  /// **'Re-authorization failed: {error}'**
  String reauthorizationFailed(Object error);

  /// No description provided for @healthDataSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Health data sync complete! Today\'s steps: {steps}'**
  String healthDataSyncComplete(Object steps);

  /// No description provided for @healthDataSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Health data sync failed'**
  String get healthDataSyncFailed;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Step Challenge!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your daily steps, compete with friends, and achieve your health goals together.'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @onboardingHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Your Health'**
  String get onboardingHealthTitle;

  /// No description provided for @onboardingHealthDescription.
  ///
  /// In en, this message translates to:
  /// **'Monitor your daily steps and health data with Apple Health integration for accurate tracking.'**
  String get onboardingHealthDescription;

  /// No description provided for @onboardingFriendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with Friends'**
  String get onboardingFriendsTitle;

  /// No description provided for @onboardingFriendsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add friends, share QR codes, and see monthly step rankings to stay motivated together.'**
  String get onboardingFriendsDescription;

  /// No description provided for @onboardingChallengesTitle.
  ///
  /// In en, this message translates to:
  /// **'Join Challenges'**
  String get onboardingChallengesTitle;

  /// No description provided for @onboardingChallengesDescription.
  ///
  /// In en, this message translates to:
  /// **'Participate in step challenges and compete with others to achieve your fitness goals.'**
  String get onboardingChallengesDescription;

  /// No description provided for @createProfile.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get createProfile;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @basicInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start with some basic details about you'**
  String get basicInformationSubtitle;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @enterNickname.
  ///
  /// In en, this message translates to:
  /// **'Enter your nickname'**
  String get enterNickname;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @personalDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us a bit more about yourself'**
  String get personalDetailsSubtitle;

  /// No description provided for @selectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select Birth Date'**
  String get selectBirthDate;

  /// No description provided for @physicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Physical Information'**
  String get physicalInformation;

  /// No description provided for @physicalInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us calculate your health metrics accurately'**
  String get physicalInformationSubtitle;

  /// No description provided for @enterHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your height'**
  String get enterHeight;

  /// No description provided for @pleaseEnterHeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter height'**
  String get pleaseEnterHeight;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your weight'**
  String get enterWeight;

  /// No description provided for @pleaseEnterWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter weight'**
  String get pleaseEnterWeight;

  /// No description provided for @healthPermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable health data access for accurate step tracking'**
  String get healthPermissionSubtitle;

  /// No description provided for @healthPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll request permission to read your step data from Apple Health. This helps us provide accurate tracking and personalized insights.'**
  String get healthPermissionDescription;

  /// No description provided for @pleaseSelectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select gender'**
  String get pleaseSelectGender;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get completeRegistration;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @syncingData.
  ///
  /// In en, this message translates to:
  /// **'Syncing data from Apple Health...'**
  String get syncingData;

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync Completed'**
  String get syncCompleted;

  /// No description provided for @weeklyAverage.
  ///
  /// In en, this message translates to:
  /// **'📈 Weekly Average: {steps}'**
  String weeklyAverage(Object steps);

  /// No description provided for @goalAchievedCount.
  ///
  /// In en, this message translates to:
  /// **'🎯 Goal Achieved: {days} days'**
  String goalAchievedCount(Object days);

  /// No description provided for @syncFail.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFail(Object error);

  /// No description provided for @viewSettings.
  ///
  /// In en, this message translates to:
  /// **'View Settings'**
  String get viewSettings;

  /// No description provided for @checkingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Checking health data permissions...'**
  String get checkingPermissions;

  /// No description provided for @permissionStatus.
  ///
  /// In en, this message translates to:
  /// **'Permission Status: {status}'**
  String permissionStatus(Object status);

  /// No description provided for @authStatus.
  ///
  /// In en, this message translates to:
  /// **'Auth Status: {status}'**
  String authStatus(Object status);

  /// No description provided for @authorized.
  ///
  /// In en, this message translates to:
  /// **'Authorized'**
  String get authorized;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get unauthorized;

  /// No description provided for @supportedDataTypes.
  ///
  /// In en, this message translates to:
  /// **'Supported Data Types: {types}'**
  String supportedDataTypes(Object types);

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String error(Object error);

  /// No description provided for @requestPermissionAgain.
  ///
  /// In en, this message translates to:
  /// **'Request Permission Again'**
  String get requestPermissionAgain;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? This will clear all local data.'**
  String get logoutConfirmation;

  /// No description provided for @yourMonthlyPerformance.
  ///
  /// In en, this message translates to:
  /// **'Your Monthly Performance'**
  String get yourMonthlyPerformance;

  /// No description provided for @userRank.
  ///
  /// In en, this message translates to:
  /// **'Rank #{rank}'**
  String userRank(Object rank);

  /// No description provided for @km.
  ///
  /// In en, this message translates to:
  /// **'KM'**
  String get km;

  /// No description provided for @userSteps.
  ///
  /// In en, this message translates to:
  /// **'{steps} steps'**
  String userSteps(Object steps);

  /// No description provided for @friendsMonthlyRanking.
  ///
  /// In en, this message translates to:
  /// **'Friends\' Monthly Ranking'**
  String get friendsMonthlyRanking;

  /// No description provided for @youParentheses.
  ///
  /// In en, this message translates to:
  /// **'(You)'**
  String get youParentheses;

  /// No description provided for @kmValue.
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String kmValue(Object value);

  /// No description provided for @friendsWithoutSteps.
  ///
  /// In en, this message translates to:
  /// **'{count} friends have no step records yet'**
  String friendsWithoutSteps(Object count);

  /// No description provided for @idNumber.
  ///
  /// In en, this message translates to:
  /// **'ID Number/Passport Number'**
  String get idNumber;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @selectNationality.
  ///
  /// In en, this message translates to:
  /// **'Please select nationality'**
  String get selectNationality;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Information'**
  String get emergencyContact;

  /// No description provided for @emergencyContactName.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Name'**
  String get emergencyContactName;

  /// No description provided for @emergencyContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Phone'**
  String get emergencyContactPhone;

  /// No description provided for @emergencyContactRelation.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Relationship'**
  String get emergencyContactRelation;

  /// No description provided for @medicalHistory.
  ///
  /// In en, this message translates to:
  /// **'Medical History'**
  String get medicalHistory;

  /// No description provided for @medicalHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Please describe any relevant medical conditions or allergies'**
  String get medicalHistoryHint;

  /// No description provided for @relationParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get relationParent;

  /// No description provided for @relationSpouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get relationSpouse;

  /// No description provided for @relationSibling.
  ///
  /// In en, this message translates to:
  /// **'Sibling'**
  String get relationSibling;

  /// No description provided for @relationChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get relationChild;

  /// No description provided for @relationFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get relationFriend;

  /// No description provided for @relationColleague.
  ///
  /// In en, this message translates to:
  /// **'Colleague'**
  String get relationColleague;

  /// No description provided for @relationOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relationOther;

  /// No description provided for @validIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid ID number'**
  String get validIdRequired;

  /// No description provided for @validPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get validPhoneRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validEmailRequired;

  /// No description provided for @searchNationality.
  ///
  /// In en, this message translates to:
  /// **'Search Nationality'**
  String get searchNationality;

  /// No description provided for @selectNationalityDialog.
  ///
  /// In en, this message translates to:
  /// **'Select Nationality'**
  String get selectNationalityDialog;

  /// No description provided for @marathonEvents.
  ///
  /// In en, this message translates to:
  /// **'Marathon Events'**
  String get marathonEvents;

  /// No description provided for @searchMarathonEvents.
  ///
  /// In en, this message translates to:
  /// **'Search marathon events...'**
  String get searchMarathonEvents;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// No description provided for @filterMarathonEvents.
  ///
  /// In en, this message translates to:
  /// **'Filter Marathon Events'**
  String get filterMarathonEvents;

  /// No description provided for @noMarathonEvents.
  ///
  /// In en, this message translates to:
  /// **'No marathon events found'**
  String get noMarathonEvents;

  /// No description provided for @noMarathonEventsDescription.
  ///
  /// In en, this message translates to:
  /// **'Check back later for upcoming events or adjust your search criteria.'**
  String get noMarathonEventsDescription;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @registrationOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get registrationOpen;

  /// No description provided for @registrationClosed.
  ///
  /// In en, this message translates to:
  /// **'Registration Closed'**
  String get registrationClosed;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Enter location'**
  String get enterLocation;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @dateNotSet.
  ///
  /// In en, this message translates to:
  /// **'Date not set'**
  String get dateNotSet;

  /// No description provided for @marathonEventDetails.
  ///
  /// In en, this message translates to:
  /// **'Marathon Event Details'**
  String get marathonEventDetails;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @races.
  ///
  /// In en, this message translates to:
  /// **'Races'**
  String get races;

  /// No description provided for @eventDescription.
  ///
  /// In en, this message translates to:
  /// **'Event Description'**
  String get eventDescription;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @organizer.
  ///
  /// In en, this message translates to:
  /// **'Organizer'**
  String get organizer;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @routeMap.
  ///
  /// In en, this message translates to:
  /// **'Route Map'**
  String get routeMap;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @raceDate.
  ///
  /// In en, this message translates to:
  /// **'Race Date'**
  String get raceDate;

  /// No description provided for @registrationDeadline.
  ///
  /// In en, this message translates to:
  /// **'Registration Deadline'**
  String get registrationDeadline;

  /// No description provided for @entryFee.
  ///
  /// In en, this message translates to:
  /// **'Entry Fee'**
  String get entryFee;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @raceFull.
  ///
  /// In en, this message translates to:
  /// **'Race Full'**
  String get raceFull;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @eventLocation.
  ///
  /// In en, this message translates to:
  /// **'Event Location'**
  String get eventLocation;

  /// No description provided for @startPoint.
  ///
  /// In en, this message translates to:
  /// **'Start Point'**
  String get startPoint;

  /// No description provided for @finishPoint.
  ///
  /// In en, this message translates to:
  /// **'Finish Point'**
  String get finishPoint;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @landmark.
  ///
  /// In en, this message translates to:
  /// **'Landmark'**
  String get landmark;

  /// No description provided for @registerForRace.
  ///
  /// In en, this message translates to:
  /// **'Register for Race'**
  String get registerForRace;

  /// No description provided for @participantName.
  ///
  /// In en, this message translates to:
  /// **'Participant Name'**
  String get participantName;

  /// No description provided for @pleaseEnterParticipantName.
  ///
  /// In en, this message translates to:
  /// **'Please enter participant name'**
  String get pleaseEnterParticipantName;

  /// No description provided for @medicalInformation.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInformation;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccessful;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @noRouteMapAvailable.
  ///
  /// In en, this message translates to:
  /// **'No route map available'**
  String get noRouteMapAvailable;

  /// No description provided for @earlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get earlyBird;

  /// No description provided for @earlyBirdPrice.
  ///
  /// In en, this message translates to:
  /// **'Early Bird Price'**
  String get earlyBirdPrice;

  /// No description provided for @regularPrice.
  ///
  /// In en, this message translates to:
  /// **'Regular Price'**
  String get regularPrice;

  /// No description provided for @earlyBirdUntil.
  ///
  /// In en, this message translates to:
  /// **'Early Bird Until'**
  String get earlyBirdUntil;

  /// No description provided for @registrationStep1.
  ///
  /// In en, this message translates to:
  /// **'Registration Information'**
  String get registrationStep1;

  /// No description provided for @registrationStep2.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get registrationStep2;

  /// No description provided for @fillRegistrationInfo.
  ///
  /// In en, this message translates to:
  /// **'Fill Registration Information'**
  String get fillRegistrationInfo;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Payment Method'**
  String get selectPaymentMethod;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get creditCard;

  /// No description provided for @abaPayment.
  ///
  /// In en, this message translates to:
  /// **'ABA Payment'**
  String get abaPayment;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @iAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms and conditions'**
  String get iAgreeToTerms;

  /// No description provided for @pleaseAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the terms and conditions'**
  String get pleaseAgreeToTerms;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @makePayment.
  ///
  /// In en, this message translates to:
  /// **'Make Payment'**
  String get makePayment;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get paymentFailed;

  /// No description provided for @registrationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Registration completed successfully'**
  String get registrationCompleted;

  /// No description provided for @backToEvents.
  ///
  /// In en, this message translates to:
  /// **'Back to Events'**
  String get backToEvents;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount'**
  String get paymentAmount;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @selectParticipantCount.
  ///
  /// In en, this message translates to:
  /// **'Select number of participants'**
  String get selectParticipantCount;

  /// No description provided for @maximumParticipants.
  ///
  /// In en, this message translates to:
  /// **'Maximum 3 participants'**
  String get maximumParticipants;

  /// No description provided for @participantCount.
  ///
  /// In en, this message translates to:
  /// **'Number of participants'**
  String get participantCount;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'people'**
  String get people;

  /// No description provided for @fillRegistrationData.
  ///
  /// In en, this message translates to:
  /// **'Fill registration data'**
  String get fillRegistrationData;

  /// No description provided for @participantData.
  ///
  /// In en, this message translates to:
  /// **'Participant data'**
  String get participantData;

  /// No description provided for @mainContact.
  ///
  /// In en, this message translates to:
  /// **'Main contact'**
  String get mainContact;

  /// No description provided for @notFilled.
  ///
  /// In en, this message translates to:
  /// **'Not filled'**
  String get notFilled;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;
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
      <String>['en', 'km', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
