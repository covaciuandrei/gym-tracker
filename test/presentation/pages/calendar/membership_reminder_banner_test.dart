import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/presentation/pages/calendar/widgets/membership_reminder_banner.dart';

void main() {
  Widget buildSubject({required GymMembership? membership}) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MembershipReminderBanner(membership: membership, onAction: () {}, onDismiss: () {}),
      ),
    );
  }

  testWidgets('shows add action when no membership exists', (tester) async {
    await tester.pumpWidget(buildSubject(membership: null));

    expect(find.text('No membership recorded'), findsOneWidget);
    expect(find.text('Add membership'), findsOneWidget);
  });

  testWidgets('shows renewal action for an expired membership', (tester) async {
    final membership = GymMembership(
      id: 'membership_1',
      gymName: 'Test Gym',
      startDate: DateTime(2025, 1, 1),
      durationMonths: 1,
      validUntil: DateTime(2025, 2, 1),
      priceMinor: 15000,
      currency: 'RON',
    );

    await tester.pumpWidget(buildSubject(membership: membership));

    expect(find.text('Membership expired'), findsOneWidget);
    expect(find.text('Renew membership'), findsOneWidget);
    expect(find.textContaining('Test Gym expired on 01.02.2025'), findsOneWidget);
  });
}
