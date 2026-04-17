// Unit tests for AppVersionCubit
//
// STRATEGY: mock AppConfigService. Override PackageInfo + platform check via a
// test subclass so we don't need real bindings.
//
// Run:  flutter test test/cubit/app_version/app_version_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/cubit/app_version/app_version_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/app_config.dart';
import 'package:gym_tracker/service/app_config/app_config_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ─── Mocks / test double ──────────────────────────────────────────────────

class MockAppConfigService extends Mock implements AppConfigService {}

class _TestAppVersionCubit extends AppVersionCubit {
  _TestAppVersionCubit(super.configService, {required this.version, this.android = true});

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

  setUp(() {
    service = MockAppConfigService();
  });

  group('check', () {
    test('maintenance mode wins over version checks', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '9.0.0', maintenance: true));
      final sut = _TestAppVersionCubit(service, version: '1.0.0');

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<AppVersionMaintenanceState>().having((s) => s.config.maintenanceMode, 'maintenanceMode', true),
        ]),
      );
      await sut.check();
      await future;
      await sut.close();
    });

    test('force update when current < minRequired', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '2.0.0', latest: '2.0.0'));
      final sut = _TestAppVersionCubit(service, version: '1.0.0');

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<AppVersionForceUpdateState>()
              .having((s) => s.currentVersion, 'currentVersion', '1.0.0')
              .having((s) => s.requiredVersion, 'requiredVersion', '2.0.0')
              .having((s) => s.storeUrl, 'storeUrl', 'https://play/android'),
        ]),
      );
      await sut.check();
      await future;
      await sut.close();
    });

    test('force update uses iOS store url when not Android', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '2.0.0'));
      final sut = _TestAppVersionCubit(service, version: '1.0.0', android: false);

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<AppVersionForceUpdateState>().having((s) => s.storeUrl, 'storeUrl', 'https://apps/ios'),
        ]),
      );
      await sut.check();
      await future;
      await sut.close();
    });

    test('ok with softUpdateAvailable when current < latest but >= min', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '1.0.0', latest: '1.2.0'));
      final sut = _TestAppVersionCubit(service, version: '1.1.0');

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<AppVersionOkState>()
              .having((s) => s.softUpdateAvailable, 'softUpdateAvailable', true)
              .having((s) => s.latestVersion, 'latestVersion', '1.2.0')
              .having((s) => s.currentVersion, 'currentVersion', '1.1.0'),
        ]),
      );
      await sut.check();
      await future;
      await sut.close();
    });

    test('ok without soft update when current == latest', () async {
      when(() => service.getAppConfig()).thenAnswer((_) async => _config(min: '1.0.0', latest: '1.0.0'));
      final sut = _TestAppVersionCubit(service, version: '1.0.0');

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<AppVersionOkState>().having((s) => s.softUpdateAvailable, 'softUpdateAvailable', false),
        ]),
      );
      await sut.check();
      await future;
      await sut.close();
    });

    test('network error when service throws', () async {
      when(() => service.getAppConfig()).thenThrow(Exception('offline'));
      final sut = _TestAppVersionCubit(service, version: '1.0.0');

      final future = expectLater(sut.stream, emitsInOrder([const PendingState(), const AppVersionNetworkErrorState()]));
      await sut.check();
      await future;
      await sut.close();
    });
  });
}
