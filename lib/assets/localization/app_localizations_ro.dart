// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Gym Tracker';

  @override
  String get authLoginTitle => 'Autentificare';

  @override
  String get authLoginWelcomeTitle => 'Bine ai revenit';

  @override
  String get authLoginSubtitle =>
      'Autentifică-te pentru a urmări prezența la sală';

  @override
  String get authLoginSignUp => 'Înregistrează-te';

  @override
  String get authLoginEmail => 'Email';

  @override
  String get authLoginPassword => 'Parolă';

  @override
  String get authLoginButton => 'Autentificare';

  @override
  String get authLoginNoAccount => 'Nu ai cont?';

  @override
  String get authLoginForgotPassword => 'Ai uitat parola?';

  @override
  String get authRegisterTitle => 'Creare Cont';

  @override
  String get authRegisterDisplayName => 'Nume afișat';

  @override
  String get authRegisterEmail => 'Email';

  @override
  String get authRegisterPassword => 'Parolă';

  @override
  String get authRegisterConfirmPassword => 'Confirmă Parola';

  @override
  String get authRegisterButton => 'Creare Cont';

  @override
  String get authRegisterHaveAccount => 'Ai deja cont?';

  @override
  String get authRegisterSubtitle =>
      'Începe să îți urmărești prezența la sală astăzi';

  @override
  String get authRegisterSignIn => 'Autentifică-te';

  @override
  String get authRegisterSuccess => 'Cont creat!';

  @override
  String get authRegisterSuccessMessage =>
      'Verifică-ți emailul pentru a activa contul înainte de autentificare.';

  @override
  String get authRegisterGoToLogin => 'Mergi la autentificare';

  @override
  String get authPasswordStrengthWeak => 'Slabă';

  @override
  String get authPasswordStrengthFair => 'Medie';

  @override
  String get authPasswordStrengthStrong => 'Puternică';

  @override
  String get authPasswordReqLength => '8+ caractere';

  @override
  String get authPasswordReqUppercase => 'Majusculă';

  @override
  String get authPasswordReqLowercase => 'Minusculă';

  @override
  String get authPasswordReqNumber => 'Cifră';

  @override
  String get authPasswordsMatch => 'Parolele coincid';

  @override
  String get authPasswordsNoMatch => 'Parolele nu coincid';

  @override
  String get authForgotPasswordTitle => 'Resetare Parolă';

  @override
  String get authForgotPasswordSubtitle =>
      'Introdu email-ul şi îți vom trimite un link de resetare';

  @override
  String get authForgotPasswordSuccessTitle => 'Verifică Inbox-ul';

  @override
  String get authForgotPasswordEmail => 'Email';

  @override
  String get authForgotPasswordButton => 'Trimite Email de Resetare';

  @override
  String get authForgotPasswordBack => 'Înapoi la Autentificare';

  @override
  String get authForgotPasswordSent =>
      'Email de resetare trimis. Verifică inbox-ul.';

  @override
  String get authEmailNotVerified =>
      'Te rugăm să verifici emailul înainte de autentificare.';

  @override
  String get authVerificationEmailSent => 'Email de verificare trimis.';

  @override
  String get authSignOut => 'Delogare';

  @override
  String get authEmailVerificationHandled => 'Email verificat cu succes.';

  @override
  String get authActionVerifyingEmail => 'Se verifică emailul...';

  @override
  String get authActionValidatingLink => 'Se validează link-ul de resetare...';

  @override
  String get authActionEmailVerifiedTitle => 'Email Verificat!';

  @override
  String get authActionEmailVerifiedMessage =>
      'Emailul tău a fost verificat. Te poți autentifica acum.';

  @override
  String get authActionSetNewPasswordTitle => 'Setează Parola Nouă';

  @override
  String get authActionNewPassword => 'Parolă Nouă';

  @override
  String get authActionResetPasswordButton => 'Resetează Parola';

  @override
  String get authActionPasswordResetTitle => 'Parolă Resetată!';

  @override
  String get authActionPasswordResetMessage =>
      'Parola ta a fost resetată. Te poți autentifica cu noua parolă.';

  @override
  String get authActionRequestNewLink => 'Solicită Link Nou';

  @override
  String get authActionBackToSignIn => 'Înapoi la Autentificare';

  @override
  String get errorsInvalidActionCode =>
      'Acest link a expirat sau a fost deja folosit. Te rugăm să soliciți unul nou.';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navStats => 'Statistici';

  @override
  String get navHealth => 'Sănătate';

  @override
  String get navProfile => 'Profil';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarMonthly => 'Lunar';

  @override
  String get calendarYearly => 'Anual';

  @override
  String get calendarMarkAttended => 'Marchează prezența';

  @override
  String get calendarWentToGym => 'Prezent la sală';

  @override
  String get calendarSave => 'Salvează';

  @override
  String get calendarClear => 'Șterge';

  @override
  String get calendarAddSupplement => 'Adaugă supliment';

  @override
  String get calendarWorkoutTab => 'Antrenament';

  @override
  String get calendarHealthTab => 'Sănătate';

  @override
  String get calendarNotes => 'Note';

  @override
  String get calendarDurationMinutes => 'Durată (minute)';

  @override
  String get calendarTrainingType => 'Tip antrenament';

  @override
  String get calendarNoType => 'Fără tip';

  @override
  String get calendarNoHealthLogs =>
      'Niciun supliment înregistrat pentru această zi.';

  @override
  String get calendarSelectProduct => 'Selectează un produs';

  @override
  String get calendarRemove => 'Elimină';

  @override
  String get calendarCancel => 'Anulează';

  @override
  String get calendarDidYouGoToGym => 'Ai fost la sală?';

  @override
  String get calendarSelectTypePlaceholder => '-- Selectează tipul --';

  @override
  String get calendarSelectWorkoutTypeOptional =>
      'Selectează tipul de antrenament (opțional)';

  @override
  String get calendarDurationLabel => 'Durată:';

  @override
  String get calendarDurationHint => 'ex. 60';

  @override
  String get calendarDurationOptional => 'Durată (opțional)';

  @override
  String get calendarAdd => 'Adaugă';

  @override
  String get calendarSupplementsTaken => 'Suplimente luate';

  @override
  String get calendarNoSupplementProductsAvailable =>
      'Nu există produse de suplimente disponibile.';

  @override
  String get calendarDidYouTakeAnySupplements => 'Ai luat suplimente?';

  @override
  String get calendarAddSupplementLabel => 'Adaugă supliment:';

  @override
  String get calendarPleaseSelectSupplement =>
      'Te rugăm să selectezi un supliment';

  @override
  String get calendarSelectSupplementHint => 'Selectează un supliment...';

  @override
  String calendarDurationMinutesShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min',
      few: '$count min',
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
      few: '$count h',
      one: '$count h',
    );
    return '$_temp0';
  }

  @override
  String get statsTitle => 'Statistici';

  @override
  String get statsAttendances => 'Prezențe';

  @override
  String get statsWorkout => 'Antrenament';

  @override
  String get statsDuration => 'Durată';

  @override
  String get statsHealth => 'Sănătate';

  @override
  String get statsThisMonth => 'Luna Aceasta';

  @override
  String get statsThisYear => 'Anul Acesta';

  @override
  String get statsAllTime => 'Total';

  @override
  String get statsCurrentStreak => 'Serie Curentă';

  @override
  String get statsBestStreak => 'Top Serie';

  @override
  String get statsFavoriteDay => 'Ziua Fav';

  @override
  String get statsConsistency => 'Consistență';

  @override
  String get statsConsistencyWithoutIcon => 'Consistență';

  @override
  String get statsUniqueSupplements => 'Suplimente Unice';

  @override
  String get statsStreak0 => 'Începe-ți călătoria!';

  @override
  String get statsStreak1 => 'Prima săptămână finalizată!';

  @override
  String get statsStreak2 => 'Prinzi avânt!';

  @override
  String get statsStreak4 => 'De o lună în formă!';

  @override
  String get statsStreak8 => 'Ești on fire!';

  @override
  String get statsStreak12 => 'Regele consecvenței!';

  @override
  String get statsStreak20 => 'De neoprit!';

  @override
  String get statsStreak30 => 'Fiară de jumătate de an!';

  @override
  String get statsStreak40 => 'Mod legendă!';

  @override
  String get statsStreak52 => 'Aproape un an întreg!';

  @override
  String get statsStreakMax => 'Absolut GOAT!';

  @override
  String get statsTapToSeeDates => 'Atinge pentru a vedea datele';

  @override
  String get statsNoStreakYet => 'Niciun șir încă';

  @override
  String get statsDaysYouHitGym => 'Zile în care ai fost la sală';

  @override
  String get statsFavoriteDayLegend => 'Zi favorită';

  @override
  String get statsFavoriteDaysLegend => 'Zile favorite';

  @override
  String get statsMonthlyBreakdown => 'Defalcare lunară';

  @override
  String get statsAverageDurationLegend => 'Durata medie';

  @override
  String get statsOfWeeksThisYear => 'din săptămânile acestui an';

  @override
  String statsXThisYear(Object count) {
    return '${count}x anul acesta';
  }

  @override
  String statsWeekCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de săptămâni',
      few: '$count săptămâni',
      one: '$count săptămână',
    );
    return '$_temp0';
  }

  @override
  String statsPercentOfWeeksThisYear(int percent) {
    return '$percent% din săptămânile acestui an';
  }

  @override
  String statsDifferentProducts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de produse diferite',
      few: '$count produse diferite',
      one: '1 produs diferit',
    );
    return '$_temp0';
  }

  @override
  String statsCountTimes(int count) {
    return '${count}x';
  }

  @override
  String get statsAvgThisMonth => 'Medie Luna Aceasta';

  @override
  String get statsAvgThisYear => 'Medie Anul Acesta';

  @override
  String get statsUntrackedCount => 'Neînregistrate';

  @override
  String get statsMinutes => 'min';

  @override
  String get statsTotalLogs => 'Total Înregistrări';

  @override
  String get statsMostUsed => 'Cel Mai Folosit';

  @override
  String get statsTotalTracked => 'Total Înregistrate';

  @override
  String get monthsJanuary => 'Ianuarie';

  @override
  String get monthsFebruary => 'Februarie';

  @override
  String get monthsMarch => 'Martie';

  @override
  String get monthsApril => 'Aprilie';

  @override
  String get monthsMay => 'Mai';

  @override
  String get monthsJune => 'Iunie';

  @override
  String get monthsJuly => 'Iulie';

  @override
  String get monthsAugust => 'August';

  @override
  String get monthsSeptember => 'Septembrie';

  @override
  String get monthsOctober => 'Octombrie';

  @override
  String get monthsNovember => 'Noiembrie';

  @override
  String get monthsDecember => 'Decembrie';

  @override
  String get weekdaysMonday => 'Luni';

  @override
  String get weekdaysTuesday => 'Marți';

  @override
  String get weekdaysWednesday => 'Miercuri';

  @override
  String get weekdaysThursday => 'Joi';

  @override
  String get weekdaysFriday => 'Vineri';

  @override
  String get weekdaysSaturday => 'Sâmbătă';

  @override
  String get weekdaysSunday => 'Duminică';

  @override
  String get weekdaysMiniMon => 'L';

  @override
  String get weekdaysMiniTue => 'Ma';

  @override
  String get weekdaysMiniWed => 'Mi';

  @override
  String get weekdaysMiniThu => 'J';

  @override
  String get weekdaysMiniFri => 'V';

  @override
  String get weekdaysMiniSat => 'S';

  @override
  String get weekdaysMiniSun => 'D';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEmailVerified => 'Verificat';

  @override
  String get profileManage => 'Gestionare';

  @override
  String get profileAccount => 'Cont';

  @override
  String get profileWorkoutTypes => 'Tipuri de Antrenament';

  @override
  String get profileSettings => 'Setări';

  @override
  String get profileSignOut => 'Delogare';

  @override
  String get workoutTypesTitle => 'Tipuri de Antrenament';

  @override
  String get workoutTypesAdd => 'Adaugă Tip';

  @override
  String get workoutTypesSave => 'Salvează';

  @override
  String get workoutTypesDelete => 'Șterge';

  @override
  String get workoutTypesDeleteConfirm =>
      'Ești sigur că vrei să ștergi acest tip de antrenament?';

  @override
  String get workoutTypesName => 'Nume';

  @override
  String get workoutTypesNamePlaceholder => 'ex: Antrenament de Forță';

  @override
  String get workoutTypesIcon => 'Pictogramă';

  @override
  String get workoutTypesColor => 'Culoare';

  @override
  String get workoutTypesCreate => 'Creează';

  @override
  String get workoutTypesCancel => 'Anulează';

  @override
  String get workoutTypesEmpty =>
      'Nu există tipuri de antrenament.\nAtinge + pentru a adăuga primul tip.';

  @override
  String get workoutTypesEmptyTitle => 'Nu există tipuri de antrenament';

  @override
  String get workoutTypesEmptyDescription =>
      'Creează primul tip de antrenament pentru a organiza sesiunile.';

  @override
  String get workoutTypesCreateFirst => 'Creează primul tip';

  @override
  String get workoutTypesCreateTitle => 'Creează tip de antrenament';

  @override
  String get workoutTypesEditTitle => 'Editează Tip';

  @override
  String get workoutTypesDeleteTitle => 'Șterge tipul de antrenament';

  @override
  String get workoutTypesDeleteWarning =>
      'Această acțiune nu poate fi anulată.';

  @override
  String get workoutTypesLoading => 'Se încarcă tipurile de antrenament...';

  @override
  String get workoutTypesPreview => 'Previzualizare';

  @override
  String get workoutTypesPreviewName => 'Tip de antrenament';

  @override
  String get healthTitle => 'Sănătate';

  @override
  String get healthToday => 'Astăzi';

  @override
  String get healthMySupplements => 'Suplimentele Mele';

  @override
  String get healthAllSupplements => 'Toate Suplimentele';

  @override
  String get healthProductName => 'Nume Produs';

  @override
  String get healthBrand => 'Brand';

  @override
  String get healthIngredients => 'Ingrediente';

  @override
  String get healthServings => 'Porții';

  @override
  String get healthAddSupplement => 'Adaugă Supliment';

  @override
  String get healthLogToday => 'Înregistrează Azi';

  @override
  String get healthSave => 'Salvează';

  @override
  String get healthDelete => 'Șterge';

  @override
  String get healthSearchPlaceholder => 'Caută după nume sau brand...';

  @override
  String get healthServingsPerDay => 'Porții pe zi';

  @override
  String get healthProductCreated => 'Supliment creat.';

  @override
  String get healthProductUpdated => 'Supliment actualizat.';

  @override
  String get healthDeleteSupplementTitle => 'Șterge suplimentul';

  @override
  String get healthDeleteWarning => 'Această acțiune nu poate fi anulată.';

  @override
  String get healthDeleteLogTitle => 'Șterge înregistrarea';

  @override
  String get healthDeleteLogMessage =>
      'Sigur vrei să ștergi această înregistrare de supliment?';

  @override
  String get healthMySearchHint => 'Caută în suplimentele mele...';

  @override
  String get healthAllSearchHint => 'Caută în toate suplimentele...';

  @override
  String get healthNoPersonalSupplements => 'Nu ai suplimente personale';

  @override
  String get healthNoPersonalSupplementsMessage =>
      'Nu ai adăugat încă suplimente personalizate.';

  @override
  String get healthNoSupplementsFound => 'Nu au fost găsite suplimente';

  @override
  String get healthNoSupplementsFoundMessage =>
      'Încearcă un alt termen de căutare.';

  @override
  String get healthNoSupplementsToday =>
      'Nu există suplimente înregistrate azi';

  @override
  String get healthNoSupplementsTodayMessage =>
      'Începe ziua prin înregistrarea suplimentelor.';

  @override
  String get healthEditAction => 'Editează';

  @override
  String get healthEditSupplement => 'Editează suplimentul';

  @override
  String get healthIngredientName => 'Ingredient';

  @override
  String get healthAmount => 'Cantitate';

  @override
  String get healthNoIngredientsYet => 'Nu au fost adăugate ingrediente.';

  @override
  String get healthUnknownProduct => 'Necunoscut';

  @override
  String healthServingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de porții',
      few: '$count porții',
      one: '$count porție',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Setări';

  @override
  String get settingsAbout => 'Despre';

  @override
  String get settingsSecurity => 'Securitate';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsTheme => 'Temă';

  @override
  String get settingsThemeDark => 'Întunecat';

  @override
  String get settingsThemeLight => 'Luminos';

  @override
  String get settingsLanguage => 'Limbă';

  @override
  String get settingsLanguageEn => 'Engleză';

  @override
  String get settingsLanguageRo => 'Română';

  @override
  String get settingsChangePassword => 'Schimbă Parola';

  @override
  String get settingsCurrentPassword => 'Parola Actuală';

  @override
  String get settingsNewPassword => 'Parola Nouă';

  @override
  String get settingsConfirmPassword => 'Confirmă Parola';

  @override
  String get settingsSavePassword => 'Salvează Parola';

  @override
  String get settingsAppVersion => 'Versiune Aplicație';

  @override
  String get settingsBuiltWith => 'Creat cu Flutter + Firebase';

  @override
  String get settingsBuiltWithValue => 'Flutter + Firebase';

  @override
  String get settingsDataMigration => 'Migrare Date';

  @override
  String get settingsRunMigration => 'Rulează Migrare';

  @override
  String get errorsInvalidCredentials => 'Email sau parolă incorectă.';

  @override
  String get errorsEmailAlreadyInUse => 'Acest email este deja folosit.';

  @override
  String get errorsEmailNotVerified =>
      'Te rugăm să verifici emailul înainte de autentificare.';

  @override
  String get errorsWeakPassword => 'Parola este prea slabă.';

  @override
  String get errorsNetworkError => 'Eroare de rețea. Verifică conexiunea.';

  @override
  String get errorsUnknown => 'Ceva nu a mers bine. Încearcă din nou.';

  @override
  String get errorsNumbersOnly => 'Te rugăm să introduci doar cifre';

  @override
  String get errorsInvalidNumber => 'Te rugăm să introduci un număr valid';

  @override
  String get errorsPositiveNumber => 'Te rugăm să introduci un număr pozitiv';

  @override
  String get errorsFieldRequired => 'Acest câmp este obligatoriu.';

  @override
  String get errorsPasswordMismatch => 'Parolele nu coincid.';

  @override
  String get errorsPasswordTooShort =>
      'Parola trebuie să aibă cel puțin 6 caractere.';

  @override
  String get settingsPasswordChangedSuccess =>
      'Parola a fost schimbată cu succes.';

  @override
  String authActionCreateNewPasswordFor(String email) {
    return 'Creează o parolă nouă pentru $email';
  }

  @override
  String get profileDefaultUserName => 'Utilizator Gym Tracker';

  @override
  String get globalTryAgain => 'Încearcă din nou';
}
