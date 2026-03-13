import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ro.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ro'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Gym Tracker'**
  String get appTitle;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLoginTitle;

  /// No description provided for @authLoginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get authLoginWelcomeTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to track your gym attendance'**
  String get authLoginSubtitle;

  /// No description provided for @authLoginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authLoginSignUp;

  /// No description provided for @authLoginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authLoginEmail;

  /// No description provided for @authLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authLoginPassword;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLoginButton;

  /// No description provided for @authLoginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authLoginNoAccount;

  /// No description provided for @authLoginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authLoginForgotPassword;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get authRegisterDisplayName;

  /// No description provided for @authRegisterEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authRegisterEmail;

  /// No description provided for @authRegisterPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authRegisterPassword;

  /// No description provided for @authRegisterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authRegisterConfirmPassword;

  /// No description provided for @authRegisterButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authRegisterButton;

  /// No description provided for @authRegisterHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authRegisterHaveAccount;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your gym attendance today'**
  String get authRegisterSubtitle;

  /// No description provided for @authRegisterSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authRegisterSignIn;

  /// No description provided for @authRegisterSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account Created!'**
  String get authRegisterSuccess;

  /// No description provided for @authRegisterSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to verify your account before signing in.'**
  String get authRegisterSuccessMessage;

  /// No description provided for @authRegisterGoToLogin.
  ///
  /// In en, this message translates to:
  /// **'Go to Sign In'**
  String get authRegisterGoToLogin;

  /// No description provided for @authPasswordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get authPasswordStrengthWeak;

  /// No description provided for @authPasswordStrengthFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get authPasswordStrengthFair;

  /// No description provided for @authPasswordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get authPasswordStrengthStrong;

  /// No description provided for @authPasswordReqLength.
  ///
  /// In en, this message translates to:
  /// **'8+ characters'**
  String get authPasswordReqLength;

  /// No description provided for @authPasswordReqUppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase'**
  String get authPasswordReqUppercase;

  /// No description provided for @authPasswordReqLowercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase'**
  String get authPasswordReqLowercase;

  /// No description provided for @authPasswordReqNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get authPasswordReqNumber;

  /// No description provided for @authPasswordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords match'**
  String get authPasswordsMatch;

  /// No description provided for @authPasswordsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get authPasswordsNoMatch;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a reset link'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authForgotPasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Check Your Inbox'**
  String get authForgotPasswordSuccessTitle;

  /// No description provided for @authForgotPasswordEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authForgotPasswordEmail;

  /// No description provided for @authForgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Email'**
  String get authForgotPasswordButton;

  /// No description provided for @authForgotPasswordBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authForgotPasswordBack;

  /// No description provided for @authForgotPasswordSent.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent. Check your inbox.'**
  String get authForgotPasswordSent;

  /// No description provided for @authEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before logging in.'**
  String get authEmailNotVerified;

  /// No description provided for @authVerificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent.'**
  String get authVerificationEmailSent;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get authSignOut;

  /// No description provided for @authEmailVerificationHandled.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully.'**
  String get authEmailVerificationHandled;

  /// No description provided for @authActionVerifyingEmail.
  ///
  /// In en, this message translates to:
  /// **'Verifying your email...'**
  String get authActionVerifyingEmail;

  /// No description provided for @authActionValidatingLink.
  ///
  /// In en, this message translates to:
  /// **'Validating reset link...'**
  String get authActionValidatingLink;

  /// No description provided for @authActionEmailVerifiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Verified!'**
  String get authActionEmailVerifiedTitle;

  /// No description provided for @authActionEmailVerifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your email has been verified. You can now sign in.'**
  String get authActionEmailVerifiedMessage;

  /// No description provided for @authActionSetNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get authActionSetNewPasswordTitle;

  /// No description provided for @authActionNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get authActionNewPassword;

  /// No description provided for @authActionResetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authActionResetPasswordButton;

  /// No description provided for @authActionPasswordResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Reset!'**
  String get authActionPasswordResetTitle;

  /// No description provided for @authActionPasswordResetMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset. You can now sign in with your new password.'**
  String get authActionPasswordResetMessage;

  /// No description provided for @authActionRequestNewLink.
  ///
  /// In en, this message translates to:
  /// **'Request New Link'**
  String get authActionRequestNewLink;

  /// No description provided for @authActionBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get authActionBackToSignIn;

  /// No description provided for @errorsInvalidActionCode.
  ///
  /// In en, this message translates to:
  /// **'This link has expired or has already been used. Please request a new one.'**
  String get errorsInvalidActionCode;

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get navHealth;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get calendarMonthly;

  /// No description provided for @calendarYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get calendarYearly;

  /// No description provided for @calendarMarkAttended.
  ///
  /// In en, this message translates to:
  /// **'Mark as attended'**
  String get calendarMarkAttended;

  /// No description provided for @calendarWentToGym.
  ///
  /// In en, this message translates to:
  /// **'Went to gym ✓'**
  String get calendarWentToGym;

  /// No description provided for @calendarSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get calendarSave;

  /// No description provided for @calendarClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get calendarClear;

  /// No description provided for @calendarAddSupplement.
  ///
  /// In en, this message translates to:
  /// **'Add supplement'**
  String get calendarAddSupplement;

  /// No description provided for @calendarWorkoutTab.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get calendarWorkoutTab;

  /// No description provided for @calendarHealthTab.
  ///
  /// In en, this message translates to:
  /// **'Health 💊'**
  String get calendarHealthTab;

  /// No description provided for @calendarNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get calendarNotes;

  /// No description provided for @calendarDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get calendarDurationMinutes;

  /// No description provided for @calendarTrainingType.
  ///
  /// In en, this message translates to:
  /// **'Training type'**
  String get calendarTrainingType;

  /// No description provided for @calendarNoType.
  ///
  /// In en, this message translates to:
  /// **'No type'**
  String get calendarNoType;

  /// No description provided for @calendarNoHealthLogs.
  ///
  /// In en, this message translates to:
  /// **'No supplements logged for this day.'**
  String get calendarNoHealthLogs;

  /// No description provided for @calendarSelectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select a product'**
  String get calendarSelectProduct;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// No description provided for @statsAttendances.
  ///
  /// In en, this message translates to:
  /// **'Attendances'**
  String get statsAttendances;

  /// No description provided for @statsWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get statsWorkouts;

  /// No description provided for @statsDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get statsDuration;

  /// No description provided for @statsHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get statsHealth;

  /// No description provided for @statsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get statsThisMonth;

  /// No description provided for @statsThisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get statsThisYear;

  /// No description provided for @statsAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get statsAllTime;

  /// No description provided for @statsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak 🔥'**
  String get statsCurrentStreak;

  /// No description provided for @statsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak 🏆'**
  String get statsBestStreak;

  /// No description provided for @statsFavoriteDay.
  ///
  /// In en, this message translates to:
  /// **'Favorite Day 📅'**
  String get statsFavoriteDay;

  /// No description provided for @statsStreak0.
  ///
  /// In en, this message translates to:
  /// **'Start your journey!'**
  String get statsStreak0;

  /// No description provided for @statsStreak1.
  ///
  /// In en, this message translates to:
  /// **'First week down!'**
  String get statsStreak1;

  /// No description provided for @statsAvgThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Avg This Month'**
  String get statsAvgThisMonth;

  /// No description provided for @statsAvgThisYear.
  ///
  /// In en, this message translates to:
  /// **'Avg This Year'**
  String get statsAvgThisYear;

  /// No description provided for @statsUntrackedCount.
  ///
  /// In en, this message translates to:
  /// **'Untracked'**
  String get statsUntrackedCount;

  /// No description provided for @statsMinutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get statsMinutes;

  /// No description provided for @statsTotalLogs.
  ///
  /// In en, this message translates to:
  /// **'Total Logs'**
  String get statsTotalLogs;

  /// No description provided for @statsMostUsed.
  ///
  /// In en, this message translates to:
  /// **'Most Used'**
  String get statsMostUsed;

  /// No description provided for @statsTotalTracked.
  ///
  /// In en, this message translates to:
  /// **'Total Tracked'**
  String get statsTotalTracked;

  /// No description provided for @monthsJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthsJanuary;

  /// No description provided for @monthsFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthsFebruary;

  /// No description provided for @monthsMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthsMarch;

  /// No description provided for @monthsApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthsApril;

  /// No description provided for @monthsMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthsMay;

  /// No description provided for @monthsJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthsJune;

  /// No description provided for @monthsJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthsJuly;

  /// No description provided for @monthsAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthsAugust;

  /// No description provided for @monthsSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthsSeptember;

  /// No description provided for @monthsOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthsOctober;

  /// No description provided for @monthsNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthsNovember;

  /// No description provided for @monthsDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthsDecember;

  /// No description provided for @weekdaysMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdaysMonday;

  /// No description provided for @weekdaysTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdaysTuesday;

  /// No description provided for @weekdaysWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdaysWednesday;

  /// No description provided for @weekdaysThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdaysThursday;

  /// No description provided for @weekdaysFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdaysFriday;

  /// No description provided for @weekdaysSaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaysSaturday;

  /// No description provided for @weekdaysSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaysSunday;

  /// No description provided for @weekdaysMiniMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdaysMiniMon;

  /// No description provided for @weekdaysMiniTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdaysMiniTue;

  /// No description provided for @weekdaysMiniWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdaysMiniWed;

  /// No description provided for @weekdaysMiniThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdaysMiniThu;

  /// No description provided for @weekdaysMiniFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdaysMiniFri;

  /// No description provided for @weekdaysMiniSat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaysMiniSat;

  /// No description provided for @weekdaysMiniSun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaysMiniSun;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profileEmailVerified;

  /// No description provided for @profileManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get profileManage;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileWorkoutTypes.
  ///
  /// In en, this message translates to:
  /// **'Workout Types'**
  String get profileWorkoutTypes;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @workoutTypesTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Types'**
  String get workoutTypesTitle;

  /// No description provided for @workoutTypesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Type'**
  String get workoutTypesAdd;

  /// No description provided for @workoutTypesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get workoutTypesSave;

  /// No description provided for @workoutTypesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get workoutTypesDelete;

  /// No description provided for @workoutTypesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this workout type?'**
  String get workoutTypesDeleteConfirm;

  /// No description provided for @workoutTypesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get workoutTypesName;

  /// No description provided for @workoutTypesNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Strength Training'**
  String get workoutTypesNamePlaceholder;

  /// No description provided for @workoutTypesIcon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get workoutTypesIcon;

  /// No description provided for @workoutTypesColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get workoutTypesColor;

  /// No description provided for @workoutTypesCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get workoutTypesCreate;

  /// No description provided for @workoutTypesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get workoutTypesCancel;

  /// No description provided for @workoutTypesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No workout types yet.\nTap + to add your first type.'**
  String get workoutTypesEmpty;

  /// No description provided for @workoutTypesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No workout types yet'**
  String get workoutTypesEmptyTitle;

  /// No description provided for @workoutTypesEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first workout type to organize sessions.'**
  String get workoutTypesEmptyDescription;

  /// No description provided for @workoutTypesCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create First Type'**
  String get workoutTypesCreateFirst;

  /// No description provided for @workoutTypesCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Workout Type'**
  String get workoutTypesCreateTitle;

  /// No description provided for @workoutTypesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Type'**
  String get workoutTypesEditTitle;

  /// No description provided for @workoutTypesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete workout type'**
  String get workoutTypesDeleteTitle;

  /// No description provided for @workoutTypesDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get workoutTypesDeleteWarning;

  /// No description provided for @workoutTypesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading workout types...'**
  String get workoutTypesLoading;

  /// No description provided for @workoutTypesPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get workoutTypesPreview;

  /// No description provided for @workoutTypesPreviewName.
  ///
  /// In en, this message translates to:
  /// **'Workout Type'**
  String get workoutTypesPreviewName;

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthTitle;

  /// No description provided for @healthToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get healthToday;

  /// No description provided for @healthMySupplements.
  ///
  /// In en, this message translates to:
  /// **'My Supplements'**
  String get healthMySupplements;

  /// No description provided for @healthAllSupplements.
  ///
  /// In en, this message translates to:
  /// **'All Supplements'**
  String get healthAllSupplements;

  /// No description provided for @healthProductName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get healthProductName;

  /// No description provided for @healthBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get healthBrand;

  /// No description provided for @healthIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get healthIngredients;

  /// No description provided for @healthServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get healthServings;

  /// No description provided for @healthAddSupplement.
  ///
  /// In en, this message translates to:
  /// **'Add Supplement'**
  String get healthAddSupplement;

  /// No description provided for @healthLogToday.
  ///
  /// In en, this message translates to:
  /// **'Log Today'**
  String get healthLogToday;

  /// No description provided for @healthSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get healthSave;

  /// No description provided for @healthDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get healthDelete;

  /// No description provided for @healthSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name or brand...'**
  String get healthSearchPlaceholder;

  /// No description provided for @healthServingsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Servings per day'**
  String get healthServingsPerDay;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageRo.
  ///
  /// In en, this message translates to:
  /// **'Romanian'**
  String get settingsLanguageRo;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get settingsCurrentPassword;

  /// No description provided for @settingsNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get settingsNewPassword;

  /// No description provided for @settingsConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get settingsConfirmPassword;

  /// No description provided for @settingsSavePassword.
  ///
  /// In en, this message translates to:
  /// **'Save Password'**
  String get settingsSavePassword;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settingsAppVersion;

  /// No description provided for @settingsBuiltWith.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter + Firebase'**
  String get settingsBuiltWith;

  /// No description provided for @settingsDataMigration.
  ///
  /// In en, this message translates to:
  /// **'Data Migration'**
  String get settingsDataMigration;

  /// No description provided for @settingsRunMigration.
  ///
  /// In en, this message translates to:
  /// **'Run Migration'**
  String get settingsRunMigration;

  /// No description provided for @errorsInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get errorsInvalidCredentials;

  /// No description provided for @errorsEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get errorsEmailAlreadyInUse;

  /// No description provided for @errorsEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before logging in.'**
  String get errorsEmailNotVerified;

  /// No description provided for @errorsWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak.'**
  String get errorsWeakPassword;

  /// No description provided for @errorsNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorsNetworkError;

  /// No description provided for @errorsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorsUnknown;

  /// No description provided for @errorsFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get errorsFieldRequired;

  /// No description provided for @errorsPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorsPasswordMismatch;

  /// No description provided for @errorsPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get errorsPasswordTooShort;

  /// No description provided for @settingsPasswordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get settingsPasswordChangedSuccess;
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
      <String>['en', 'ro'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ro':
      return AppLocalizationsRo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
