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

  /// No description provided for @authRegisterContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get authRegisterContinue;

  /// No description provided for @authRegisterSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get authRegisterSkip;

  /// No description provided for @authPersonalDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Personalize your experience'**
  String get authPersonalDetailsTitle;

  /// No description provided for @authPersonalDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional — helps tailor future health insights. You can skip this and add it later.'**
  String get authPersonalDetailsSubtitle;

  /// No description provided for @authPersonalDetailsSex.
  ///
  /// In en, this message translates to:
  /// **'Sex'**
  String get authPersonalDetailsSex;

  /// No description provided for @authPersonalDetailsSexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get authPersonalDetailsSexMale;

  /// No description provided for @authPersonalDetailsSexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get authPersonalDetailsSexFemale;

  /// No description provided for @authPersonalDetailsBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get authPersonalDetailsBirthDate;

  /// No description provided for @authPersonalDetailsBirthDateHint.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get authPersonalDetailsBirthDateHint;

  /// No description provided for @authPersonalDetailsHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get authPersonalDetailsHeight;

  /// No description provided for @authPersonalDetailsWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get authPersonalDetailsWeight;

  /// No description provided for @authPersonalDetailsBodyType.
  ///
  /// In en, this message translates to:
  /// **'Body type'**
  String get authPersonalDetailsBodyType;

  /// No description provided for @authPersonalDetailsBodyTypeLean.
  ///
  /// In en, this message translates to:
  /// **'Lean'**
  String get authPersonalDetailsBodyTypeLean;

  /// No description provided for @authPersonalDetailsBodyTypeAthletic.
  ///
  /// In en, this message translates to:
  /// **'Athletic'**
  String get authPersonalDetailsBodyTypeAthletic;

  /// No description provided for @authPersonalDetailsBodyTypeAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get authPersonalDetailsBodyTypeAverage;

  /// No description provided for @authPersonalDetailsBodyTypeSkinnyFat.
  ///
  /// In en, this message translates to:
  /// **'Skinny fat'**
  String get authPersonalDetailsBodyTypeSkinnyFat;

  /// No description provided for @authPersonalDetailsBodyTypeHigherBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Higher body fat'**
  String get authPersonalDetailsBodyTypeHigherBodyFat;

  /// No description provided for @authPersonalDetailsBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get authPersonalDetailsBack;

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

  /// No description provided for @navCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// No description provided for @navWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get navWorkouts;

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

  /// No description provided for @workoutsTitle.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workoutsTitle;

  /// No description provided for @workoutsManageTypes.
  ///
  /// In en, this message translates to:
  /// **'Manage workout types'**
  String get workoutsManageTypes;

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
  /// **'Went to gym'**
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
  /// **'Health'**
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

  /// No description provided for @calendarRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get calendarRemove;

  /// No description provided for @calendarCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get calendarCancel;

  /// No description provided for @calendarDidYouGoToGym.
  ///
  /// In en, this message translates to:
  /// **'Did you go to the gym?'**
  String get calendarDidYouGoToGym;

  /// No description provided for @calendarSelectTypePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'-- Select type --'**
  String get calendarSelectTypePlaceholder;

  /// No description provided for @calendarSelectWorkoutTypeOptional.
  ///
  /// In en, this message translates to:
  /// **'Select Workout Type (optional)'**
  String get calendarSelectWorkoutTypeOptional;

  /// No description provided for @calendarDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration:'**
  String get calendarDurationLabel;

  /// No description provided for @calendarDurationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 60'**
  String get calendarDurationHint;

  /// No description provided for @calendarDurationOptional.
  ///
  /// In en, this message translates to:
  /// **'Duration (optional)'**
  String get calendarDurationOptional;

  /// No description provided for @calendarAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get calendarAdd;

  /// No description provided for @calendarSupplementsTaken.
  ///
  /// In en, this message translates to:
  /// **'Supplements taken'**
  String get calendarSupplementsTaken;

  /// No description provided for @calendarNoSupplementProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No supplement products available.'**
  String get calendarNoSupplementProductsAvailable;

  /// No description provided for @calendarDidYouTakeAnySupplements.
  ///
  /// In en, this message translates to:
  /// **'Did you take any supplements?'**
  String get calendarDidYouTakeAnySupplements;

  /// No description provided for @calendarAddSupplementLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Supplement:'**
  String get calendarAddSupplementLabel;

  /// No description provided for @calendarPleaseSelectSupplement.
  ///
  /// In en, this message translates to:
  /// **'Please select a supplement'**
  String get calendarPleaseSelectSupplement;

  /// No description provided for @calendarSelectSupplementHint.
  ///
  /// In en, this message translates to:
  /// **'Select a supplement...'**
  String get calendarSelectSupplementHint;

  /// No description provided for @calendarDurationMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} min} other{{count} min}}'**
  String calendarDurationMinutesShort(int count);

  /// No description provided for @calendarDurationHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} h} other{{count} h}}'**
  String calendarDurationHoursShort(int count);

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

  /// No description provided for @statsWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get statsWorkout;

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
  /// **'Current Streak'**
  String get statsCurrentStreak;

  /// No description provided for @statsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get statsBestStreak;

  /// No description provided for @statsFavoriteDay.
  ///
  /// In en, this message translates to:
  /// **'Fav Day'**
  String get statsFavoriteDay;

  /// No description provided for @statsConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get statsConsistency;

  /// No description provided for @statsConsistencyWithoutIcon.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get statsConsistencyWithoutIcon;

  /// No description provided for @statsUniqueSupplements.
  ///
  /// In en, this message translates to:
  /// **'Unique Supplements'**
  String get statsUniqueSupplements;

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

  /// No description provided for @statsStreak2.
  ///
  /// In en, this message translates to:
  /// **'Building momentum!'**
  String get statsStreak2;

  /// No description provided for @statsStreak4.
  ///
  /// In en, this message translates to:
  /// **'One month strong!'**
  String get statsStreak4;

  /// No description provided for @statsStreak8.
  ///
  /// In en, this message translates to:
  /// **'You\'re on fire!'**
  String get statsStreak8;

  /// No description provided for @statsStreak12.
  ///
  /// In en, this message translates to:
  /// **'Consistency king!'**
  String get statsStreak12;

  /// No description provided for @statsStreak20.
  ///
  /// In en, this message translates to:
  /// **'Unstoppable!'**
  String get statsStreak20;

  /// No description provided for @statsStreak30.
  ///
  /// In en, this message translates to:
  /// **'Half-year beast!'**
  String get statsStreak30;

  /// No description provided for @statsStreak40.
  ///
  /// In en, this message translates to:
  /// **'Legend mode!'**
  String get statsStreak40;

  /// No description provided for @statsStreak52.
  ///
  /// In en, this message translates to:
  /// **'Almost a full year!'**
  String get statsStreak52;

  /// No description provided for @statsStreakMax.
  ///
  /// In en, this message translates to:
  /// **'Absolute GOAT!'**
  String get statsStreakMax;

  /// No description provided for @statsTapToSeeDates.
  ///
  /// In en, this message translates to:
  /// **'Tap to see dates'**
  String get statsTapToSeeDates;

  /// No description provided for @statsNoStreakYet.
  ///
  /// In en, this message translates to:
  /// **'No streak yet'**
  String get statsNoStreakYet;

  /// No description provided for @statsDaysYouHitGym.
  ///
  /// In en, this message translates to:
  /// **'Days You Hit the Gym'**
  String get statsDaysYouHitGym;

  /// No description provided for @statsFavoriteDayLegend.
  ///
  /// In en, this message translates to:
  /// **'Favorite day'**
  String get statsFavoriteDayLegend;

  /// No description provided for @statsFavoriteDaysLegend.
  ///
  /// In en, this message translates to:
  /// **'Favorite days'**
  String get statsFavoriteDaysLegend;

  /// No description provided for @statsMonthlyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Monthly Breakdown'**
  String get statsMonthlyBreakdown;

  /// No description provided for @statsAverageDurationLegend.
  ///
  /// In en, this message translates to:
  /// **'Average duration'**
  String get statsAverageDurationLegend;

  /// No description provided for @statsOfWeeksThisYear.
  ///
  /// In en, this message translates to:
  /// **'of weeks this year'**
  String get statsOfWeeksThisYear;

  /// No description provided for @statsXThisYear.
  ///
  /// In en, this message translates to:
  /// **'{count}x this year'**
  String statsXThisYear(Object count);

  /// No description provided for @statsWeekCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} week} other{{count} weeks}}'**
  String statsWeekCount(int count);

  /// No description provided for @statsPercentOfWeeksThisYear.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of weeks this year'**
  String statsPercentOfWeeksThisYear(int percent);

  /// No description provided for @statsDifferentProducts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 different product} other{{count} different products}}'**
  String statsDifferentProducts(int count);

  /// No description provided for @statsCountTimes.
  ///
  /// In en, this message translates to:
  /// **'{count}x'**
  String statsCountTimes(int count);

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

  /// No description provided for @profileMembershipHistory.
  ///
  /// In en, this message translates to:
  /// **'Membership history'**
  String get profileMembershipHistory;

  /// No description provided for @profileMembershipHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track purchases and validity'**
  String get profileMembershipHistorySubtitle;

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

  /// No description provided for @healthInsightsEntryTooltip.
  ///
  /// In en, this message translates to:
  /// **'Health Insights'**
  String get healthInsightsEntryTooltip;

  /// No description provided for @healthInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Insights'**
  String get healthInsightsTitle;

  /// No description provided for @healthInsightsInfoClose.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get healthInsightsInfoClose;

  /// No description provided for @healthInsightsNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet.'**
  String get healthInsightsNoData;

  /// No description provided for @healthInsightsChartPeriod.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String healthInsightsChartPeriod(String start, String end);

  /// No description provided for @healthInsightsOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Physical Overview'**
  String get healthInsightsOverviewTitle;

  /// No description provided for @healthInsightsOverviewInfo.
  ///
  /// In en, this message translates to:
  /// **'Your latest weight, lean mass, and body-fat % from Apple Health, alongside a comparison you choose: people who share your age, sex, and height, or an earlier version of yourself.'**
  String get healthInsightsOverviewInfo;

  /// No description provided for @healthInsightsOverviewWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get healthInsightsOverviewWeight;

  /// No description provided for @healthInsightsOverviewLeanMass.
  ///
  /// In en, this message translates to:
  /// **'Lean mass'**
  String get healthInsightsOverviewLeanMass;

  /// No description provided for @healthInsightsOverviewBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get healthInsightsOverviewBodyFat;

  /// No description provided for @healthInsightsOverviewAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get healthInsightsOverviewAge;

  /// No description provided for @healthInsightsOverviewHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get healthInsightsOverviewHeight;

  /// No description provided for @healthInsightsOverviewStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get healthInsightsOverviewStress;

  /// No description provided for @healthInsightsStressBandLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get healthInsightsStressBandLow;

  /// No description provided for @healthInsightsStressBandTypical.
  ///
  /// In en, this message translates to:
  /// **'Typical'**
  String get healthInsightsStressBandTypical;

  /// No description provided for @healthInsightsStressBandElevated.
  ///
  /// In en, this message translates to:
  /// **'Elevated'**
  String get healthInsightsStressBandElevated;

  /// No description provided for @healthInsightsStressBandHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get healthInsightsStressBandHigh;

  /// No description provided for @healthInsightsOverviewCompareCta.
  ///
  /// In en, this message translates to:
  /// **'Tap to compare'**
  String get healthInsightsOverviewCompareCta;

  /// No description provided for @healthInsightsComparePopulation.
  ///
  /// In en, this message translates to:
  /// **'Population'**
  String get healthInsightsComparePopulation;

  /// No description provided for @healthInsightsCompareSelf.
  ///
  /// In en, this message translates to:
  /// **'Past you'**
  String get healthInsightsCompareSelf;

  /// No description provided for @healthInsightsWindow3m.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get healthInsightsWindow3m;

  /// No description provided for @healthInsightsWindow6m.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get healthInsightsWindow6m;

  /// No description provided for @healthInsightsWindow1y.
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get healthInsightsWindow1y;

  /// No description provided for @healthInsightsWindow2y.
  ///
  /// In en, this message translates to:
  /// **'2 years'**
  String get healthInsightsWindow2y;

  /// No description provided for @healthInsightsBodyCompTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Recomposition'**
  String get healthInsightsBodyCompTitle;

  /// No description provided for @healthInsightsBodyCompInfo.
  ///
  /// In en, this message translates to:
  /// **'Tracks whether a recent weight change came from fat or muscle, using your weight and lean-body-mass readings. A clean cut loses fat while keeping lean mass; recomposition gains muscle while losing fat at a similar weight.'**
  String get healthInsightsBodyCompInfo;

  /// No description provided for @healthInsightsBodyCompCutting.
  ///
  /// In en, this message translates to:
  /// **'Cutting — losing fat, keeping muscle'**
  String get healthInsightsBodyCompCutting;

  /// No description provided for @healthInsightsBodyCompBulking.
  ///
  /// In en, this message translates to:
  /// **'Bulking — gaining weight and muscle'**
  String get healthInsightsBodyCompBulking;

  /// No description provided for @healthInsightsBodyCompRecomposition.
  ///
  /// In en, this message translates to:
  /// **'Recomposition — gaining muscle, losing fat'**
  String get healthInsightsBodyCompRecomposition;

  /// No description provided for @healthInsightsBodyCompStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get healthInsightsBodyCompStable;

  /// No description provided for @healthInsightsBodyCompWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get healthInsightsBodyCompWeightLabel;

  /// No description provided for @healthInsightsBodyCompFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get healthInsightsBodyCompFatLabel;

  /// No description provided for @healthInsightsVo2Title.
  ///
  /// In en, this message translates to:
  /// **'Cardio Fitness (VO2Max)'**
  String get healthInsightsVo2Title;

  /// No description provided for @healthInsightsVo2Info.
  ///
  /// In en, this message translates to:
  /// **'VO2Max measures how efficiently your body uses oxygen during exercise — a core fitness marker. Because Apple reports it per kilogram of body weight, this card also shows what your reading would be at a past weight, so a real fitness change isn\'t confused with a bodyweight change.'**
  String get healthInsightsVo2Info;

  /// No description provided for @healthInsightsVo2Current.
  ///
  /// In en, this message translates to:
  /// **'Current VO2Max'**
  String get healthInsightsVo2Current;

  /// No description provided for @healthInsightsVo2AtPastWeight.
  ///
  /// In en, this message translates to:
  /// **'At your past weight'**
  String get healthInsightsVo2AtPastWeight;

  /// No description provided for @healthInsightsHrrTitle.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate Recovery'**
  String get healthInsightsHrrTitle;

  /// No description provided for @healthInsightsHrrInfo.
  ///
  /// In en, this message translates to:
  /// **'How many beats per minute your heart rate drops in the first minute after exercise stops — a well-established marker of cardiovascular fitness and how well your nervous system recovers. Based on Cole et al. (New England Journal of Medicine, 1999): a drop of 12 bpm or less was linked to higher health risk in that study, so a bigger drop is generally better.'**
  String get healthInsightsHrrInfo;

  /// No description provided for @healthInsightsHrrBandLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery level'**
  String get healthInsightsHrrBandLabel;

  /// No description provided for @healthInsightsHrrBandLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get healthInsightsHrrBandLow;

  /// No description provided for @healthInsightsHrrBandFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get healthInsightsHrrBandFair;

  /// No description provided for @healthInsightsHrrBandGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get healthInsightsHrrBandGood;

  /// No description provided for @healthInsightsHrrBandExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get healthInsightsHrrBandExcellent;

  /// No description provided for @healthInsightsMetabolicTitle.
  ///
  /// In en, this message translates to:
  /// **'Resting Energy & TDEE'**
  String get healthInsightsMetabolicTitle;

  /// No description provided for @healthInsightsMetabolicInfo.
  ///
  /// In en, this message translates to:
  /// **'Two personalized resting-metabolic-rate estimates — Mifflin-St Jeor (age/sex/height/weight) and, when you have a recent lean-body-mass reading, the Cunningham equation, generally considered more accurate for people who track body composition — shown next to Apple Watch\'s own daily averages for reference.'**
  String get healthInsightsMetabolicInfo;

  /// No description provided for @healthInsightsMetabolicTdee.
  ///
  /// In en, this message translates to:
  /// **'Estimated total daily burn'**
  String get healthInsightsMetabolicTdee;

  /// No description provided for @healthInsightsMetabolicCunningham.
  ///
  /// In en, this message translates to:
  /// **'Resting rate (lean-mass based)'**
  String get healthInsightsMetabolicCunningham;

  /// No description provided for @healthInsightsMetabolicMifflin.
  ///
  /// In en, this message translates to:
  /// **'Resting rate (estimated)'**
  String get healthInsightsMetabolicMifflin;

  /// No description provided for @healthInsightsMetabolicWatch.
  ///
  /// In en, this message translates to:
  /// **'Apple Watch resting average'**
  String get healthInsightsMetabolicWatch;

  /// No description provided for @healthInsightsMetabolicActive.
  ///
  /// In en, this message translates to:
  /// **'Apple Watch active average'**
  String get healthInsightsMetabolicActive;

  /// No description provided for @healthInsightsPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'No Apple Health data'**
  String get healthInsightsPermissionDeniedTitle;

  /// No description provided for @healthInsightsPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Gym Tracker couldn\'t read any Apple Health data. If you haven\'t allowed access, open the Health app, tap your profile picture › Apps › Gym Tracker, turn the data on, then try again.'**
  String get healthInsightsPermissionDeniedMessage;

  /// No description provided for @healthInsightsPopulationCompareSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compared to an average adult in the {cohort} reference group, at your height.'**
  String healthInsightsPopulationCompareSubtitle(String cohort);

  /// No description provided for @healthInsightsPopulationCompareYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get healthInsightsPopulationCompareYou;

  /// No description provided for @healthInsightsPopulationCompareAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get healthInsightsPopulationCompareAverage;

  /// No description provided for @healthInsightsHrrReferenceCaption.
  ///
  /// In en, this message translates to:
  /// **'Healthy reference'**
  String get healthInsightsHrrReferenceCaption;

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

  /// No description provided for @healthProductCreated.
  ///
  /// In en, this message translates to:
  /// **'Supplement created.'**
  String get healthProductCreated;

  /// No description provided for @healthProductUpdated.
  ///
  /// In en, this message translates to:
  /// **'Supplement updated.'**
  String get healthProductUpdated;

  /// No description provided for @healthDeleteSupplementTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete supplement'**
  String get healthDeleteSupplementTitle;

  /// No description provided for @healthDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get healthDeleteWarning;

  /// No description provided for @healthDeleteLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete log'**
  String get healthDeleteLogTitle;

  /// No description provided for @healthDeleteLogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this supplement log?'**
  String get healthDeleteLogMessage;

  /// No description provided for @healthMySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search my supplements...'**
  String get healthMySearchHint;

  /// No description provided for @healthAllSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search all supplements...'**
  String get healthAllSearchHint;

  /// No description provided for @healthNoPersonalSupplements.
  ///
  /// In en, this message translates to:
  /// **'No personal supplements'**
  String get healthNoPersonalSupplements;

  /// No description provided for @healthNoPersonalSupplementsMessage.
  ///
  /// In en, this message translates to:
  /// **'You have not added any custom supplements yet.'**
  String get healthNoPersonalSupplementsMessage;

  /// No description provided for @healthNoSupplementsFound.
  ///
  /// In en, this message translates to:
  /// **'No supplements found'**
  String get healthNoSupplementsFound;

  /// No description provided for @healthNoSupplementsFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing the search term.'**
  String get healthNoSupplementsFoundMessage;

  /// No description provided for @healthNoSupplementsToday.
  ///
  /// In en, this message translates to:
  /// **'No supplements logged today'**
  String get healthNoSupplementsToday;

  /// No description provided for @healthNoSupplementsTodayMessage.
  ///
  /// In en, this message translates to:
  /// **'Start your day by logging your supplements.'**
  String get healthNoSupplementsTodayMessage;

  /// No description provided for @healthEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get healthEditAction;

  /// No description provided for @healthEditSupplement.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplement'**
  String get healthEditSupplement;

  /// No description provided for @healthIngredientName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get healthIngredientName;

  /// No description provided for @healthAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get healthAmount;

  /// No description provided for @healthNoIngredientsYet.
  ///
  /// In en, this message translates to:
  /// **'No ingredients added yet.'**
  String get healthNoIngredientsYet;

  /// No description provided for @healthUnknownProduct.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get healthUnknownProduct;

  /// No description provided for @healthServingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} serving} other{{count} servings}}'**
  String healthServingCount(num count);

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

  /// No description provided for @settingsActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get settingsActions;

  /// No description provided for @settingsLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegal;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacy;

  /// Required-consent sentence shown on the Register page. {terms} and {privacy} are replaced by the localized labels rendered as tappable links.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the {terms} and {privacy}.'**
  String legalConsentMessage(String terms, String privacy);

  /// No description provided for @legalConsentTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalConsentTermsLabel;

  /// No description provided for @legalConsentPrivacyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalConsentPrivacyLabel;

  /// No description provided for @legalConsentRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms of Service and Privacy Policy to continue.'**
  String get legalConsentRequired;

  /// No description provided for @authAgeConfirm.
  ///
  /// In en, this message translates to:
  /// **'I confirm I am at least 16 years old.'**
  String get authAgeConfirm;

  /// No description provided for @authAgeRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 16 years old to use this app.'**
  String get authAgeRequired;

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

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get settingsCurrency;

  /// No description provided for @settingsCurrencyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default currency updated.'**
  String get settingsCurrencyUpdated;

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

  /// No description provided for @settingsBuiltWithValue.
  ///
  /// In en, this message translates to:
  /// **'Flutter + Firebase'**
  String get settingsBuiltWithValue;

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

  /// No description provided for @errorsNumbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Please enter only numbers'**
  String get errorsNumbersOnly;

  /// No description provided for @errorsInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get errorsInvalidNumber;

  /// No description provided for @errorsPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a positive number'**
  String get errorsPositiveNumber;

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

  /// No description provided for @errorsHeightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a height between 50 and 260 cm.'**
  String get errorsHeightInvalid;

  /// No description provided for @errorsWeightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a weight between 20 and 400 kg.'**
  String get errorsWeightInvalid;

  /// No description provided for @settingsPasswordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get settingsPasswordChangedSuccess;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get settingsDeleteAccountTitle;

  /// No description provided for @settingsDeleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all your data (workouts, supplement logs, training types, and gym memberships). This action cannot be undone.'**
  String get settingsDeleteAccountMessage;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsDeleteAccountPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm'**
  String get settingsDeleteAccountPasswordHint;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @profileDefaultUserName.
  ///
  /// In en, this message translates to:
  /// **'Gym Tracker User'**
  String get profileDefaultUserName;

  /// No description provided for @globalTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get globalTryAgain;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Track Your Workouts'**
  String get onboardingTitle1;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Log every gym session and see your attendance at a glance.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Monitor Your Health'**
  String get onboardingTitle2;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Keep track of your supplements and daily nutrition.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Analyze Your Progress'**
  String get onboardingTitle3;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'View detailed stats, streaks, and monthly breakdowns.'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'A new version of Gym Tracker is required to continue.'**
  String get forceUpdateBody;

  /// No description provided for @forceUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get forceUpdateButton;

  /// No description provided for @forceUpdateCurrentVersion.
  ///
  /// In en, this message translates to:
  /// **'Your version'**
  String get forceUpdateCurrentVersion;

  /// No description provided for @forceUpdateRequiredVersion.
  ///
  /// In en, this message translates to:
  /// **'Required version'**
  String get forceUpdateRequiredVersion;

  /// No description provided for @maintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll be right back'**
  String get maintenanceTitle;

  /// No description provided for @maintenanceRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get maintenanceRetry;

  /// No description provided for @noConnectionTitle.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get noConnectionTitle;

  /// No description provided for @noConnectionBody.
  ///
  /// In en, this message translates to:
  /// **'Gym Tracker needs an internet connection to start. Please check your network and try again.'**
  String get noConnectionBody;

  /// No description provided for @noConnectionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get noConnectionRetry;

  /// No description provided for @bigUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'A big update is here'**
  String get bigUpdateTitle;

  /// No description provided for @bigUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available with major improvements. Update now to get the latest features.'**
  String bigUpdateBody(String version);

  /// No description provided for @bigUpdateAction.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get bigUpdateAction;

  /// No description provided for @bigUpdateLater.
  ///
  /// In en, this message translates to:
  /// **'Remind me later'**
  String get bigUpdateLater;

  /// No description provided for @membershipHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership history'**
  String get membershipHistoryTitle;

  /// No description provided for @membershipAdd.
  ///
  /// In en, this message translates to:
  /// **'Add membership'**
  String get membershipAdd;

  /// No description provided for @membershipAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add first membership'**
  String get membershipAddFirst;

  /// No description provided for @membershipEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit membership'**
  String get membershipEdit;

  /// No description provided for @membershipRenew.
  ///
  /// In en, this message translates to:
  /// **'Renew membership'**
  String get membershipRenew;

  /// No description provided for @membershipDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get membershipDelete;

  /// No description provided for @membershipDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete membership'**
  String get membershipDeleteTitle;

  /// No description provided for @membershipDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the membership for {gymName}? This cannot be undone.'**
  String membershipDeleteConfirm(String gymName);

  /// No description provided for @membershipEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No memberships yet'**
  String get membershipEmptyTitle;

  /// No description provided for @membershipEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a paid gym membership to keep its validity close to your workout calendar.'**
  String get membershipEmptyMessage;

  /// No description provided for @membershipGymName.
  ///
  /// In en, this message translates to:
  /// **'Gym name'**
  String get membershipGymName;

  /// No description provided for @membershipGymNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Downtown Fitness'**
  String get membershipGymNameHint;

  /// No description provided for @membershipStartDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase / start date'**
  String get membershipStartDate;

  /// No description provided for @membershipDuration.
  ///
  /// In en, this message translates to:
  /// **'Validity'**
  String get membershipDuration;

  /// No description provided for @membershipDurationOneMonth.
  ///
  /// In en, this message translates to:
  /// **'1 month'**
  String get membershipDurationOneMonth;

  /// No description provided for @membershipDurationThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 months'**
  String get membershipDurationThreeMonths;

  /// No description provided for @membershipDurationSixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 months'**
  String get membershipDurationSixMonths;

  /// No description provided for @membershipDurationTwelveMonths.
  ///
  /// In en, this message translates to:
  /// **'12 months'**
  String get membershipDurationTwelveMonths;

  /// No description provided for @membershipValidUntilValue.
  ///
  /// In en, this message translates to:
  /// **'Valid until {date}'**
  String membershipValidUntilValue(String date);

  /// No description provided for @membershipPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get membershipPrice;

  /// No description provided for @membershipPriceHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 150.00'**
  String get membershipPriceHint;

  /// No description provided for @membershipCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get membershipCurrency;

  /// No description provided for @membershipStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get membershipStatusUpcoming;

  /// No description provided for @membershipStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get membershipStatusExpired;

  /// No description provided for @membershipDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Expires today} =1{1 day left} other{{count} days left}}'**
  String membershipDaysRemaining(int count);

  /// No description provided for @membershipMoreActions.
  ///
  /// In en, this message translates to:
  /// **'Membership actions'**
  String get membershipMoreActions;

  /// No description provided for @membershipCopyPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Reuse your last membership details?'**
  String get membershipCopyPromptTitle;

  /// No description provided for @membershipCopyPromptMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy the gym, validity, price, and currency from your latest membership. The start date will reset to today.'**
  String get membershipCopyPromptMessage;

  /// No description provided for @membershipCopyLast.
  ///
  /// In en, this message translates to:
  /// **'Copy last details'**
  String get membershipCopyLast;

  /// No description provided for @membershipStartFresh.
  ///
  /// In en, this message translates to:
  /// **'Start fresh'**
  String get membershipStartFresh;

  /// No description provided for @membershipCreated.
  ///
  /// In en, this message translates to:
  /// **'Membership added.'**
  String get membershipCreated;

  /// No description provided for @membershipUpdated.
  ///
  /// In en, this message translates to:
  /// **'Membership updated.'**
  String get membershipUpdated;

  /// No description provided for @membershipDeleted.
  ///
  /// In en, this message translates to:
  /// **'Membership deleted.'**
  String get membershipDeleted;

  /// No description provided for @membershipCalendarExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Membership expired'**
  String get membershipCalendarExpiredTitle;

  /// No description provided for @membershipCalendarExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'{gymName} expired on {date}. Add the new paid period when you renew.'**
  String membershipCalendarExpiredMessage(String gymName, String date);

  /// No description provided for @membershipCalendarMissingTitle.
  ///
  /// In en, this message translates to:
  /// **'No membership recorded'**
  String get membershipCalendarMissingTitle;

  /// No description provided for @membershipCalendarMissingMessage.
  ///
  /// In en, this message translates to:
  /// **'Add one to track its validity alongside your workouts.'**
  String get membershipCalendarMissingMessage;

  /// No description provided for @membershipCalendarDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss membership reminder'**
  String get membershipCalendarDismiss;

  /// No description provided for @healthInsightsCompareVsPopulation.
  ///
  /// In en, this message translates to:
  /// **'People like you'**
  String get healthInsightsCompareVsPopulation;

  /// No description provided for @healthInsightsCompareVsPastSelf.
  ///
  /// In en, this message translates to:
  /// **'Past you'**
  String get healthInsightsCompareVsPastSelf;

  /// No description provided for @healthInsightsWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get healthInsightsWeight;

  /// No description provided for @healthInsightsLeanMass.
  ///
  /// In en, this message translates to:
  /// **'Lean mass'**
  String get healthInsightsLeanMass;

  /// No description provided for @healthInsightsBodyFat.
  ///
  /// In en, this message translates to:
  /// **'Body fat'**
  String get healthInsightsBodyFat;

  /// No description provided for @healthInsightsHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get healthInsightsHeight;

  /// No description provided for @healthInsightsAsOf.
  ///
  /// In en, this message translates to:
  /// **'As of {date}'**
  String healthInsightsAsOf(String date);

  /// No description provided for @healthInsightsErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not load your Health Insights.'**
  String get healthInsightsErrorMessage;

  /// No description provided for @healthInsightsNoDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get healthInsightsNoDataTitle;

  /// No description provided for @healthInsightsNoDataMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep wearing your Apple Watch — this card will appear once there\'s enough history.'**
  String get healthInsightsNoDataMessage;

  /// No description provided for @healthInsightsIncompleteProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Add your sex and date of birth to unlock this comparison.'**
  String get healthInsightsIncompleteProfileMessage;

  /// No description provided for @healthInsightsInfoButtonTooltip.
  ///
  /// In en, this message translates to:
  /// **'What does this mean?'**
  String get healthInsightsInfoButtonTooltip;

  /// No description provided for @healthInsightsCloseAction.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get healthInsightsCloseAction;

  /// No description provided for @healthInsightsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Wellness estimates only — not medical advice.'**
  String get healthInsightsDisclaimer;

  /// No description provided for @healthInsightsLoadErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not load your Health Insights. Please try again.'**
  String get healthInsightsLoadErrorMessage;

  /// No description provided for @healthInsightsBodyCompositionTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Recomposition'**
  String get healthInsightsBodyCompositionTitle;

  /// No description provided for @healthInsightsBodyCompositionInfo.
  ///
  /// In en, this message translates to:
  /// **'Tracks your weight and lean body mass together so a scale-weight change doesn\'t tell half the story. Apple Health shows weight alone — this card shows whether a change is fat, muscle, or both, and (with your sex) roughly how your body-fat % compares to other adults.'**
  String get healthInsightsBodyCompositionInfo;

  /// No description provided for @healthInsightsDirectionCutting.
  ///
  /// In en, this message translates to:
  /// **'Cutting — losing fat'**
  String get healthInsightsDirectionCutting;

  /// No description provided for @healthInsightsDirectionBulking.
  ///
  /// In en, this message translates to:
  /// **'Bulking — gaining weight'**
  String get healthInsightsDirectionBulking;

  /// No description provided for @healthInsightsDirectionRecomposition.
  ///
  /// In en, this message translates to:
  /// **'Recomposition — fat down, muscle up'**
  String get healthInsightsDirectionRecomposition;

  /// No description provided for @healthInsightsDirectionStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get healthInsightsDirectionStable;

  /// No description provided for @healthInsightsDirectionInsufficientData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get healthInsightsDirectionInsufficientData;

  /// No description provided for @healthInsightsCardioFitnessTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight-Adjusted VO2Max'**
  String get healthInsightsCardioFitnessTitle;

  /// No description provided for @healthInsightsCardioFitnessInfo.
  ///
  /// In en, this message translates to:
  /// **'Apple reports VO2Max per kilogram of bodyweight, so it moves whenever your weight does — even if your aerobic fitness hasn\'t changed. This card rescales your current reading to your comparison weight so you can tell a real fitness change from a bodyweight-driven one.'**
  String get healthInsightsCardioFitnessInfo;

  /// No description provided for @healthInsightsVo2MaxAtCompareWeight.
  ///
  /// In en, this message translates to:
  /// **'At your {date} weight, this reading would be about {value}'**
  String healthInsightsVo2MaxAtCompareWeight(String date, String value);

  /// No description provided for @healthInsightsMifflinStJeor.
  ///
  /// In en, this message translates to:
  /// **'Mifflin-St Jeor'**
  String get healthInsightsMifflinStJeor;

  /// No description provided for @healthInsightsCunningham.
  ///
  /// In en, this message translates to:
  /// **'Cunningham (lean mass)'**
  String get healthInsightsCunningham;

  /// No description provided for @healthInsightsWatchBasalAvg.
  ///
  /// In en, this message translates to:
  /// **'Watch resting avg'**
  String get healthInsightsWatchBasalAvg;

  /// No description provided for @healthInsightsWatchActiveAvg.
  ///
  /// In en, this message translates to:
  /// **'Watch active avg'**
  String get healthInsightsWatchActiveAvg;

  /// No description provided for @healthInsightsTotalDailyEnergy.
  ///
  /// In en, this message translates to:
  /// **'Estimated total daily energy'**
  String get healthInsightsTotalDailyEnergy;
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
