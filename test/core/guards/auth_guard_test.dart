import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/guards/auth_guard.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

class MockNavigationResolver extends Mock implements NavigationResolver {}

class MockStackRouter extends Mock implements StackRouter {}

void main() {
  setUpAll(() => registerFallbackValue(const LoginRoute()));

  late MockFirebaseAuth auth;
  late MockNavigationResolver resolver;
  late MockStackRouter router;

  setUp(() async {
    await getIt.reset();
    auth = MockFirebaseAuth();
    resolver = MockNavigationResolver();
    router = MockStackRouter();
    getIt.registerSingleton<FirebaseAuth>(auth);
    when(() => resolver.next(any())).thenReturn(null);
    when(() => router.replace(any<PageRouteInfo>(), onFailure: any(named: 'onFailure'))).thenAnswer((_) async => null);
  });

  tearDown(() => getIt.reset());

  test('allows a verified Firebase user', () {
    final user = MockFirebaseUser();
    when(() => user.emailVerified).thenReturn(true);
    when(() => auth.currentUser).thenReturn(user);

    AuthGuard().onNavigation(resolver, router);

    verify(() => resolver.next(true)).called(1);
    verifyNever(() => router.replace(any<PageRouteInfo>(), onFailure: any(named: 'onFailure')));
  });

  test('redirects an unverified Firebase user to login', () {
    final user = MockFirebaseUser();
    when(() => user.emailVerified).thenReturn(false);
    when(() => auth.currentUser).thenReturn(user);

    AuthGuard().onNavigation(resolver, router);

    verify(() => router.replace(const LoginRoute(), onFailure: any(named: 'onFailure'))).called(1);
    verify(() => resolver.next(false)).called(1);
  });

  test('redirects when no Firebase user exists', () {
    when(() => auth.currentUser).thenReturn(null);

    AuthGuard().onNavigation(resolver, router);

    verify(() => router.replace(const LoginRoute(), onFailure: any(named: 'onFailure'))).called(1);
    verify(() => resolver.next(false)).called(1);
  });
}
