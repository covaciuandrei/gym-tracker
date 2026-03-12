// Widget tests for GradientButton.
//
// Run: flutter test test/presentation/controls/gradient_button_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_tracker/presentation/controls/gradient_button.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('GradientButton', () {
    testWidgets('renders label when not loading', (tester) async {
      await tester.pumpWidget(_wrap(
        GradientButton(label: 'Submit', isLoading: false, onTap: () {}),
      ));

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows spinner and hides label when loading', (tester) async {
      await tester.pumpWidget(_wrap(
        GradientButton(label: 'Submit', isLoading: true, onTap: () {}),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('invokes onTap when tapped and not loading', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        GradientButton(
          label: 'Submit',
          isLoading: false,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(GradientButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not invoke onTap when loading', (tester) async {
      var tapped = false;

      await tester.pumpWidget(_wrap(
        GradientButton(
          label: 'Submit',
          isLoading: true,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(GradientButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });

    testWidgets('respects custom height and radius', (tester) async {
      await tester.pumpWidget(_wrap(
        GradientButton(
          label: 'Tall',
          isLoading: false,
          onTap: () {},
          height: 72,
          radius: 24,
        ),
      ));

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(GradientButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(container.constraints?.maxHeight, 72);
    });
  });
}
