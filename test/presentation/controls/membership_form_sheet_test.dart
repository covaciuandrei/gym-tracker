import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/presentation/controls/membership_form_sheet.dart';

void main() {
  testWidgets('renders initial membership details and returns a draft', (tester) async {
    GymMembershipDraft? result;
    final initial = GymMembershipDraft(
      gymName: 'Test Gym',
      startDate: DateTime(2026, 7, 22),
      duration: MembershipDuration.oneMonth,
      priceMinor: 15000,
      currency: 'RON',
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await showDialog<GymMembershipDraft>(
                  context: context,
                  builder: (_) => MembershipFormSheet(title: 'Add membership', initial: initial),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Test Gym'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
    expect(find.text('RON'), findsOneWidget);
    expect(find.text('22.07.2026'), findsOneWidget);
    expect(find.text('Valid until 21.08.2026'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.gymName, 'Test Gym');
    expect(result!.priceMinor, 15000);
    expect(result!.validUntil, DateTime(2026, 8, 21));
  });
}
