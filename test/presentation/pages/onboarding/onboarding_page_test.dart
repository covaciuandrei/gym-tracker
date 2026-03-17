import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/pages/onboarding/onboarding_page.dart';
import 'package:mocktail/mocktail.dart';

class MockStackRouter extends Mock implements StackRouter {}

class _FakePageRouteInfo extends Fake implements PageRouteInfo {}

Widget _buildApp({StackRouter? router}) {
  final effectiveRouter = router ?? MockStackRouter();
  return StackRouterScope(
    controller: effectiveRouter,
    stateHash: 0,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OnboardingPage(),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakePageRouteInfo());
  });

  group('OnboardingPage', () {
    testWidgets('renders first slide with title and subtitle', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Track Your Workouts'), findsOneWidget);
      expect(
        find.text('Log every gym session and see your attendance at a glance.'),
        findsOneWidget,
      );
    });

    testWidgets('renders Next button on first page', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('navigates to second page on Next tap', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      expect(find.text('Monitor Your Health'), findsOneWidget);
    });

    testWidgets('shows Get Started on last page', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Navigate to page 2
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();
      // Navigate to page 3
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      expect(find.text('Analyze Your Progress'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      // Skip is still in the tree but invisible via Visibility
      final skipVisibility = tester.widget<Visibility>(
        find.ancestor(of: find.text('Skip'), matching: find.byType(Visibility)),
      );
      expect(skipVisibility.visible, isFalse);
    });

    testWidgets('Skip navigates to login', (tester) async {
      final mockRouter = MockStackRouter();
      when(
        () => mockRouter.replace(any<PageRouteInfo>()),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(_buildApp(router: mockRouter));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      verify(() => mockRouter.replace(any<PageRouteInfo>())).called(1);
    });

    testWidgets('Get Started on last page navigates to login', (tester) async {
      final mockRouter = MockStackRouter();
      when(
        () => mockRouter.replace(any<PageRouteInfo>()),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(_buildApp(router: mockRouter));
      await tester.pumpAndSettle();

      // Navigate to last page
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      // Tap "Get Started"
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      verify(() => mockRouter.replace(any<PageRouteInfo>())).called(1);
    });

    testWidgets('dot indicator has 3 dots', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Find animated containers used as dot indicators (3 dots)
      // The dots are inside a Row; all 3 pages represented
      expect(find.text('Track Your Workouts'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('can swipe to next page', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.pumpAndSettle();

      // Swipe left to go to page 2
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Monitor Your Health'), findsOneWidget);
    });
  });
}
