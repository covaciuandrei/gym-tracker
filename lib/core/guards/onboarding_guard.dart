import 'package:auto_route/auto_route.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/presentation/helpers/onboarding_helper.dart';

/// Blocks navigation to post-onboarding routes (e.g. [MainShellRoute]) when
/// the user has not yet completed the first-launch onboarding, redirecting
/// to [OnboardingRoute].
///
/// In normal flow the [SplashCubit] already routes first-launchers to
/// onboarding. This guard is defense-in-depth for direct deep links and for
/// the rare case where onboarding has not been completed but the user lands
/// on an authenticated route.
class OnboardingGuard extends AutoRouteGuard {
  OnboardingGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final isFirstLaunch = getIt<OnboardingHelper>().isFirstLaunch;
    if (!isFirstLaunch) {
      resolver.next(true);
      return;
    }
    router.replace(const OnboardingRoute());
    resolver.next(false);
  }
}
