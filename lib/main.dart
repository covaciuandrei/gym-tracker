import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/assets/theme/custom_theme.dart';
import 'package:gym_tracker/assets/theme/theme_helper.dart';
import 'package:gym_tracker/core/app_router.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO(phase6): Uncomment after running `flutterfire configure` to generate
//   firebase_options.dart. Firebase is initialized AFTER DI because
//   FirebaseAuth is a @lazySingleton — it resolves on first use, not at
//   startup. Order: configureDependencies → getIt.allReady → Firebase.init.
//
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await getIt.allReady();

  // Register preference-backed helpers manually (they need SharedPreferences,
  // so they cannot be marked @injectable for build_runner code generation).
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<LocaleHelper>(LocaleHelper(prefs));
  getIt.registerSingleton<ThemeHelper>(ThemeHelper(prefs));

  // TODO(phase6): Uncomment after `flutterfire configure`:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = getIt<AppRouter>();
  late final LocaleHelper _localeHelper;
  late final ThemeHelper _themeHelper;

  @override
  void initState() {
    super.initState();
    _localeHelper = getIt<LocaleHelper>();
    _themeHelper = getIt<ThemeHelper>();
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

      // ── Theme ────────────────────────────────────────────────────────────
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode: _themeHelper.themeMode,

      // ── Localizations ────────────────────────────────────────────────────
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _localeHelper.locale,

      // ── Routing ──────────────────────────────────────────────────────────
      routerConfig: _appRouter.config(
        navigatorObservers: () => [AutoRouteObserver()],
      ),
    );
  }
}

