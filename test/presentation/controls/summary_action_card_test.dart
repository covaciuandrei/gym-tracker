import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_tracker/presentation/controls/summary_action_card.dart';

void main() {
  testWidgets('SummaryActionCard renders text and actions', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SummaryActionCard(
            title: 'Magnesium',
            subtitle: 'Brand',
            description: '200mg Magnesium Citrate',
            onTap: () => tapped = true,
            actions: [TextButton(onPressed: () {}, child: const Text('Edit'))],
          ),
        ),
      ),
    );

    expect(find.text('Magnesium'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);
    expect(find.text('200mg Magnesium Citrate'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    await tester.tap(find.text('Magnesium'));
    await tester.pump();

    expect(tapped, true);
  });
}
