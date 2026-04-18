import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/presentation/controls/labeled_checkbox.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('LabeledCheckbox', () {
    testWidgets('renders checkbox and label', (tester) async {
      await tester.pumpWidget(
        _wrap(LabeledCheckbox(value: false, onChanged: (_) {}, label: const Text('Accept terms'))),
      );

      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Accept terms'), findsOneWidget);
    });

    testWidgets('calls onChanged with toggled value when tapped', (tester) async {
      bool? latest;

      await tester.pumpWidget(
        _wrap(LabeledCheckbox(value: false, onChanged: (value) => latest = value, label: const Text('Accept terms'))),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(latest, isTrue);
    });

    testWidgets('does not call onChanged when disabled', (tester) async {
      var calls = 0;

      await tester.pumpWidget(
        _wrap(
          LabeledCheckbox(value: false, enabled: false, onChanged: (_) => calls++, label: const Text('Accept terms')),
        ),
      );

      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.pump();

      expect(calls, 0);
    });

    testWidgets('shows error text when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          LabeledCheckbox(
            value: false,
            onChanged: (_) {},
            label: const Text('Accept terms'),
            errorText: 'Please accept',
          ),
        ),
      );

      expect(find.text('Please accept'), findsOneWidget);
    });

    testWidgets('hides error text when null', (tester) async {
      await tester.pumpWidget(
        _wrap(LabeledCheckbox(value: false, onChanged: (_) {}, label: const Text('Accept terms'))),
      );

      expect(find.text('Please accept'), findsNothing);
    });
  });
}
