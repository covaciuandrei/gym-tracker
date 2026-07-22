import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/settings/settings_cubit.dart';
import 'package:gym_tracker/model/user.dart';
import 'package:gym_tracker/service/auth/auth_service.dart';
import 'package:gym_tracker/service/user/user_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUserService extends Mock implements UserService {}

User _user({String currency = 'EUR'}) => User(
  id: 'user_1',
  email: 'user@test.com',
  displayName: 'User',
  theme: 'dark',
  language: 'en',
  currency: currency,
  lastLoginAt: DateTime(2026),
  createdAt: DateTime(2026),
  totalAttendances: 0,
);

void main() {
  late MockAuthService authService;
  late MockUserService userService;
  late SettingsCubit cubit;

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Gym Tracker',
      packageName: 'com.example.gym_tracker',
      version: '1.2.3',
      buildNumber: '1',
      buildSignature: '',
    );
    authService = MockAuthService();
    userService = MockUserService();
    when(() => authService.currentUserId).thenReturn('user_1');
    when(() => userService.getById(userId: 'user_1')).thenAnswer((_) async => _user(currency: 'RON'));
    cubit = SettingsCubit(authService, userService);
  });

  tearDown(() => cubit.close());

  test('init loads app version and account currency', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([const PendingState(), const SettingsReadyState(appVersion: '1.2.3', currency: 'RON')]),
    );

    await cubit.init();
    await expectation;
  });

  test('init falls back to EUR when the profile cannot be loaded', () async {
    when(() => userService.getById(userId: 'user_1')).thenThrow(Exception('offline'));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([const PendingState(), const SettingsReadyState(appVersion: '1.2.3', currency: 'EUR')]),
    );

    await cubit.init();
    await expectation;
  });

  test('setCurrency persists and emits the updated account currency', () async {
    await cubit.init();
    when(() => userService.updateCurrency(userId: 'user_1', currency: 'GBP')).thenAnswer((_) async {});

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([const PendingState(), const SettingsCurrencyUpdatedState(appVersion: '1.2.3', currency: 'GBP')]),
    );

    await cubit.setCurrency(currency: 'GBP');
    await expectation;
    verify(() => userService.updateCurrency(userId: 'user_1', currency: 'GBP')).called(1);
  });

  test('setCurrency rejects unsupported values without writing', () async {
    final expectation = expectLater(cubit.stream, emits(const SomethingWentWrongState()));

    await cubit.setCurrency(currency: 'CAD');
    await expectation;
    verifyNever(
      () => userService.updateCurrency(
        userId: any(named: 'userId'),
        currency: any(named: 'currency'),
      ),
    );
  });
}
