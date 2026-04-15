import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/assets/theme/custom_theme.dart';
import 'package:gym_tracker/assets/theme/theme_helper.dart';
import 'package:gym_tracker/core/app_router.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';
import 'package:gym_tracker/presentation/helpers/onboarding_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await getIt.allReady();

  // Disable reCAPTCHA app-verification in debug mode BEFORE Firebase init.
  // firebase_auth v5+ runs a reCAPTCHA Enterprise pre-check on every
  // email/password sign-in. On Android emulators (especially API 35+) the
  // reCAPTCHA network call fails. This must be set before any auth operations.

  // Register preference-backed helpers manually (they need SharedPreferences,
  // so they cannot be marked @injectable for build_runner code generation).
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<LocaleHelper>(LocaleHelper(prefs));
  getIt.registerSingleton<ThemeHelper>(ThemeHelper(prefs));
  getIt.registerSingleton<OnboardingHelper>(OnboardingHelper(prefs));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    await getIt<FirebaseAuth>().setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = getIt<AppRouter>();
  final LocaleHelper _localeHelper = getIt<LocaleHelper>();
  final ThemeHelper _themeHelper = getIt<ThemeHelper>();

  @override
  void initState() {
    super.initState();
    _localeHelper.addListener(_onHelperChanged);
    _themeHelper.addListener(_onHelperChanged);
  }

  void _onHelperChanged() => setState(() {});

  @override
  void dispose() {
    _localeHelper.removeListener(_onHelperChanged);
    _themeHelper.removeListener(_onHelperChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gym Tracker',

      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: _themeHelper.themeMode,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _localeHelper.locale,

      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(textScaler: TextScaler.linear(1.0)),
          child: child ?? const SizedBox.shrink(),
        );
      },

      routerConfig: _appRouter.config(
        navigatorObservers: () => [AutoRouteObserver()],
      ),
    );
  }
}
