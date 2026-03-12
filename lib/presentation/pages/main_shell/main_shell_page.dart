import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';

@RoutePage()
class MainShellPage extends StatefulWidget implements AutoRouteWrapper {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: this,
    );
  }
}

class _MainShellPageState extends State<MainShellPage> {
  @override
  void initState() {
    super.initState();
    // Start streaming Firebase auth changes so the shell can react to
    // token expiry or externally-triggered sign-outs.
    context.read<AuthCubit>().watchAuthState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthCubit, BaseState>(
      listenWhen: (_, curr) =>
          curr is AuthSignOutSuccessState || curr is AuthUnauthenticatedState,
      listener: (ctx, _) {
        // The stack is already clean when inside the shell (previous screens
        // used replace/replaceAll before landing here), so a simple replace
        // is sufficient to return to the login page.
        ctx.router.replace(const LoginRoute());
      },
      child: AutoTabsScaffold(
        routes: const [
          CalendarRoute(),
          StatsRoute(),
          HealthRoute(),
          ProfileRoute(),
        ],
        bottomNavigationBuilder: (_, tabsRouter) {
          return NavigationBar(
            selectedIndex: tabsRouter.activeIndex,
            onDestinationSelected: tabsRouter.setActiveIndex,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: l10n.navCalendar,
              ),
              NavigationDestination(
                icon: const Icon(Icons.bar_chart_outlined),
                selectedIcon: const Icon(Icons.bar_chart),
                label: l10n.navStats,
              ),
              NavigationDestination(
                icon: const Icon(Icons.medication_outlined),
                selectedIcon: const Icon(Icons.medication),
                label: l10n.navHealth,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: l10n.navProfile,
              ),
            ],
          );
        },
      ),
    );
  }
}
