// Widget tests for SoftUpdateBanner.
//
// Run: flutter test test/presentation/controls/soft_update_banner_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/presentation/controls/soft_update_banner.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('SoftUpdateBanner', () {
    testWidgets('renders latest version and message', (tester) async {
      await tester.pumpWidget(_wrap(SoftUpdateBanner(latestVersion: '1.2.0', onUpdate: () {}, onDismiss: () {})));
      await tester.pumpAndSettle();

      expect(find.text('v1.2.0'), findsOneWidget);
      // English fallback message from ARB.
      expect(find.text('A new version is available.'), findsOneWidget);
    });

    testWidgets('tapping Update invokes onUpdate', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(
        _wrap(SoftUpdateBanner(latestVersion: '1.2.0', onUpdate: () => tapped++, onDismiss: () {})),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update'));
      expect(tapped, 1);
    });

    testWidgets('tapping close icon invokes onDismiss', (tester) async {
      var dismissed = 0;
      await tester.pumpWidget(
        _wrap(SoftUpdateBanner(latestVersion: '1.2.0', onUpdate: () {}, onDismiss: () => dismissed++)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, 1);
    });
  });
}
