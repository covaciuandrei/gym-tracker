import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/presentation/pages/calendar/widgets/membership_history_shortcut.dart';

void main() {
  testWidgets('uses a transparent error-colored icon and invokes the action', (tester) async {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, colorScheme: colorScheme),
        home: Scaffold(
          appBar: AppBar(
            actions: [MembershipHistoryShortcut(tooltip: 'Membership history', onPressed: () => pressed = true)],
          ),
        ),
      ),
    );

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.color, colorScheme.error);
    expect(button.style?.backgroundColor, isNull);
    expect(find.byTooltip('Membership history'), findsOneWidget);

    await tester.tap(find.byTooltip('Membership history'));
    expect(pressed, isTrue);
  });
}
