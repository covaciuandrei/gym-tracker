// Widget tests for PasswordMatchIndicator.
//
// Run: flutter test test/presentation/controls/password_match_indicator_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/presentation/controls/password_match_indicator.dart';

Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  late TextEditingController passwordCtrl;
  late TextEditingController confirmCtrl;

  setUp(() {
    passwordCtrl = TextEditingController();
    confirmCtrl = TextEditingController();
  });

  tearDown(() {
    passwordCtrl.dispose();
    confirmCtrl.dispose();
  });

  Widget buildIndicator() => _wrap(
        PasswordMatchIndicator(
          passwordCtrl: passwordCtrl,
          confirmCtrl: confirmCtrl,
        ),
      );

  group('PasswordMatchIndicator', () {
    testWidgets('shows nothing when confirm is empty', (tester) async {
      passwordCtrl.text = 'Pass1234!';

      await tester.pumpWidget(buildIndicator());
      await tester.pump();

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('shows match text when passwords are identical', (tester) async {
      passwordCtrl.text = 'Pass1234!';
      confirmCtrl.text = 'Pass1234!';

      await tester.pumpWidget(buildIndicator());
      await tester.pump();

      expect(find.text('Passwords match'), findsOneWidget);
    });

    testWidgets("shows no-match text when passwords differ", (tester) async {
      passwordCtrl.text = 'Pass1234!';
      confirmCtrl.text = 'Different!';

      await tester.pumpWidget(buildIndicator());
      await tester.pump();

      expect(find.text("Passwords don't match"), findsOneWidget);
    });

    testWidgets('updates when password controller changes', (tester) async {
      passwordCtrl.text = 'Pass1234!';
      confirmCtrl.text = 'Pass1234!';

      await tester.pumpWidget(buildIndicator());
      await tester.pump();
      expect(find.text('Passwords match'), findsOneWidget);

      passwordCtrl.text = 'Changed!';
      await tester.pump();
      expect(find.text("Passwords don't match"), findsOneWidget);
    });

    testWidgets('updates when confirm controller changes', (tester) async {
      passwordCtrl.text = 'Pass1234!';
      confirmCtrl.text = 'Wrong';

      await tester.pumpWidget(buildIndicator());
      await tester.pump();
      expect(find.text("Passwords don't match"), findsOneWidget);

      confirmCtrl.text = 'Pass1234!';
      await tester.pump();
      expect(find.text('Passwords match'), findsOneWidget);
    });

    testWidgets('hides again when confirm is cleared', (tester) async {
      passwordCtrl.text = 'Pass1234!';
      confirmCtrl.text = 'Pass1234!';

      await tester.pumpWidget(buildIndicator());
      await tester.pump();
      expect(find.text('Passwords match'), findsOneWidget);

      confirmCtrl.text = '';
      await tester.pump();
      expect(find.byType(Text), findsNothing);
    });
  });
}
