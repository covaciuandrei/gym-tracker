import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_tracker/presentation/controls/search_input.dart';

void main() {
  testWidgets('SearchInput renders hint and search icon', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchInput(controller: controller, hint: 'Search products...'),
        ),
      ),
    );

    expect(find.text('Search products...'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });
}
