// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Gym Tracker';

  @override
  String get authLoginTitle => 'Log In';

  @override
  String get authLoginWelcomeTitle => 'Welcome Back';

  @override
  String get authLoginSubtitle => 'Sign in to track your gym attendance';

  @override
  String get authLoginSignUp => 'Sign up';

  @override
  String get authLoginEmail => 'Email';

  @override
  String get authLoginPassword => 'Password';

  @override
  String get authLoginButton => 'Log In';

  @override
  String get authLoginNoAccount => 'Don\'t have an account?';

  @override
  String get authLoginForgotPassword => 'Forgot password?';

  @override
  String get authRegisterTitle => 'Create Account';

  @override
  String get authRegisterDisplayName => 'Display Name';

  @override
  String get authRegisterEmail => 'Email';

  @override
  String get authRegisterPassword => 'Password';

  @override
  String get authRegisterConfirmPassword => 'Confirm Password';

  @override
  String get authRegisterButton => 'Create Account';

  @override
  String get authRegisterHaveAccount => 'Already have an account?';

  @override
  String get authRegisterSubtitle => 'Start tracking your gym attendance today';

  @override
  String get authRegisterSignIn => 'Sign in';

  @override
  String get authRegisterSuccess => 'Account Created!';

  @override
  String get authRegisterSuccessMessage =>
      'Please check your email to verify your account before signing in.';

  @override
  String get authRegisterGoToLogin => 'Go to Sign In';

  @override
  String get authRegisterContinue => 'Continue';

  @override
  String get authRegisterSkip => 'Skip for now';

  @override
  String get authPersonalDetailsTitle => 'Personalize your experience';

  @override
  String get authPersonalDetailsSubtitle =>
      'Optional — helps tailor future health insights. You can skip this and add it later.';

  @override
  String get authPersonalDetailsSex => 'Sex';

  @override
  String get authPersonalDetailsSexMale => 'Male';

  @override
  String get authPersonalDetailsSexFemale => 'Female';

  @override
  String get authPersonalDetailsBirthDate => 'Date of birth';

  @override
  String get authPersonalDetailsBirthDateHint => 'Select date';

  @override
  String get authPersonalDetailsHeight => 'Height (cm)';

  @override
  String get authPersonalDetailsWeight => 'Weight (kg)';

  @override
  String get authPersonalDetailsBodyType => 'Body type';

  @override
  String get authPersonalDetailsBodyTypeLean => 'Lean';

  @override
  String get authPersonalDetailsBodyTypeAthletic => 'Athletic';

  @override
  String get authPersonalDetailsBodyTypeAverage => 'Average';

  @override
  String get authPersonalDetailsBodyTypeSkinnyFat => 'Skinny fat';

  @override
  String get authPersonalDetailsBodyTypeHigherBodyFat => 'Higher body fat';

  @override
  String get authPersonalDetailsBack => 'Back';

  @override
  String get authPasswordStrengthWeak => 'Weak';

  @override
  String get authPasswordStrengthFair => 'Fair';

  @override
  String get authPasswordStrengthStrong => 'Strong';

  @override
  String get authPasswordReqLength => '8+ characters';

  @override
  String get authPasswordReqUppercase => 'Uppercase';

  @override
  String get authPasswordReqLowercase => 'Lowercase';

  @override
  String get authPasswordReqNumber => 'Number';

  @override
  String get authPasswordsMatch => 'Passwords match';

  @override
  String get authPasswordsNoMatch => 'Passwords don\'t match';

  @override
  String get authForgotPasswordTitle => 'Reset Password';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email and we\'ll send you a reset link';

  @override
  String get authForgotPasswordSuccessTitle => 'Check Your Inbox';

  @override
  String get authForgotPasswordEmail => 'Email';

  @override
  String get authForgotPasswordButton => 'Send Reset Email';

  @override
  String get authForgotPasswordBack => 'Back to Login';

  @override
  String get authForgotPasswordSent => 'Reset email sent. Check your inbox.';

  @override
  String get authEmailNotVerified =>
      'Please verify your email before logging in.';

  @override
  String get authVerificationEmailSent => 'Verification email sent.';

  @override
  String get authSignOut => 'Sign Out';

  @override
  String get authEmailVerificationHandled => 'Email verified successfully.';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navWorkouts => 'Workouts';

  @override
  String get navStats => 'Stats';

  @override
  String get navHealth => 'Health';

  @override
  String get navProfile => 'Profile';

  @override
  String get workoutsTitle => 'Workouts';

  @override
  String get workoutsManageTypes => 'Manage workout types';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarMonthly => 'Monthly';

  @override
  String get calendarYearly => 'Yearly';

  @override
  String get calendarMarkAttended => 'Mark as attended';

  @override
  String get calendarWentToGym => 'Went to gym';

  @override
  String get calendarSave => 'Save';

  @override
  String get calendarClear => 'Clear';

  @override
  String get calendarAddSupplement => 'Add supplement';

  @override
  String get calendarWorkoutTab => 'Workout';

  @override
  String get calendarHealthTab => 'Health';

  @override
  String get calendarNotes => 'Notes';

  @override
  String get calendarDurationMinutes => 'Duration (minutes)';

  @override
  String get calendarTrainingType => 'Training type';

  @override
  String get calendarNoType => 'No type';

  @override
  String get calendarNoHealthLogs => 'No supplements logged for this day.';

  @override
  String get calendarSelectProduct => 'Select a product';

  @override
  String get calendarRemove => 'Remove';

  @override
  String get calendarCancel => 'Cancel';

  @override
  String get calendarDidYouGoToGym => 'Did you go to the gym?';

  @override
  String get calendarSelectTypePlaceholder => '-- Select type --';

  @override
  String get calendarSelectWorkoutTypeOptional =>
      'Select Workout Type (optional)';

  @override
  String get calendarDurationLabel => 'Duration:';

  @override
  String get calendarDurationHint => 'e.g. 60';

  @override
  String get calendarDurationOptional => 'Duration (optional)';

  @override
  String get calendarAdd => 'Add';

  @override
  String get calendarSupplementsTaken => 'Supplements taken';

  @override
  String get calendarNoSupplementProductsAvailable =>
      'No supplement products available.';

  @override
  String get calendarDidYouTakeAnySupplements =>
      'Did you take any supplements?';

  @override
  String get calendarAddSupplementLabel => 'Add Supplement:';

  @override
  String get calendarPleaseSelectSupplement => 'Please select a supplement';

  @override
  String get calendarSelectSupplementHint => 'Select a supplement...';

  @override
  String calendarDurationMinutesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min',
      one: '$count min',
    );
    return '$_temp0';
  }

  @override
  String calendarDurationHoursShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count h',
      one: '$count h',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsAttendances => 'Attendances';

  @override
  String get statsWorkout => 'Workout';

  @override
  String get statsDuration => 'Duration';

  @override
  String get statsHealth => 'Health';

  @override
  String get statsThisMonth => 'This Month';

  @override
  String get statsThisYear => 'This Year';

  @override
  String get statsAllTime => 'All Time';

  @override
  String get statsCurrentStreak => 'Current Streak';

  @override
  String get statsBestStreak => 'Best Streak';

  @override
  String get statsFavoriteDay => 'Fav Day';

  @override
  String get statsConsistency => 'Consistency';

  @override
  String get statsConsistencyWithoutIcon => 'Consistency';

  @override
  String get statsUniqueSupplements => 'Unique Supplements';

  @override
  String get statsStreak0 => 'Start your journey!';

  @override
  String get statsStreak1 => 'First week down!';

  @override
  String get statsStreak2 => 'Building momentum!';

  @override
  String get statsStreak4 => 'One month strong!';

  @override
  String get statsStreak8 => 'You\'re on fire!';

  @override
  String get statsStreak12 => 'Consistency king!';

  @override
  String get statsStreak20 => 'Unstoppable!';

  @override
  String get statsStreak30 => 'Half-year beast!';

  @override
  String get statsStreak40 => 'Legend mode!';

  @override
  String get statsStreak52 => 'Almost a full year!';

  @override
  String get statsStreakMax => 'Absolute GOAT!';

  @override
  String get statsTapToSeeDates => 'Tap to see dates';

  @override
  String get statsNoStreakYet => 'No streak yet';

  @override
  String get statsDaysYouHitGym => 'Days You Hit the Gym';

  @override
  String get statsFavoriteDayLegend => 'Favorite day';

  @override
  String get statsFavoriteDaysLegend => 'Favorite days';

  @override
  String get statsMonthlyBreakdown => 'Monthly Breakdown';

  @override
  String get statsAverageDurationLegend => 'Average duration';

  @override
  String get statsOfWeeksThisYear => 'of weeks this year';

  @override
  String statsXThisYear(Object count) {
    return '${count}x this year';
  }

  @override
  String statsWeekCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '$count week',
    );
    return '$_temp0';
  }

  @override
  String statsPercentOfWeeksThisYear(int percent) {
    return '$percent% of weeks this year';
  }

  @override
  String statsDifferentProducts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count different products',
      one: '1 different product',
    );
    return '$_temp0';
  }

  @override
  String statsCountTimes(int count) {
    return '${count}x';
  }

  @override
  String get statsAvgThisMonth => 'Avg This Month';

  @override
  String get statsAvgThisYear => 'Avg This Year';

  @override
  String get statsUntrackedCount => 'Untracked';

  @override
  String get statsMinutes => 'min';

  @override
  String get statsTotalLogs => 'Total Logs';

  @override
  String get statsMostUsed => 'Most Used';

  @override
  String get statsTotalTracked => 'Total Tracked';

  @override
  String get monthsJanuary => 'January';

  @override
  String get monthsFebruary => 'February';

  @override
  String get monthsMarch => 'March';

  @override
  String get monthsApril => 'April';

  @override
  String get monthsMay => 'May';

  @override
  String get monthsJune => 'June';

  @override
  String get monthsJuly => 'July';

  @override
  String get monthsAugust => 'August';

  @override
  String get monthsSeptember => 'September';

  @override
  String get monthsOctober => 'October';

  @override
  String get monthsNovember => 'November';

  @override
  String get monthsDecember => 'December';

  @override
  String get weekdaysMonday => 'Monday';

  @override
  String get weekdaysTuesday => 'Tuesday';

  @override
  String get weekdaysWednesday => 'Wednesday';

  @override
  String get weekdaysThursday => 'Thursday';

  @override
  String get weekdaysFriday => 'Friday';

  @override
  String get weekdaysSaturday => 'Saturday';

  @override
  String get weekdaysSunday => 'Sunday';

  @override
  String get weekdaysMiniMon => 'M';

  @override
  String get weekdaysMiniTue => 'T';

  @override
  String get weekdaysMiniWed => 'W';

  @override
  String get weekdaysMiniThu => 'T';

  @override
  String get weekdaysMiniFri => 'F';

  @override
  String get weekdaysMiniSat => 'S';

  @override
  String get weekdaysMiniSun => 'S';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEmailVerified => 'Verified';

  @override
  String get profileManage => 'Manage';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileWorkoutTypes => 'Workout Types';

  @override
  String get profileMembershipHistory => 'Membership history';

  @override
  String get profileMembershipHistorySubtitle => 'Track purchases and validity';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get workoutTypesTitle => 'Workout Types';

  @override
  String get workoutTypesAdd => 'Add Type';

  @override
  String get workoutTypesSave => 'Save';

  @override
  String get workoutTypesDelete => 'Delete';

  @override
  String get workoutTypesDeleteConfirm =>
      'Are you sure you want to delete this workout type?';

  @override
  String get workoutTypesName => 'Name';

  @override
  String get workoutTypesNamePlaceholder => 'e.g. Strength Training';

  @override
  String get workoutTypesIcon => 'Icon';

  @override
  String get workoutTypesColor => 'Color';

  @override
  String get workoutTypesCreate => 'Create';

  @override
  String get workoutTypesCancel => 'Cancel';

  @override
  String get workoutTypesEmpty =>
      'No workout types yet.\nTap + to add your first type.';

  @override
  String get workoutTypesEmptyTitle => 'No workout types yet';

  @override
  String get workoutTypesEmptyDescription =>
      'Create your first workout type to organize sessions.';

  @override
  String get workoutTypesCreateFirst => 'Create First Type';

  @override
  String get workoutTypesCreateTitle => 'Create Workout Type';

  @override
  String get workoutTypesEditTitle => 'Edit Type';

  @override
  String get workoutTypesDeleteTitle => 'Delete workout type';

  @override
  String get workoutTypesDeleteWarning => 'This action cannot be undone.';

  @override
  String get workoutTypesLoading => 'Loading workout types...';

  @override
  String get workoutTypesPreview => 'Preview';

  @override
  String get workoutTypesPreviewName => 'Workout Type';

  @override
  String get healthTitle => 'Health';

  @override
  String get healthInsightsEntryTooltip => 'Health Insights';

  @override
  String get healthInsightsTitle => 'Health Insights';

  @override
  String get healthInsightsInfoClose => 'Got it';

  @override
  String get healthInsightsNoData => 'Not enough data yet.';

  @override
  String healthInsightsChartPeriod(String start, String end) {
    return '$start – $end';
  }

  @override
  String get healthInsightsOverviewTitle => 'Physical Overview';

  @override
  String get healthInsightsOverviewInfo =>
      'Your latest weight, lean mass, and body-fat % from Apple Health, alongside a comparison you choose: people who share your age, sex, and height, or an earlier version of yourself.';

  @override
  String get healthInsightsOverviewWeight => 'Weight';

  @override
  String get healthInsightsOverviewLeanMass => 'Lean mass';

  @override
  String get healthInsightsOverviewBodyFat => 'Body fat';

  @override
  String get healthInsightsOverviewAge => 'Age';

  @override
  String get healthInsightsOverviewHeight => 'Height';

  @override
  String get healthInsightsOverviewStress => 'Stress';

  @override
  String get healthInsightsStressBandLow => 'Low';

  @override
  String get healthInsightsStressBandTypical => 'Typical';

  @override
  String get healthInsightsStressBandElevated => 'Elevated';

  @override
  String get healthInsightsStressBandHigh => 'High';

  @override
  String get healthInsightsOverviewCompareCta => 'Tap to compare';

  @override
  String get healthInsightsComparePopulation => 'Population';

  @override
  String get healthInsightsCompareSelf => 'Past you';

  @override
  String get healthInsightsWindow3m => '3 months';

  @override
  String get healthInsightsWindow6m => '6 months';

  @override
  String get healthInsightsWindow1y => '1 year';

  @override
  String get healthInsightsWindow2y => '2 years';

  @override
  String get healthInsightsBodyCompTitle => 'Body Recomposition';

  @override
  String get healthInsightsBodyCompInfo =>
      'Tracks whether a recent weight change came from fat or muscle, using your weight and lean-body-mass readings. A clean cut loses fat while keeping lean mass; recomposition gains muscle while losing fat at a similar weight.';

  @override
  String get healthInsightsBodyCompCutting =>
      'Cutting — losing fat, keeping muscle';

  @override
  String get healthInsightsBodyCompBulking =>
      'Bulking — gaining weight and muscle';

  @override
  String get healthInsightsBodyCompRecomposition =>
      'Recomposition — gaining muscle, losing fat';

  @override
  String get healthInsightsBodyCompStable => 'Stable';

  @override
  String get healthInsightsBodyCompWeightLabel => 'Weight';

  @override
  String get healthInsightsBodyCompFatLabel => 'Body fat';

  @override
  String get healthInsightsVo2Title => 'Cardio Fitness (VO2Max)';

  @override
  String get healthInsightsVo2Info =>
      'VO2Max measures how efficiently your body uses oxygen during exercise — a core fitness marker. Because Apple reports it per kilogram of body weight, this card also shows what your reading would be at a past weight, so a real fitness change isn\'t confused with a bodyweight change.';

  @override
  String get healthInsightsVo2Current => 'Current VO2Max';

  @override
  String get healthInsightsVo2AtPastWeight => 'At your past weight';

  @override
  String get healthInsightsHrrTitle => 'Heart Rate Recovery';

  @override
  String get healthInsightsHrrInfo =>
      'How many beats per minute your heart rate drops in the first minute after exercise stops — a well-established marker of cardiovascular fitness and how well your nervous system recovers. Based on Cole et al. (New England Journal of Medicine, 1999): a drop of 12 bpm or less was linked to higher health risk in that study, so a bigger drop is generally better.';

  @override
  String get healthInsightsHrrBandLabel => 'Recovery level';

  @override
  String get healthInsightsHrrBandLow => 'Low';

  @override
  String get healthInsightsHrrBandFair => 'Fair';

  @override
  String get healthInsightsHrrBandGood => 'Good';

  @override
  String get healthInsightsHrrBandExcellent => 'Excellent';

  @override
  String get healthInsightsMetabolicTitle => 'Resting Energy & TDEE';

  @override
  String get healthInsightsMetabolicInfo =>
      'Two personalized resting-metabolic-rate estimates — Mifflin-St Jeor (age/sex/height/weight) and, when you have a recent lean-body-mass reading, the Cunningham equation, generally considered more accurate for people who track body composition — shown next to Apple Watch\'s own daily averages for reference.';

  @override
  String get healthInsightsMetabolicTdee => 'Estimated total daily burn';

  @override
  String get healthInsightsMetabolicCunningham =>
      'Resting rate (lean-mass based)';

  @override
  String get healthInsightsMetabolicMifflin => 'Resting rate (estimated)';

  @override
  String get healthInsightsMetabolicWatch => 'Apple Watch resting average';

  @override
  String get healthInsightsMetabolicActive => 'Apple Watch active average';

  @override
  String get healthInsightsPermissionDeniedTitle => 'No Apple Health data';

  @override
  String get healthInsightsPermissionDeniedMessage =>
      'Gym Tracker couldn\'t read any Apple Health data. If you haven\'t allowed access, open the Health app, tap your profile picture › Apps › Gym Tracker, turn the data on, then try again.';

  @override
  String healthInsightsPopulationCompareSubtitle(String cohort) {
    return 'Compared to an average adult in the $cohort reference group, at your height.';
  }

  @override
  String get healthInsightsPopulationCompareYou => 'You';

  @override
  String get healthInsightsPopulationCompareAverage => 'Average';

  @override
  String get healthInsightsHrrReferenceCaption => 'Healthy reference';

  @override
  String get healthToday => 'Today';

  @override
  String get healthMySupplements => 'My Supplements';

  @override
  String get healthAllSupplements => 'All Supplements';

  @override
  String get healthProductName => 'Product Name';

  @override
  String get healthBrand => 'Brand';

  @override
  String get healthIngredients => 'Ingredients';

  @override
  String get healthServings => 'Servings';

  @override
  String get healthAddSupplement => 'Add Supplement';

  @override
  String get healthLogToday => 'Log Today';

  @override
  String get healthSave => 'Save';

  @override
  String get healthDelete => 'Delete';

  @override
  String get healthSearchPlaceholder => 'Search by name or brand...';

  @override
  String get healthServingsPerDay => 'Servings per day';

  @override
  String get healthProductCreated => 'Supplement created.';

  @override
  String get healthProductUpdated => 'Supplement updated.';

  @override
  String get healthDeleteSupplementTitle => 'Delete supplement';

  @override
  String get healthDeleteWarning => 'This action cannot be undone.';

  @override
  String get healthDeleteLogTitle => 'Delete log';

  @override
  String get healthDeleteLogMessage =>
      'Are you sure you want to delete this supplement log?';

  @override
  String get healthMySearchHint => 'Search my supplements...';

  @override
  String get healthAllSearchHint => 'Search all supplements...';

  @override
  String get healthNoPersonalSupplements => 'No personal supplements';

  @override
  String get healthNoPersonalSupplementsMessage =>
      'You have not added any custom supplements yet.';

  @override
  String get healthNoSupplementsFound => 'No supplements found';

  @override
  String get healthNoSupplementsFoundMessage => 'Try changing the search term.';

  @override
  String get healthNoSupplementsToday => 'No supplements logged today';

  @override
  String get healthNoSupplementsTodayMessage =>
      'Start your day by logging your supplements.';

  @override
  String get healthEditAction => 'Edit';

  @override
  String get healthEditSupplement => 'Edit Supplement';

  @override
  String get healthIngredientName => 'Ingredient';

  @override
  String get healthAmount => 'Amount';

  @override
  String get healthNoIngredientsYet => 'No ingredients added yet.';

  @override
  String get healthUnknownProduct => 'Unknown';

  @override
  String healthServingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings',
      one: '$count serving',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsActions => 'Actions';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsTerms => 'Terms of Service';

  @override
  String get settingsPrivacy => 'Privacy Policy';

  @override
  String legalConsentMessage(String terms, String privacy) {
    return 'I have read and agree to the $terms and $privacy.';
  }

  @override
  String get legalConsentTermsLabel => 'Terms of Service';

  @override
  String get legalConsentPrivacyLabel => 'Privacy Policy';

  @override
  String get legalConsentRequired =>
      'You must accept the Terms of Service and Privacy Policy to continue.';

  @override
  String get authAgeConfirm => 'I confirm I am at least 16 years old.';

  @override
  String get authAgeRequired =>
      'You must be at least 16 years old to use this app.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageRo => 'Romanian';

  @override
  String get settingsCurrency => 'Default currency';

  @override
  String get settingsCurrencyUpdated => 'Default currency updated.';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsCurrentPassword => 'Current Password';

  @override
  String get settingsNewPassword => 'New Password';

  @override
  String get settingsConfirmPassword => 'Confirm Password';

  @override
  String get settingsSavePassword => 'Save Password';

  @override
  String get settingsAppVersion => 'App Version';

  @override
  String get settingsBuiltWith => 'Built with Flutter + Firebase';

  @override
  String get settingsBuiltWithValue => 'Flutter + Firebase';

  @override
  String get settingsDataMigration => 'Data Migration';

  @override
  String get settingsRunMigration => 'Run Migration';

  @override
  String get errorsInvalidCredentials => 'Invalid email or password.';

  @override
  String get errorsEmailAlreadyInUse => 'This email is already in use.';

  @override
  String get errorsEmailNotVerified =>
      'Please verify your email before logging in.';

  @override
  String get errorsWeakPassword => 'Password is too weak.';

  @override
  String get errorsNetworkError =>
      'Network error. Please check your connection.';

  @override
  String get errorsUnknown => 'Something went wrong. Please try again.';

  @override
  String get errorsNumbersOnly => 'Please enter only numbers';

  @override
  String get errorsInvalidNumber => 'Please enter a valid number';

  @override
  String get errorsPositiveNumber => 'Please enter a positive number';

  @override
  String get errorsFieldRequired => 'This field is required.';

  @override
  String get errorsPasswordMismatch => 'Passwords do not match.';

  @override
  String get errorsPasswordTooShort =>
      'Password must be at least 6 characters.';

  @override
  String get errorsHeightInvalid => 'Enter a height between 50 and 260 cm.';

  @override
  String get errorsWeightInvalid => 'Enter a weight between 20 and 400 kg.';

  @override
  String get settingsPasswordChangedSuccess => 'Password changed successfully.';

  @override
  String get settingsDeleteAccount => 'Delete Account';

  @override
  String get settingsDeleteAccountTitle => 'Delete Account';

  @override
  String get settingsDeleteAccountMessage =>
      'This will permanently delete your account and all your data (workouts, supplement logs, training types, and gym memberships). This action cannot be undone.';

  @override
  String get settingsDeleteAccountConfirm => 'Delete My Account';

  @override
  String get settingsDeleteAccountPasswordHint =>
      'Enter your password to confirm';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get profileDefaultUserName => 'Gym Tracker User';

  @override
  String get globalTryAgain => 'Try Again';

  @override
  String get onboardingTitle1 => 'Track Your Workouts';

  @override
  String get onboardingSubtitle1 =>
      'Log every gym session and see your attendance at a glance.';

  @override
  String get onboardingTitle2 => 'Monitor Your Health';

  @override
  String get onboardingSubtitle2 =>
      'Keep track of your supplements and daily nutrition.';

  @override
  String get onboardingTitle3 => 'Analyze Your Progress';

  @override
  String get onboardingSubtitle3 =>
      'View detailed stats, streaks, and monthly breakdowns.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get forceUpdateTitle => 'Update required';

  @override
  String get forceUpdateBody =>
      'A new version of Gym Tracker is required to continue.';

  @override
  String get forceUpdateButton => 'Update now';

  @override
  String get forceUpdateCurrentVersion => 'Your version';

  @override
  String get forceUpdateRequiredVersion => 'Required version';

  @override
  String get maintenanceTitle => 'We\'ll be right back';

  @override
  String get maintenanceRetry => 'Try again';

  @override
  String get noConnectionTitle => 'No connection';

  @override
  String get noConnectionBody =>
      'Gym Tracker needs an internet connection to start. Please check your network and try again.';

  @override
  String get noConnectionRetry => 'Try again';

  @override
  String get bigUpdateTitle => 'A big update is here';

  @override
  String bigUpdateBody(String version) {
    return 'Version $version is available with major improvements. Update now to get the latest features.';
  }

  @override
  String get bigUpdateAction => 'Update now';

  @override
  String get bigUpdateLater => 'Remind me later';

  @override
  String get membershipHistoryTitle => 'Membership history';

  @override
  String get membershipAdd => 'Add membership';

  @override
  String get membershipAddFirst => 'Add first membership';

  @override
  String get membershipEdit => 'Edit membership';

  @override
  String get membershipRenew => 'Renew membership';

  @override
  String get membershipDelete => 'Delete';

  @override
  String get membershipDeleteTitle => 'Delete membership';

  @override
  String membershipDeleteConfirm(String gymName) {
    return 'Delete the membership for $gymName? This cannot be undone.';
  }

  @override
  String get membershipEmptyTitle => 'No memberships yet';

  @override
  String get membershipEmptyMessage =>
      'Add a paid gym membership to keep its validity close to your workout calendar.';

  @override
  String get membershipGymName => 'Gym name';

  @override
  String get membershipGymNameHint => 'e.g. Downtown Fitness';

  @override
  String get membershipStartDate => 'Purchase / start date';

  @override
  String get membershipDuration => 'Validity';

  @override
  String get membershipDurationOneMonth => '1 month';

  @override
  String get membershipDurationThreeMonths => '3 months';

  @override
  String get membershipDurationSixMonths => '6 months';

  @override
  String get membershipDurationTwelveMonths => '12 months';

  @override
  String membershipValidUntilValue(String date) {
    return 'Valid until $date';
  }

  @override
  String get membershipPrice => 'Price';

  @override
  String get membershipPriceHint => 'e.g. 150.00';

  @override
  String get membershipCurrency => 'Currency';

  @override
  String get membershipStatusUpcoming => 'Upcoming';

  @override
  String get membershipStatusExpired => 'Expired';

  @override
  String membershipDaysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'Expires today',
    );
    return '$_temp0';
  }

  @override
  String get membershipMoreActions => 'Membership actions';

  @override
  String get membershipCopyPromptTitle => 'Reuse your last membership details?';

  @override
  String get membershipCopyPromptMessage =>
      'Copy the gym, validity, price, and currency from your latest membership. The start date will reset to today.';

  @override
  String get membershipCopyLast => 'Copy last details';

  @override
  String get membershipStartFresh => 'Start fresh';

  @override
  String get membershipCreated => 'Membership added.';

  @override
  String get membershipUpdated => 'Membership updated.';

  @override
  String get membershipDeleted => 'Membership deleted.';

  @override
  String get membershipCalendarExpiredTitle => 'Membership expired';

  @override
  String membershipCalendarExpiredMessage(String gymName, String date) {
    return '$gymName expired on $date. Add the new paid period when you renew.';
  }

  @override
  String get membershipCalendarMissingTitle => 'No membership recorded';

  @override
  String get membershipCalendarMissingMessage =>
      'Add one to track its validity alongside your workouts.';

  @override
  String get membershipCalendarDismiss => 'Dismiss membership reminder';

  @override
  String get healthInsightsCompareVsPopulation => 'People like you';

  @override
  String get healthInsightsCompareVsPastSelf => 'Past you';

  @override
  String get healthInsightsWeight => 'Weight';

  @override
  String get healthInsightsLeanMass => 'Lean mass';

  @override
  String get healthInsightsBodyFat => 'Body fat';

  @override
  String get healthInsightsHeight => 'Height';

  @override
  String healthInsightsAsOf(String date) {
    return 'As of $date';
  }

  @override
  String get healthInsightsErrorMessage =>
      'Could not load your Health Insights.';

  @override
  String get healthInsightsNoDataTitle => 'Not enough data yet';

  @override
  String get healthInsightsNoDataMessage =>
      'Keep wearing your Apple Watch — this card will appear once there\'s enough history.';

  @override
  String get healthInsightsIncompleteProfileMessage =>
      'Add your sex and date of birth to unlock this comparison.';

  @override
  String get healthInsightsInfoButtonTooltip => 'What does this mean?';

  @override
  String get healthInsightsCloseAction => 'Got it';

  @override
  String get healthInsightsDisclaimer =>
      'Wellness estimates only — not medical advice.';

  @override
  String get healthInsightsLoadErrorMessage =>
      'Could not load your Health Insights. Please try again.';

  @override
  String get healthInsightsBodyCompositionTitle => 'Body Recomposition';

  @override
  String get healthInsightsBodyCompositionInfo =>
      'Tracks your weight and lean body mass together so a scale-weight change doesn\'t tell half the story. Apple Health shows weight alone — this card shows whether a change is fat, muscle, or both, and (with your sex) roughly how your body-fat % compares to other adults.';

  @override
  String get healthInsightsDirectionCutting => 'Cutting — losing fat';

  @override
  String get healthInsightsDirectionBulking => 'Bulking — gaining weight';

  @override
  String get healthInsightsDirectionRecomposition =>
      'Recomposition — fat down, muscle up';

  @override
  String get healthInsightsDirectionStable => 'Stable';

  @override
  String get healthInsightsDirectionInsufficientData => 'Not enough data yet';

  @override
  String get healthInsightsCardioFitnessTitle => 'Weight-Adjusted VO2Max';

  @override
  String get healthInsightsCardioFitnessInfo =>
      'Apple reports VO2Max per kilogram of bodyweight, so it moves whenever your weight does — even if your aerobic fitness hasn\'t changed. This card rescales your current reading to your comparison weight so you can tell a real fitness change from a bodyweight-driven one.';

  @override
  String healthInsightsVo2MaxAtCompareWeight(String date, String value) {
    return 'At your $date weight, this reading would be about $value';
  }

  @override
  String get healthInsightsMifflinStJeor => 'Mifflin-St Jeor';

  @override
  String get healthInsightsCunningham => 'Cunningham (lean mass)';

  @override
  String get healthInsightsWatchBasalAvg => 'Watch resting avg';

  @override
  String get healthInsightsWatchActiveAvg => 'Watch active avg';

  @override
  String get healthInsightsTotalDailyEnergy => 'Estimated total daily energy';
}
