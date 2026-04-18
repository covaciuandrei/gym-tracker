// Unit tests for SplashCubit.
//
// STRATEGY: mock AppConfigService + FirebaseAuth + helpers. Override
// PackageInfo + platform check via a test subclass so no real bindings are
// needed. Every start() call uses Duration.zero as minSplashDuration so the
// resolved navigation state is emitted without an artificial wait.
//
// Run:  flutter test test/cubit/splash/splash_cubit_test.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/core/app_version_status.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/splash/splash_cubit.dart';
import 'package:gym_tracker/model/app_config.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';
import 'package:gym_tracker/presentation/helpers/onboarding_helper.dart';
import 'package:gym_tracker/service/app_config/app_config_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ─── Mocks / test double ──────────────────────────────────────────────────

class MockAppConfigService extends Mock implements AppConfigService {}

class MockOnboardingHelper extends Mock implements OnboardingHelper {}

class MockLocaleHelper extends Mock implements LocaleHelper {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class _TestSplashCubit extends SplashCubit {
  _TestSplashCubit(
    super.configService,
    super.onboardingHelper,
    super.localeHelper,
    super.authInstance,
    super.versionStatus, {
    required this.version,
    this.android = true,
  });

  final String version;
  final bool android;

  @override
  Future<PackageInfo> packageInfo() async =>
      PackageInfo(appName: 'gym_tracker', packageName: 'com.example.gym_tracker', version: version, buildNumber: '1');

  @override
  bool get isAndroid => android;
}

// ─── Fixtures ─────────────────────────────────────────────────────────────

AppConfig _config({
  String min = '1.0.0',
  String latest = '1.0.0',
  bool maintenance = false,
  Map<String, String> messages = const {'en': 'Down', 'ro': 'Indisponibil'},
  String android = 'https://play/android',
  String ios = 'https://apps/ios',
}) => AppConfig(
  minRequiredVersion: min,
  latestVersion: latest,
  maintenanceMode: maintenance,
  maintenanceMessages: messages,
  androidStoreUrl: android,
  iosStoreUrl: ios,
);

// ─── Tests ────────────────────────────────────────────────────────────────

void main() {
  late MockAppConfigService service;
  late MockOnboardingHelper onboarding;
  late MockLocaleHelper locale;
  late MockFirebaseAuth auth;
  late AppVersionStatus versionStatus;

  setUp(() {
    service = MockAppConfigService();
    onboarding = MockOnboardingHelper();
    locale = MockLocaleHelper();
    auth = MockFirebaseAuth();
    versionStatus = AppVersionStatus();

    // Default helper answers for the "ok + main shell" happy path; individual
    // tests override as needed.
    when(() => onboarding.isFirstLaunch).thenReturn(false);
    when(() => locale.locale).thenReturn(const Locale('en'));
    when(() => auth.currentUser).thenReturn(MockUser());
  });

  _TestSplashCubit buildSut({required String version, bool android = true}) =>
      _TestSplashCubit(service, onboarding, locale, auth, versionStatus, version: version, android: android);

  group('start — version gate', () {
    test('maintenance mode wins over version checks and uses locale message', () async {
      when(() => service.getAppConfig()).thenAnswer(
        (_) async => _config(min: '9.0.0', maintenance: true, messages: const {'en': 'Down', 'ro': 'Indisponibil'}),
      );
      when(() => locale.locale).thenReturn(const Locale('ro'));
      final sut = buildSut(version: '1.0.0');

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<SplashNavigateMaintenanceState>().having((s) => s.message, 'message', 'Indisponibil'),
        ]),
      );
      await sut.start(minSplashDuration: Duration.zero);
      await future;
      await sut.close();
    });

