// Widget tests for PasswordStrengthIndicator.
//
// Run: flutter test test/presentation/controls/password_strength_indicator_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/presentation/controls/password_strength_indicator.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  late TextEditingController controller;

  setUp(() => controller = TextEditingController());
  tearDown(() => controller.dispose());

  group('PasswordStrengthIndicator', () {
    testWidgets('shows nothing when password is empty', (tester) async {
      await tester.pumpWidget(
        _wrap(PasswordStrengthIndicator(controller: controller)),
      );
      await tester.pump();

      // No visible text rows at all
      expect(find.byType(Row), findsNothing);
      expect(find.byType(Wrap), findsNothing);
    });

    testWidgets('becomes visible when text is entered', (tester) async {
      controller.text = 'abc';

      await tester.pumpWidget(
        _wrap(PasswordStrengthIndicator(controller: controller)),
      );
      await tester.pump();

      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('shows Weak label for short / simple password', (tester) async {
      controller.text = 'abc'; // score = 1 (lowercase)

      await tester.pumpWidget(
        _wrap(PasswordStrengthIndicator(controller: controller)),
      );
      await tester.pump();

      expect(find.text('Weak'), findsOneWidget);
    });

    testWidgets('shows Fair label for partial-strength password', (tester) async {
      controller.text = 'Abcdefg'; // score = 2 (upper + lower, <8 chars)

      await tester.pumpWidget(
        _wrap(PasswordStrengthIndicator(controller: controller)),
      );
      await tester.pump();

      // score=2: uppercase + lowercase (no number, <8 chars → only 2 criteria)
      expect(find.text('Fair'), findsOneWidget);
    });

    testWidgets('shows Strong label for fully-compliant password', (tester) async {
      controller.text = 'SecurePass1'; // score = 4

      await tester.pumpWidget(
        _wrap(PasswordStrengthIndicator(controller: controller)),
      );
      await tester.pump();

      expect(find.text('Strong'), findsOneWidget);
    });

    testWidgets('shows all four requirement bullets', (tester) async {
      controller.text = 'x';

      await tester.pumpWidget(
        _wrap(PasswordStrengthIndicator(controller: controller)),
      );
      await tester.pump();

      expect(find.text('• 8+ characters'), findsOneWidget);
      expect(find.text('• Uppercase'), findsOneWidget);
      expect(find.text('• Lowercase'), findsOneWidget);
      expect(find.text('• Number'), findsOneWidget);
    });

    testWidgets('updates reactively when controller text changes', (tester) async {
      await tester.pumpWidget(
        _wrap(PasswordStrengthIndicator(controller: controller)),
      );

      controller.text = 'weak';
      await tester.pump();
      expect(find.text('Weak'), findsOneWidget);

      controller.text = 'SecurePass1';
      await tester.pump();
      expect(find.text('Strong'), findsOneWidget);
    });
  });
}
