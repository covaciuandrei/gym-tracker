import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/pages/change_password/change_password_page.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

Widget _buildApp(AuthCubit cubit) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<AuthCubit>.value(
      value: cubit,
      child: const ChangePasswordPage(),
    ),
  );
}

MockAuthCubit _stubCubit(BaseState state) {
  final cubit = MockAuthCubit();
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  when(
    () => cubit.changePassword(
      currentPassword: any(named: 'currentPassword'),
      newPassword: any(named: 'newPassword'),
    ),
  ).thenAnswer((_) async {});
  return cubit;
}

void main() {
  setUpAll(() {
    registerFallbackValue(const InitialState());
  });

  group('ChangePasswordPage', () {
    testWidgets('renders change-password form fields', (tester) async {
      final cubit = _stubCubit(const InitialState());

      await tester.pumpWidget(_buildApp(cubit));

      expect(find.text('Change Password'), findsNWidgets(2));
      expect(find.text('Current Password'), findsWidgets);
      expect(find.text('New Password'), findsWidgets);
      expect(find.text('Confirm Password'), findsWidgets);
      expect(find.text('Save Password'), findsOneWidget);
    });

    testWidgets('shows required validation when submitting empty form', (
      tester,
    ) async {
      final cubit = _stubCubit(const InitialState());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.ensureVisible(find.text('Save Password'));
      await tester.tap(find.text('Save Password'));
      await tester.pump();

      expect(find.text('This field is required.'), findsNWidgets(3));
      verifyNever(
        () => cubit.changePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    testWidgets('submits current and new password when form is valid', (
      tester,
    ) async {
      final cubit = _stubCubit(const InitialState());

      await tester.pumpWidget(_buildApp(cubit));

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'OldPass123');
      await tester.enterText(textFields.at(1), 'NewPass123');
      await tester.enterText(textFields.at(2), 'NewPass123');

      await tester.ensureVisible(find.text('Save Password'));
      await tester.tap(find.text('Save Password'));
      await tester.pump();

      verify(
        () => cubit.changePassword(
          currentPassword: 'OldPass123',
          newPassword: 'NewPass123',
        ),
      ).called(1);
    });
  });
}
