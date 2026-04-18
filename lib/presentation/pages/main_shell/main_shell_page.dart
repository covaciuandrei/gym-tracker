import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/checking_update/checking_update_cubit.dart';
import 'package:gym_tracker/presentation/controls/big_update_bottom_sheet.dart';

@RoutePage()
class MainShellPage extends StatefulWidget implements AutoRouteWrapper {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<CheckingUpdateCubit>(create: (_) => getIt<CheckingUpdateCubit>()),
      ],
      child: this,
    );
  }
}

class _MainShellPageState extends State<MainShellPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().watchAuthState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CheckingUpdateCubit>().evaluate();
    });
  }

  void _onCheckingUpdateState(BuildContext context, BaseState state) {
    if (state is! CheckingUpdateShowSheetState) return;
    final cubit = context.read<CheckingUpdateCubit>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) => BigUpdateBottomSheet(
        latestVersion: state.latestVersion,
        onUpdate: () {
          Navigator.of(sheetCtx).pop();
          cubit.updateNow();
        },
        onLater: () {
          Navigator.of(sheetCtx).pop();
          cubit.remindLater();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, BaseState>(
          listenWhen: (_, curr) => curr is AuthSignOutSuccessState || curr is AuthUnauthenticatedState,
          listener: (ctx, _) {
            ctx.router.replace(const LoginRoute());
          },
        ),
        BlocListener<CheckingUpdateCubit, BaseState>(
          listenWhen: (_, curr) => curr is CheckingUpdateShowSheetState,
          listener: _onCheckingUpdateState,
        ),
      ],
      child: AutoTabsScaffold(
        routes: [CalendarRoute(), StatsRoute(), HealthRoute(), ProfileRoute()],
        bottomNavigationBuilder: (_, tabsRouter) {
          final cs = Theme.of(context).colorScheme;
          final destinations = [
            (icon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month, label: l10n.navCalendar),
            (icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart, label: l10n.navStats),
            (icon: Icons.medication_outlined, selectedIcon: Icons.medication, label: l10n.navHealth),
            (icon: Icons.person_outline, selectedIcon: Icons.person, label: l10n.navProfile),
          ];

          return DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: SizedBox(
                  height: 80,
                  child: Row(
                    children: List.generate(destinations.length, (index) {
                      final item = destinations[index];
                      final isSelected = tabsRouter.activeIndex == index;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 12),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => tabsRouter.setActiveIndex(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                decoration: BoxDecoration(
                                  color: isSelected ? cs.primaryContainer.withValues(alpha: 0.45) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: isSelected ? cs.primary : Colors.transparent, width: 1.6),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isSelected ? item.selectedIcon : item.icon,
                                      size: 22,
                                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                        color: isSelected ? cs.primary : cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