    test('force update when current < minRequired (Android store url)', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '2.0.0', latest: '2.0.0'));
      final sut = buildSut(version: '1.0.0');

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<SplashNavigateForceUpdateState>()
              .having((s) => s.currentVersion, 'currentVersion', '1.0.0')
              .having((s) => s.requiredVersion, 'requiredVersion', '2.0.0')
              .having((s) => s.storeUrl, 'storeUrl', 'https://play/android'),
        ]),
      );
      await sut.start(minSplashDuration: Duration.zero);
      await future;
      await sut.close();
    });

    test('force update uses iOS store url when not Android', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '2.0.0'));
      final sut = buildSut(version: '1.0.0', android: false);

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<SplashNavigateForceUpdateState>().having((s) => s.storeUrl, 'storeUrl', 'https://apps/ios'),
        ]),
      );
      await sut.start(minSplashDuration: Duration.zero);
      await future;
      await sut.close();
    });

    test('network error state when config service throws', () async {
      when(() => service.getAppConfig()).thenThrow(Exception('no network'));
      final sut = buildSut(version: '1.0.0');

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SplashNavigateNoConnectionState()]),
      );
      await sut.start(minSplashDuration: Duration.zero);
      await future;
      await sut.close();
    });
  });

  group('start — ok path onboarding/auth decision', () {
    test('first launch → onboarding', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(latest: '1.0.0'));
      when(() => onboarding.isFirstLaunch).thenReturn(true);
      final sut = buildSut(version: '1.0.0');

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SplashNavigateOnboardingState()]),
      );
      await sut.start(minSplashDuration: Duration.zero);
      await future;
      await sut.close();
    });

    test('returning user signed in → main shell', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(latest: '1.0.0'));
      when(() => onboarding.isFirstLaunch).thenReturn(false);
      when(() => auth.currentUser).thenReturn(MockUser());
      final sut = buildSut(version: '1.0.0');

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SplashNavigateMainShellState()]),
      );
      await sut.start(minSplashDuration: Duration.zero);
      await future;
      await sut.close();
    });

    test('returning user signed out → login', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(latest: '1.0.0'));
      when(() => onboarding.isFirstLaunch).thenReturn(false);
      when(() => auth.currentUser).thenReturn(null);
      final sut = buildSut(version: '1.0.0');

      final future = expectLater(sut.stream, emitsInOrder([const PendingState(), const SplashNavigateLoginState()]));
      await sut.start(minSplashDuration: Duration.zero);
      await future;
      await sut.close();
    });
  });

  group('start — AppVersionStatus population', () {
    test('flags bigUpdateAvailable=true on a major bump', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '1.0.0', latest: '3.0.0'));
      final sut = buildSut(version: '2.5.0');

      await sut.start(minSplashDuration: Duration.zero);
      await sut.close();

      expect(versionStatus.bigUpdateAvailable, isTrue);
      expect(versionStatus.latestVersion, '3.0.0');
      expect(versionStatus.storeUrl, 'https://play/android');
    });

    test('flags bigUpdateAvailable=true on a minor bump of 2 or more', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '1.0.0', latest: '2.4.0'));
      final sut = buildSut(version: '2.1.0');

      await sut.start(minSplashDuration: Duration.zero);
      await sut.close();

      expect(versionStatus.bigUpdateAvailable, isTrue);
      expect(versionStatus.latestVersion, '2.4.0');
    });

    test('flags bigUpdateAvailable=false for single-step minor bumps', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '1.0.0', latest: '2.2.0'));
      final sut = buildSut(version: '2.1.0');

      await sut.start(minSplashDuration: Duration.zero);
      await sut.close();

      expect(versionStatus.bigUpdateAvailable, isFalse);
      expect(versionStatus.latestVersion, '2.2.0');
    });

    test('flags bigUpdateAvailable=false for patch-only bumps', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '1.0.0', latest: '2.1.9'));
      final sut = buildSut(version: '2.1.1');

      await sut.start(minSplashDuration: Duration.zero);
      await sut.close();

      expect(versionStatus.bigUpdateAvailable, isFalse);
    });

    test('flags bigUpdateAvailable=false when current == latest', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '1.0.0', latest: '1.0.0'));
      final sut = buildSut(version: '1.0.0');

      await sut.start(minSplashDuration: Duration.zero);
      await sut.close();

      expect(versionStatus.bigUpdateAvailable, isFalse);
      expect(versionStatus.latestVersion, '1.0.0');
    });

    test('does NOT populate AppVersionStatus on the force-update path', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '2.0.0'));
      final sut = buildSut(version: '1.0.0');

      await sut.start(minSplashDuration: Duration.zero);
      await sut.close();

      // Still at initial defaults
      expect(versionStatus.latestVersion, '');
      expect(versionStatus.storeUrl, '');
    });
  });

  group('start — minimum splash duration', () {
    test('awaits at least minSplashDuration before emitting terminal state', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(latest: '1.0.0'));
      final sut = buildSut(version: '1.0.0');

      final stopwatch = Stopwatch()..start();
      await sut.start(minSplashDuration: const Duration(milliseconds: 150));
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(140));
      expect(sut.state, isA<SplashNavigateMainShellState>());
      await sut.close();
    });
  });
}
