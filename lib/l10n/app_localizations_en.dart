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

  @override
  String get appleHealth => 'Apple Health';

  @override
  String get connected => 'Connected';

  @override
  String get notConnected => 'Not Connected';

  @override
  String get syncHealthData => 'Sync Health Data';

  @override
  String get reauthorizeHealthData => 'Re-authorize Health Data';

  @override
  String get syncingHealthData => 'Syncing health data from Apple Health...';

  @override
  String get syncComplete => 'Sync Complete';

  @override
  String todayStepsCount(Object steps) {
    return '✅ Today\'s Steps: $steps';
  }

  @override
  String monthlyStepsCount(Object steps) {
    return '📊 Monthly Steps: $steps';
  }

  @override
  String weeklyAverageSteps(Object steps) {
    return 'Weekly Average: $steps';
  }

  @override
  String goalAchievedDays(Object days) {
    return 'Goal Achieved: $days days';
  }

  @override
  String syncFailed(Object error) {
    return 'Sync failed: $error';
  }

  @override
  String get checkSettings => 'Check Settings';

  @override
  String get reauthorizeSuccess => 'Re-authorization successful!';

  @override
  String get reauthorizeFailed =>
      'Re-authorization failed, please check health app settings';

  @override
  String reauthorizationFailed(Object error) {
    return 'Re-authorization failed: $error';
  }

  @override
  String healthDataSyncComplete(Object steps) {
    return 'Health data sync complete! Today\'s steps: $steps';
  }

  @override
  String get healthDataSyncFailed => 'Health data sync failed';

  @override
  String get welcomeTitle => 'Welcome to Step Challenge!';

  @override
  String get welcomeSubtitle =>
      'Track your daily steps, compete with friends, and achieve your health goals together.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get onboardingHealthTitle => 'Track Your Health';

  @override
  String get onboardingHealthDescription =>
      'Monitor your daily steps and health data with Apple Health integration for accurate tracking.';

  @override
  String get onboardingFriendsTitle => 'Connect with Friends';

  @override
  String get onboardingFriendsDescription =>
      'Add friends, share QR codes, and see monthly step rankings to stay motivated together.';

  @override
  String get onboardingChallengesTitle => 'Join Challenges';

  @override
  String get onboardingChallengesDescription =>
      'Participate in step challenges and compete with others to achieve your fitness goals.';

  @override
  String get createProfile => 'Create Profile';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get basicInformationSubtitle =>
      'Let\'s start with some basic details about you';

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get enterNickname => 'Enter your nickname';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get personalDetailsSubtitle => 'Tell us a bit more about yourself';

  @override
  String get selectBirthDate => 'Select Birth Date';

  @override
  String get physicalInformation => 'Physical Information';

  @override
  String get physicalInformationSubtitle =>
      'Help us calculate your health metrics accurately';

  @override
  String get enterHeight => 'Enter your height';

  @override
  String get pleaseEnterHeight => 'Please enter height';

  @override
  String get enterWeight => 'Enter your weight';

  @override
  String get pleaseEnterWeight => 'Please enter weight';

  @override
  String get healthPermissionSubtitle =>
      'Enable health data access for accurate step tracking';

  @override
  String get healthPermissionDescription =>
      'We\'ll request permission to read your step data from Apple Health. This helps us provide accurate tracking and personalized insights.';

  @override
  String get pleaseSelectGender => 'Please select gender';

  @override
  String get completeRegistration => 'Complete Registration';

  @override
  String get logout => 'Logout';

  @override
  String get syncingData => 'Syncing data from Apple Health...';

  @override
  String get syncCompleted => 'Sync Completed';

  @override
  String weeklyAverage(Object steps) {
    return '📈 Weekly Average: $steps';
  }

  @override
  String goalAchievedCount(Object days) {
    return '🎯 Goal Achieved: $days days';
  }

  @override
  String syncFail(Object error) {
    return 'Sync failed: $error';
  }

  @override
  String get viewSettings => 'View Settings';

  @override
  String get checkingPermissions => 'Checking health data permissions...';

  @override
  String permissionStatus(Object status) {
    return 'Permission Status: $status';
  }

  @override
  String authStatus(Object status) {
    return 'Auth Status: $status';
  }

  @override
  String get authorized => 'Authorized';

  @override
  String get unauthorized => 'Unauthorized';

  @override
  String supportedDataTypes(Object types) {
    return 'Supported Data Types: $types';
  }

  @override
  String error(Object error) {
    return 'Error: $error';
  }

  @override
  String get requestPermissionAgain => 'Request Permission Again';

  @override
  String get logoutConfirmation =>
      'Are you sure you want to log out? This will clear all local data.';

  @override
  String get yourMonthlyPerformance => 'Your Monthly Performance';

  @override
  String userRank(Object rank) {
    return 'Rank #$rank';
  }

  @override
  String get km => 'KM';

  @override
  String userSteps(Object steps) {
    return '$steps steps';
  }

  @override
  String get friendsMonthlyRanking => 'Friends\' Monthly Ranking';

  @override
  String get youParentheses => '(You)';

  @override
  String kmValue(Object value) {
    return '$value km';
  }

  @override
  String friendsWithoutSteps(Object count) {
    return '$count friends have no step records yet';
  }

  @override
  String get idNumber => 'ID Number/Passport Number';

  @override
  String get nationality => 'Nationality';

  @override
  String get selectNationality => 'Please select nationality';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get email => 'Email';

  @override
  String get emergencyContact => 'Emergency Contact Information';

  @override
  String get emergencyContactName => 'Emergency Contact Name';

  @override
  String get emergencyContactPhone => 'Emergency Contact Phone';

  @override
  String get emergencyContactRelation => 'Emergency Contact Relationship';

  @override
  String get medicalHistory => 'Medical History';

  @override
  String get medicalHistoryHint =>
      'Please describe any relevant medical conditions or allergies';

  @override
  String get relationParent => 'Parent';

  @override
  String get relationSpouse => 'Spouse';

  @override
  String get relationSibling => 'Sibling';

  @override
  String get relationChild => 'Child';

  @override
  String get relationFriend => 'Friend';

  @override
  String get relationColleague => 'Colleague';

  @override
  String get relationOther => 'Other';

  @override
  String get validIdRequired => 'Please enter a valid ID number';

  @override
  String get validPhoneRequired => 'Please enter a valid phone number';

  @override
  String get validEmailRequired => 'Please enter a valid email address';

  @override
  String get searchNationality => 'Search Nationality';

  @override
  String get selectNationalityDialog => 'Select Nationality';

  @override
  String get marathonEvents => 'Marathon Events';

  @override
  String get searchMarathonEvents => 'Search marathon events...';

  @override
  String get filter => 'Filter';

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get filterMarathonEvents => 'Filter Marathon Events';

  @override
  String get noMarathonEvents => 'No marathon events found';

  @override
  String get noMarathonEventsDescription =>
      'Check back later for upcoming events or adjust your search criteria.';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get registrationOpen => 'Open';

  @override
  String get registrationClosed => 'Registration Closed';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get distance => 'Distance';

  @override
  String get location => 'Location';

  @override
  String get enterLocation => 'Enter location';

  @override
  String get dateRange => 'Date Range';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get clearAll => 'Clear All';

  @override
  String get apply => 'Apply';

  @override
  String get status => 'Status';

  @override
  String get dateNotSet => 'Date not set';

  @override
  String get marathonEventDetails => 'Marathon Event Details';

  @override
  String get details => 'Details';

  @override
  String get races => 'Races';

  @override
  String get eventDescription => 'Event Description';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get organizer => 'Organizer';

  @override
  String get website => 'Website';

  @override
  String get routeMap => 'Route Map';

  @override
  String get notes => 'Notes';

  @override
  String get tags => 'Tags';

  @override
  String get raceDate => 'Race Date';

  @override
  String get registrationDeadline => 'Registration Deadline';

  @override
  String get entryFee => 'Entry Fee';

  @override
  String get free => 'Free';

  @override
  String get raceFull => 'Race Full';

  @override
  String get registered => 'Registered';

  @override
  String get register => 'Register';

  @override
  String get eventLocation => 'Event Location';

  @override
  String get startPoint => 'Start Point';

  @override
  String get finishPoint => 'Finish Point';

  @override
  String get address => 'Address';

  @override
  String get landmark => 'Landmark';

  @override
  String get registerForRace => 'Register for Race';

  @override
  String get participantName => 'Participant Name';

  @override
  String get pleaseEnterParticipantName => 'Please enter participant name';

  @override
  String get medicalInformation => 'Medical Information';

  @override
  String get registrationSuccessful => 'Registration successful!';

  @override
  String get registrationFailed => 'Registration failed';

  @override
  String get community => 'Community';

  @override
  String get events => 'Events';

  @override
  String get noRouteMapAvailable => 'No route map available';

  @override
  String get earlyBird => 'Early Bird';

  @override
  String get earlyBirdPrice => 'Early Bird Price';

  @override
  String get regularPrice => 'Regular Price';

  @override
  String get earlyBirdUntil => 'Early Bird Until';

  @override
  String get registrationStep1 => 'Registration Information';

  @override
  String get registrationStep2 => 'Payment Method';

  @override
  String get fillRegistrationInfo => 'Fill Registration Information';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get abaPayment => 'ABA Payment';

  @override
  String get termsAndConditions => 'I agree to the Terms and Conditions';

  @override
  String get iAgreeToTerms => 'I agree to the terms and conditions';

  @override
  String get pleaseAgreeToTerms => 'Please agree to the terms and conditions';

  @override
  String get proceedToPayment => 'Proceed to Payment';

  @override
  String get makePayment => 'Make Payment';

  @override
  String get paymentSuccessful => 'Payment Successful!';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get registrationCompleted => 'Registration completed successfully';

  @override
  String get backToEvents => 'Back to Events';

  @override
  String get paymentAmount => 'Payment Amount';

  @override
  String get name => 'Name';

  @override
  String get pleaseEnterName => 'Please enter name';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get selectParticipantCount => 'Select number of participants';

  @override
  String get maximumParticipants => 'Maximum 3 participants';

  @override
  String get participantCount => 'Number of participants';

  @override
  String get people => 'people';

  @override
  String get fillRegistrationData => 'Fill registration data';

  @override
  String get participantData => 'Participant data';

  @override
  String get mainContact => 'Main contact';

  @override
  String get notFilled => 'Not filled';

  @override
  String get complete => 'Complete';
}
