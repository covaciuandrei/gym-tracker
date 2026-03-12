// Widget tests for SuccessCard.
//
// Run: flutter test test/presentation/controls/success_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/controls/success_card.dart';

Widget _buildApp(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('SuccessCard', () {
    testWidgets('shows default checkmark icon', (tester) async {
      await tester.pumpWidget(_buildApp(
        SuccessCard(
          title: 'Done',
          message: 'All good.',
          buttonLabel: 'OK',
          onAction: () {},
        ),
      ));

      expect(find.text('✅'), findsOneWidget);
    });

    testWidgets('shows custom icon when provided', (tester) async {
      await tester.pumpWidget(_buildApp(
        SuccessCard(
          icon: '🎉',
          title: 'Done',
          message: 'All good.',
          buttonLabel: 'OK',
          onAction: () {},
        ),
      ));

      expect(find.text('🎉'), findsOneWidget);
    });

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_buildApp(
        SuccessCard(
          title: 'Account Created!',
          message: 'Check your inbox.',
          buttonLabel: 'OK',
          onAction: () {},
        ),
      ));

      expect(find.text('Account Created!'), findsOneWidget);
    });

    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(_buildApp(
        SuccessCard(
          title: 'Done',
          message: 'Check your inbox.',
          buttonLabel: 'OK',
          onAction: () {},
        ),
      ));

      expect(find.text('Check your inbox.'), findsOneWidget);
    });

    testWidgets('renders GradientButton with buttonLabel', (tester) async {
      await tester.pumpWidget(_buildApp(
        SuccessCard(
          title: 'Done',
          message: 'All good.',
          buttonLabel: 'Go to Login',
          onAction: () {},
        ),
      ));

      expect(find.byType(GradientButton), findsOneWidget);
      expect(find.text('Go to Login'), findsOneWidget);
    });

    testWidgets('onAction is called when button tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildApp(
        SuccessCard(
          title: 'Done',
          message: 'All good.',
          buttonLabel: 'Go',
          onAction: () => called = true,
        ),
      ));

      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      expect(called, isTrue);
    });
  });
}
