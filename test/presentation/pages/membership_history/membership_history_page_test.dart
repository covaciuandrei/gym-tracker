import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/cubit/membership/membership_cubit.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/presentation/pages/membership_history/membership_history_page.dart';
import 'package:gym_tracker/service/membership/gym_membership_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGymMembershipService extends Mock implements GymMembershipService {}

void main() {
  Widget buildSubject({required MembershipCubit cubit, bool startAddFlow = false}) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<MembershipCubit>.value(
        value: cubit,
        child: MembershipHistoryView(userId: 'user_1', startAddFlow: startAddFlow, showBackButton: false),
      ),
    );
  }

  testWidgets('add flow offers to copy the latest membership', (tester) async {
    const userId = 'user_1';
    final membership = GymMembership(
      id: 'membership_1',
      gymName: 'Test Gym',
      startDate: DateTime(2026, 1, 1),
      durationMonths: 1,
      validUntil: DateTime(2026, 2, 1),
      priceMinor: 15000,
      currency: 'RON',
    );
    final service = MockGymMembershipService();
    when(() => service.getAll(userId: userId)).thenAnswer((_) async => [membership]);
    final cubit = MembershipCubit(service);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit: cubit));
    await tester.pumpAndSettle();

    expect(find.text('Test Gym'), findsOneWidget);
    expect(find.text('01.01.2026 – 01.02.2026'), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Reuse your last membership details?'), findsOneWidget);
    await tester.tap(find.text('Copy last details'));
    await tester.pumpAndSettle();

    expect(find.text('Renew membership'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
    expect(find.text('RON'), findsOneWidget);
  });

  testWidgets('empty history uses only the centered add action', (tester) async {
    const userId = 'user_1';
    final service = MockGymMembershipService();
    when(() => service.getAll(userId: userId)).thenAnswer((_) async => []);
    final cubit = MembershipCubit(service);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit: cubit));
    await tester.pumpAndSettle();

    expect(find.text('Add first membership'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('startAddFlow opens the blank form directly when history is empty', (tester) async {
    const userId = 'user_1';
    final service = MockGymMembershipService();
    when(() => service.getAll(userId: userId)).thenAnswer((_) async => []);
    final cubit = MembershipCubit(service);
    addTearDown(cubit.close);

    await tester.pumpWidget(buildSubject(cubit: cubit, startAddFlow: true));
    await tester.pumpAndSettle();

    expect(find.text('Add membership'), findsWidgets);
    expect(find.text('Gym name'), findsOneWidget);
    expect(find.text('Reuse your last membership details?'), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
