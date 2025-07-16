// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Step Challenge';

  @override
  String get home => 'Home';

  @override
  String get challenges => 'Challenges';

  @override
  String get profile => 'Profile';

  @override
  String get goodMorning => 'Good Morning!';

  @override
  String get goodAfternoon => 'Good Afternoon!';

  @override
  String get goodEvening => 'Good Evening!';

  @override
  String get stayActive => 'Stay active today!';

  @override
  String get todaySteps => 'Today\'s Steps';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get goalProgress => 'Goal Progress';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get syncData => 'Sync Data';

  @override
  String get setGoal => 'Set Goal';

  @override
  String get challengeActivities => 'Challenge Activities';

  @override
  String get personalSettings => 'Personal Settings';

  @override
  String get personalProfile => 'Personal Profile';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get healthDataPermission => 'Health Data Permission';

  @override
  String get dataSyncComplete => 'Data sync complete!';

  @override
  String get setDailyStepGoal => 'Set Daily Step Goal';

  @override
  String get goalSteps => 'Goal Steps';

  @override
  String get steps => 'steps';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get createChallengeInDevelopment =>
      'Create challenge feature in development...';

  @override
  String get healthDataAuthorized => 'Health data permission authorized';

  @override
  String get pleaseEnableHealthData =>
      'Please enable health data permission in settings';

  @override
  String get initializingApp => 'Initializing app...';

  @override
  String get save => 'Save';

  @override
  String get nickname => 'Nickname';

  @override
  String get pleaseEnterNickname => 'Please enter nickname';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get pleaseSelectBirthDate => 'Please select birth date';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get enterValidHeight => 'Please enter valid height (1-300cm)';

  @override
  String get enterValidWeight => 'Please enter valid weight (1-500kg)';

  @override
  String get savePersonalProfile => 'Save Personal Profile';

  @override
  String get personalProfileSaved => 'Personal profile saved';

  @override
  String get saveFailed => 'Save failed';

  @override
  String get imageSelectionError => 'Image selection error';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => 'Traditional Chinese';

  @override
  String get khmer => 'Khmer';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get restartRequired => 'Restart required to apply language changes';

  @override
  String get weekendWalkingChallenge => 'Weekend Walking Challenge';

  @override
  String get weekendWalkingDescription =>
      'Let\'s walk together this weekend, aiming for 8000 steps daily!';

  @override
  String get tenThousandStepChallenge => '10K Steps Master Challenge';

  @override
  String get tenThousandStepDescription =>
      'Reach 10,000 steps every day for a whole month. Do you dare to challenge?';

  @override
  String get oneMillionStepChallenge => '1 Million Steps Team Challenge';

  @override
  String get oneMillionStepDescription =>
      'Work together as a team to reach the goal of 1 million steps!';

  @override
  String get noActiveChallenges => 'No active challenges currently';

  @override
  String get createNewChallengePrompt =>
      'Create a new challenge and invite friends to exercise together!';

  @override
  String get remainingTime => 'Remaining time';

  @override
  String get ended => 'Ended';

  @override
  String get days => 'days';

  @override
  String get challengeProgress => 'Challenge Progress';

  @override
  String get participants => 'participants';

  @override
  String get join => 'Join';

  @override
  String get endingSoon => 'Ending soon';

  @override
  String get inProgress => 'In progress';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String get totalGoal => 'Total goal';

  @override
  String get duration => 'Duration';

  @override
  String get stepsUnit => 'steps';

  @override
  String get achieved => 'Achieved';

  @override
  String get goalAchieved => 'Goal achieved!';

  @override
  String get keepGoing => 'Keep going';

  @override
  String get exceededGoal => 'Exceeded goal';

  @override
  String get remainingSteps => 'Remaining steps';

  @override
  String get goalAchievedCongrats =>
      'Excellent! You\'ve achieved today\'s goal. Keep up the healthy lifestyle!';

  @override
  String get nearGoalMessage =>
      'Almost there! Just a little more walking and you\'ll succeed. Keep it up!';

  @override
  String get halfwayMessage =>
      'You\'re halfway there! Keep pushing, the goal is within reach!';

  @override
  String get goodStartMessage =>
      'Great start! Every step brings you closer to your health goal.';

  @override
  String get newDayMessage =>
      'A new day begins! Take the first step towards your goal!';

  @override
  String get thisWeekWalkingRecord => 'This Week\'s Walking Record';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get weeklyTotal => 'Weekly total';

  @override
  String get dailyAverageSteps => 'Daily average steps';

  @override
  String get daysGoalAchieved => 'Days goal achieved';

  @override
  String get stepGoalReminder => 'Step Goal Reminder';

  @override
  String get stepGoalReminderBody =>
      'You haven\'t reached your step goal today. Let\'s get walking!';

  @override
  String get challengeInvitation => 'Challenge Invitation';

  @override
  String get challengeProgressUpdate => 'Challenge Progress Update';

  @override
  String clickedChallenge(Object challengeTitle) {
    return 'Selected challenge: $challengeTitle';
  }

  @override
  String joinedChallenge(Object challengeTitle) {
    return 'Joined challenge: $challengeTitle';
  }

  @override
  String shareChallenge(Object challengeTitle) {
    return 'Share challenge: $challengeTitle';
  }

  @override
  String goalWith(Object goal) {
    return 'Goal: $goal steps';
  }

  @override
  String remainingStepsToGoal(Object remaining) {
    return 'Need $remaining more steps to reach goal';
  }

  @override
  String get friends => 'Friends';

  @override
  String get addFriends => 'Add Friends';

  @override
  String get myQrCode => 'My QR Code';

  @override
  String get shareInviteLink => 'Share Invite Link';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get friendsList => 'Friends List';

  @override
  String get monthlySteps => 'Monthly Steps';

  @override
  String get friendsStepsThisMonth => 'Friends\' Steps This Month';

  @override
  String get noFriendsYet => 'No friends yet';

  @override
  String get addFriendsPrompt =>
      'Add friends to see their step progress and compete together!';

  @override
  String get scanToAddFriend =>
      'Scan this QR code or share the link to add me as a friend';

  @override
  String get friendInviteTitle => 'Join me on Step Challenge!';

  @override
  String get friendInviteMessage =>
      'Hi! I\'m using Step Challenge to track my daily steps. Join me and let\'s motivate each other to stay active!';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get removeFriend => 'Remove Friend';

  @override
  String get friendAdded => 'Friend added successfully!';

  @override
  String get friendRemoved => 'Friend removed';

  @override
  String get friendAddError => 'Error adding friend';

  @override
  String get invalidQrCode => 'Invalid QR code';

  @override
  String get shareLink => 'Share Link';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get linkCopied => 'Link copied to clipboard';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String stepsThisMonth(Object steps) {
    return '$steps steps this month';
  }

  @override
  String rank(Object rank) {
    return 'Rank #$rank';
  }

  @override
  String get you => 'You';

  @override
  String get friendsRanking => 'Friends Ranking';
}
