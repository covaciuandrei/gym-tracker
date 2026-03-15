import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/health/health_cubit.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'package:gym_tracker/presentation/pages/health/health_page.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthCubit extends Mock implements HealthCubit {}

class MockStackRouter extends Mock implements StackRouter {}

Future<void> _pumpSkeletonWindow(WidgetTester tester) {
  return tester.pump(const Duration(milliseconds: 320));
}

Widget _buildApp({required HealthCubit cubit, required StackRouter router}) {
  return StackRouterScope(
    controller: router,
    stateHash: 0,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<HealthCubit>.value(
        value: cubit,
        child: const HealthPage(testUserId: 'user-1'),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const InitialState());
    registerFallbackValue(const SupplementLog(id: 'log-1', date: '2026-03-13', productId: 'p-1', servingsTaken: 1));
    registerFallbackValue(
      const SupplementProduct(
        id: 'p-1',
        name: 'Magnesium',
        brand: 'Brand',
        ingredients: [],
        servingsPerDayDefault: 1,
        createdBy: 'user-1',
      ),
    );
  });

  MockHealthCubit stubCubit(Stream<BaseState> stream) {
    final cubit = MockHealthCubit();
    when(() => cubit.state).thenReturn(const InitialState());
    when(() => cubit.stream).thenAnswer((_) => stream);
    when(() => cubit.loadProducts(any())).thenReturn(null);
    when(
      () => cubit.loadDayEntries(
        userId: any(named: 'userId'),
        date: any(named: 'date'),
      ),
    ).thenReturn(null);
    when(
      () => cubit.logSupplement(
        userId: any(named: 'userId'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => cubit.deleteEntry(
        userId: any(named: 'userId'),
        date: any(named: 'date'),
        entryId: any(named: 'entryId'),
      ),
    ).thenAnswer((_) async {});
    when(() => cubit.deleteProduct(any())).thenAnswer((_) async {});
    when(
      () => cubit.saveProduct(
        userId: any(named: 'userId'),
        model: any(named: 'model'),
        isEdit: any(named: 'isEdit'),
      ),
    ).thenAnswer((_) async {});
    return cubit;
  }

  group('HealthPage', () {
    testWidgets('loads only day entries on init', (tester) async {
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);
      final cubit = stubCubit(controller.stream);
      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(false);

      await tester.pumpWidget(_buildApp(cubit: cubit, router: router));
      await tester.pump();

      verifyNever(() => cubit.loadProducts('user-1'));
      verify(
        () => cubit.loadDayEntries(
          userId: 'user-1',
          date: any(named: 'date'),
        ),
      ).called(1);
    });

    testWidgets('shows empty today state when no logs', (tester) async {
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);
      final cubit = stubCubit(controller.stream);
      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(false);

      await tester.pumpWidget(_buildApp(cubit: cubit, router: router));
      await tester.pump();

      controller.add(const HealthProductsLoadedState(products: [], myProducts: []));
      controller.add(const HealthDayEntriesLoadedState(entries: [], date: '2026-03-13'));
      await tester.pump();
      await _pumpSkeletonWindow(tester);

      expect(find.text('No supplements logged today'), findsOneWidget);
    });

    testWidgets('switches to my supplements tab and shows search', (tester) async {
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);
      final cubit = stubCubit(controller.stream);
      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(false);

      await tester.pumpWidget(_buildApp(cubit: cubit, router: router));
      await tester.pump();

      controller.add(
        const HealthProductsLoadedState(
          products: [
            SupplementProduct(
              id: 'p-1',
              name: 'Magnesium',
              brand: 'Brand',
              ingredients: [],
              servingsPerDayDefault: 1,
              createdBy: 'user-1',
            ),
          ],
          myProducts: [
            SupplementProduct(
              id: 'p-1',
              name: 'Magnesium',
              brand: 'Brand',
              ingredients: [],
              servingsPerDayDefault: 1,
              createdBy: 'user-1',
            ),
          ],
        ),
      );
      controller.add(const HealthDayEntriesLoadedState(entries: [], date: '2026-03-13'));
      await tester.pump();
      await _pumpSkeletonWindow(tester);

      await tester.tap(find.text('My Supplements'));
      await tester.pump();

      controller.add(
        const HealthProductsLoadedState(
          products: [
            SupplementProduct(
              id: 'p-1',
              name: 'Magnesium',
              brand: 'Brand',
              ingredients: [],
              servingsPerDayDefault: 1,
              createdBy: 'user-1',
            ),
          ],
          myProducts: [
            SupplementProduct(
              id: 'p-1',
              name: 'Magnesium',
              brand: 'Brand',
              ingredients: [],
              servingsPerDayDefault: 1,
              createdBy: 'user-1',
            ),
          ],
        ),
      );
      await tester.pump();
      await _pumpSkeletonWindow(tester);

      expect(find.text('Search my supplements...'), findsOneWidget);
      expect(find.text('Magnesium'), findsOneWidget);
    });

    testWidgets('logs supplement from all supplements tab', (tester) async {
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);
      final cubit = stubCubit(controller.stream);
      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(false);

      await tester.pumpWidget(_buildApp(cubit: cubit, router: router));
      await tester.pump();

      controller.add(
        const HealthProductsLoadedState(
          products: [
            SupplementProduct(
              id: 'p-1',
              name: 'Magnesium',
              brand: 'Brand',
              ingredients: [],
              servingsPerDayDefault: 1,
              createdBy: 'user-1',
            ),
          ],
          myProducts: [
            SupplementProduct(
              id: 'p-1',
              name: 'Magnesium',
              brand: 'Brand',
              ingredients: [],
              servingsPerDayDefault: 1,
              createdBy: 'user-1',
            ),
          ],
        ),
      );
      controller.add(const HealthDayEntriesLoadedState(entries: [], date: '2026-03-13'));
      await tester.pump();
      await _pumpSkeletonWindow(tester);

      await tester.tap(find.text('All Supplements'));
      await tester.pump();

      controller.add(
        const HealthProductsLoadedState(
          products: [
            SupplementProduct(
              id: 'p-1',
              name: 'Magnesium',
              brand: 'Brand',
              ingredients: [],
              servingsPerDayDefault: 1,
              createdBy: 'user-1',
            ),
          ],
          myProducts: [
            SupplementProduct(
              id: 'p-1',
              name: 'Magnesium',
              brand: 'Brand',
              ingredients: [],
              servingsPerDayDefault: 1,
              createdBy: 'user-1',
            ),
          ],
        ),
      );
      await tester.pump();
      await _pumpSkeletonWindow(tester);

      await tester.tap(find.text('Magnesium'));
      await tester.pump();

      verify(
        () => cubit.logSupplement(
          userId: 'user-1',
          model: any(named: 'model'),
        ),
      ).called(1);
    });
  });
}
