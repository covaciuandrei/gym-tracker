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
  String get authActionVerifyingEmail => 'Verifying your email...';

  @override
  String get authActionValidatingLink => 'Validating reset link...';

  @override
  String get authActionEmailVerifiedTitle => 'Email Verified!';

  @override
  String get authActionEmailVerifiedMessage =>
      'Your email has been verified. You can now sign in.';

  @override
  String get authActionSetNewPasswordTitle => 'Set New Password';

  @override
  String get authActionNewPassword => 'New Password';

  @override
  String get authActionResetPasswordButton => 'Reset Password';

  @override
  String get authActionPasswordResetTitle => 'Password Reset!';

  @override
  String get authActionPasswordResetMessage =>
      'Your password has been reset. You can now sign in with your new password.';

  @override
  String get authActionRequestNewLink => 'Request New Link';

  @override
  String get authActionBackToSignIn => 'Back to Sign In';

  @override
  String get errorsInvalidActionCode =>
      'This link has expired or has already been used. Please request a new one.';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navStats => 'Stats';

  @override
  String get navHealth => 'Health';

  @override
  String get navProfile => 'Profile';

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
  String get settingsPasswordChangedSuccess => 'Password changed successfully.';

  @override
  String authActionCreateNewPasswordFor(String email) {
    return 'Create a new password for $email';
  }

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
}
