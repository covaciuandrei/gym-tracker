// Widget tests for FormCard.
//
// Run: flutter test test/presentation/controls/form_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_tracker/presentation/controls/form_card.dart';

Widget _buildApp(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('FormCard', () {
    testWidgets('renders a Form widget', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_buildApp(
        FormCard(formKey: formKey, children: const []),
      ));

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('formKey is wired to the Form — validate returns correctly',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_buildApp(
        FormCard(
          formKey: formKey,
          children: [
            TextFormField(validator: (_) => 'required'),
          ],
        ),
      ));

      // Validator always returns an error — validate() should be false
      expect(formKey.currentState?.validate(), isFalse);
    });

    testWidgets('renders all children', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_buildApp(
        FormCard(
          formKey: formKey,
          children: const [
            Text('Field A'),
            Text('Field B'),
            Text('Field C'),
          ],
        ),
      ));

      expect(find.text('Field A'), findsOneWidget);
      expect(find.text('Field B'), findsOneWidget);
      expect(find.text('Field C'), findsOneWidget);
    });

    testWidgets('children are wrapped in AutofillGroup', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_buildApp(
        FormCard(formKey: formKey, children: const []),
      ));

      expect(find.byType(AutofillGroup), findsOneWidget);
    });

    testWidgets('children Column is left-aligned', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(_buildApp(
        FormCard(formKey: formKey, children: const [Text('x')]),
      ));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    });

    testWidgets('omitting formKey renders no Form widget', (tester) async {
      await tester.pumpWidget(_buildApp(
        const FormCard(children: []),
      ));

      expect(find.byType(Form), findsNothing);
    });

    testWidgets('omitting formKey still renders AutofillGroup and children',
        (tester) async {
      await tester.pumpWidget(_buildApp(
        const FormCard(children: [Text('No form')]),
      ));

      expect(find.byType(AutofillGroup), findsOneWidget);
      expect(find.text('No form'), findsOneWidget);
    });
  });
}
