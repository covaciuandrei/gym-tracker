// Widget tests for LegalConsentCheckbox.
//
// The control reads LocaleHelper and AppVersionStatus via getIt; tests
// register real instances (SharedPreferences mocked) before pumping.
//
// url_launcher is a plugin and cannot be exercised from a unit test, so these
// tests do NOT verify that tapping a link actually opens the URL; they only
// assert that the tappable link spans are present and that parent-owned state
// (checkbox value + error visibility) flows correctly.
//
// Run: flutter test test/presentation/controls/legal_consent_checkbox_test.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_version_status.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/presentation/controls/legal_consent_checkbox.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(16), child: child),
  ),
);

Future<void> _registerDeps({String languageCode = 'en'}) async {
  SharedPreferences.setMockInitialValues({'app_locale': languageCode});
  final prefs = await SharedPreferences.getInstance();

  if (getIt.isRegistered<LocaleHelper>()) {
    getIt.unregister<LocaleHelper>();
  }
  if (getIt.isRegistered<AppVersionStatus>()) {
    getIt.unregister<AppVersionStatus>();
  }
  getIt.registerSingleton<LocaleHelper>(LocaleHelper(prefs));
  getIt.registerSingleton<AppVersionStatus>(AppVersionStatus());
}

void main() {
  tearDown(() {
    if (getIt.isRegistered<LocaleHelper>()) {
      getIt.unregister<LocaleHelper>();
    }
    if (getIt.isRegistered<AppVersionStatus>()) {
      getIt.unregister<AppVersionStatus>();
    }
  });

  group('LegalConsentCheckbox', () {
    testWidgets('renders checkbox and consent text with Terms + Privacy links', (tester) async {
      await _registerDeps();
      final accepted = ValueNotifier<bool>(false);
      final showError = ValueNotifier<bool>(false);
      addTearDown(() {
        accepted.dispose();
        showError.dispose();
      });

      await tester.pumpWidget(_wrap(LegalConsentCheckbox(accepted: accepted, showError: showError)));

      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.textContaining('I have read and agree to the'), findsOneWidget);
      // Inline link labels appear as spans inside the Text.rich.
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('tapping the checkbox toggles accepted', (tester) async {
      await _registerDeps();
      final accepted = ValueNotifier<bool>(false);
      final showError = ValueNotifier<bool>(false);
      addTearDown(() {
        accepted.dispose();
        showError.dispose();
      });

      await tester.pumpWidget(_wrap(LegalConsentCheckbox(accepted: accepted, showError: showError)));

      expect(accepted.value, isFalse);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(accepted.value, isTrue);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(accepted.value, isFalse);
    });

    testWidgets('tapping row toggles accepted (wider tap target)', (tester) async {
      await _registerDeps();
      final accepted = ValueNotifier<bool>(false);
      final showError = ValueNotifier<bool>(false);
      addTearDown(() {
        accepted.dispose();
        showError.dispose();
      });

      await tester.pumpWidget(_wrap(LegalConsentCheckbox(accepted: accepted, showError: showError)));

      // Tapping the surrounding InkWell also toggles.
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(accepted.value, isTrue);
    });

    testWidgets('toggling on clears showError', (tester) async {
      await _registerDeps();
      final accepted = ValueNotifier<bool>(false);
      final showError = ValueNotifier<bool>(true);
      addTearDown(() {
        accepted.dispose();
        showError.dispose();
      });

      await tester.pumpWidget(_wrap(LegalConsentCheckbox(accepted: accepted, showError: showError)));

      expect(showError.value, isTrue);
      expect(find.text('You must accept the Terms of Service and Privacy Policy to continue.'), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(accepted.value, isTrue);
      expect(showError.value, isFalse);
      expect(find.text('You must accept the Terms of Service and Privacy Policy to continue.'), findsNothing);
    });

    testWidgets('showError=true renders the required-message text', (tester) async {
      await _registerDeps();
      final accepted = ValueNotifier<bool>(false);
      final showError = ValueNotifier<bool>(false);
      addTearDown(() {
        accepted.dispose();
        showError.dispose();
      });

      await tester.pumpWidget(_wrap(LegalConsentCheckbox(accepted: accepted, showError: showError)));

      expect(find.text('You must accept the Terms of Service and Privacy Policy to continue.'), findsNothing);

      showError.value = true;
      await tester.pump();

      expect(find.text('You must accept the Terms of Service and Privacy Policy to continue.'), findsOneWidget);
    });

    testWidgets('disabled=true prevents toggling via tap', (tester) async {
      await _registerDeps();
      final accepted = ValueNotifier<bool>(false);
      final showError = ValueNotifier<bool>(false);
      addTearDown(() {
        accepted.dispose();
        showError.dispose();
      });

      await tester.pumpWidget(_wrap(LegalConsentCheckbox(accepted: accepted, showError: showError, enabled: false)));

      await tester.tap(find.byType(Checkbox), warnIfMissed: false);
      await tester.pump();

      expect(accepted.value, isFalse);
    });

    testWidgets('link spans carry a TapGestureRecognizer', (tester) async {
      await _registerDeps();
      final accepted = ValueNotifier<bool>(false);
      final showError = ValueNotifier<bool>(false);
      addTearDown(() {
        accepted.dispose();
        showError.dispose();
      });

      await tester.pumpWidget(_wrap(LegalConsentCheckbox(accepted: accepted, showError: showError)));

      // Drill into the Text.rich to confirm each link span carries a
      // recognizer. We don't invoke it (url_launcher is a plugin).
      final richText = tester.widget<RichText>(
        find.descendant(of: find.byType(LegalConsentCheckbox), matching: find.byType(RichText)).first,
      );
      final recognizers = <TapGestureRecognizer>[];
      richText.text.visitChildren((span) {
        if (span is TextSpan && span.recognizer is TapGestureRecognizer) {
          recognizers.add(span.recognizer! as TapGestureRecognizer);
        }
        return true;
      });

      expect(recognizers.length, greaterThanOrEqualTo(2));
    });

    testWidgets('switches label copy when locale changes to ro', (tester) async {
      await _registerDeps(languageCode: 'ro');
      final accepted = ValueNotifier<bool>(false);
      final showError = ValueNotifier<bool>(false);
      addTearDown(() {
        accepted.dispose();
        showError.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ro'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: LegalConsentCheckbox(accepted: accepted, showError: showError),
            ),
          ),
        ),
      );

      expect(find.textContaining('Am citit și sunt de acord cu'), findsOneWidget);
    });
  });
}
