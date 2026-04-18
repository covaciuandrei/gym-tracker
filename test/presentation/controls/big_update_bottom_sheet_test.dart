// Widget tests for BigUpdateBottomSheet.
//
// Covers:
//   1. Renders the localized title, body (with version interpolated),
//      "Update now" CTA, and "Remind me later" link.
//   2. Tapping the primary button invokes onUpdate.
//   3. Tapping "Remind me later" invokes onLater.
//
// Run:  flutter test test/presentation/controls/big_update_bottom_sheet_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/presentation/controls/big_update_bottom_sheet.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('BigUpdateBottomSheet', () {
    testWidgets('renders title, body with version, and both actions', (tester) async {
      await tester.pumpWidget(_wrap(BigUpdateBottomSheet(latestVersion: '3.0.0', onUpdate: () {}, onLater: () {})));

      // Title + CTA copy come from the EN ARB. The body interpolates the
      // version string so it is guaranteed to appear somewhere on screen.
      expect(find.text('A big update is here'), findsOneWidget);
      expect(find.text('Update now'), findsOneWidget);
      expect(find.text('Remind me later'), findsOneWidget);
      expect(find.textContaining('3.0.0'), findsOneWidget);
    });

    testWidgets('tapping "Update now" invokes onUpdate', (tester) async {
      var updateCount = 0;
      await tester.pumpWidget(
        _wrap(BigUpdateBottomSheet(latestVersion: '3.0.0', onUpdate: () => updateCount++, onLater: () {})),
      );

      await tester.tap(find.text('Update now'));
      await tester.pump();
      expect(updateCount, 1);
    });

    testWidgets('tapping "Remind me later" invokes onLater', (tester) async {
      var laterCount = 0;
      await tester.pumpWidget(
        _wrap(BigUpdateBottomSheet(latestVersion: '3.0.0', onUpdate: () {}, onLater: () => laterCount++)),
      );

      await tester.tap(find.text('Remind me later'));
      await tester.pump();
      expect(laterCount, 1);
    });
  });
}
