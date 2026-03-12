// Widget tests for AuthFooterLink.
//
// Run: flutter test test/presentation/controls/auth_footer_link_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_tracker/presentation/controls/auth_footer_link.dart';

Widget _buildApp(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('AuthFooterLink', () {
    testWidgets('renders prompt and actionLabel texts', (tester) async {
      await tester.pumpWidget(_buildApp(
        AuthFooterLink(
          prompt: 'Already have an account?',
          actionLabel: 'Sign in',
          onTap: () {},
        ),
      ));

      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('renders a Divider', (tester) async {
      await tester.pumpWidget(_buildApp(
        AuthFooterLink(
          prompt: 'Prompt',
          actionLabel: 'Action',
          onTap: () {},
        ),
      ));

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('invokes onTap when enabled and button tapped', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildApp(
        AuthFooterLink(
          prompt: 'Prompt',
          actionLabel: 'Action',
          onTap: () => called = true,
        ),
      ));

      await tester.tap(find.byType(TextButton));
      expect(called, isTrue);
    });

    testWidgets('does not invoke onTap when enabled is false', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildApp(
        AuthFooterLink(
          prompt: 'Prompt',
          actionLabel: 'Action',
          enabled: false,
          onTap: () => called = true,
        ),
      ));

      await tester.tap(find.byType(TextButton), warnIfMissed: false);
      expect(called, isFalse);
    });

    testWidgets('enabled defaults to true and button fires', (tester) async {
      var called = false;
      await tester.pumpWidget(_buildApp(
        AuthFooterLink(
          prompt: 'Prompt',
          actionLabel: 'Go',
          onTap: () => called = true,
        ),
      ));

      await tester.tap(find.byType(TextButton));
      expect(called, isTrue);
    });

    testWidgets('contains a TextButton widget', (tester) async {
      await tester.pumpWidget(_buildApp(
        AuthFooterLink(
          prompt: 'No account?',
          actionLabel: 'Register',
          onTap: () {},
        ),
      ));

      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
