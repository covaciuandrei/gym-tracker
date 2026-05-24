import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/presentation/controls/pull_to_refresh.dart';

void main() {
  testWidgets('PullToRefresh calls onRefresh after a pull gesture', (tester) async {
    var refreshCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PullToRefresh(
            onRefresh: () async {
              refreshCount++;
            },
            child: ListView(
              physics: PullToRefresh.alwaysScrollablePhysics,
              children: const [SizedBox(height: 80, child: Text('Content'))],
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.text('Content'), const Offset(0, 320));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(refreshCount, 1);
  });
}
