import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';

/// Blocks navigation to authenticated-only routes when no Firebase user is
/// signed in, redirecting to [LoginRoute].
///
/// Replaces the previous pattern of every page checking
/// `FirebaseAuth.instance.currentUser == null` in its `build()` and scheduling
/// a post-frame `context.router.replace(LoginRoute)`.
class AuthGuard extends AutoRouteGuard {
  AuthGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final user = getIt<FirebaseAuth>().currentUser;
    if (user != null) {
      resolver.next(true);
      return;
    }
    router.replace(const LoginRoute());
    resolver.next(false);
  }
}
