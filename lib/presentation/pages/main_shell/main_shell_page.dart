import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/app_version_status.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/soft_update_banner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class MainShellPage extends StatefulWidget implements AutoRouteWrapper {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>(), child: this);
  }
}

class _MainShellPageState extends State<MainShellPage> {
  /// SharedPreferences key holding the [AppVersionStatus.latestVersion] for
  /// which the user has dismissed the soft-update banner. The banner reappears
  /// only when remote config advertises a newer version.
  static const String _dismissedPrefsKey = 'soft_update_dismissed_for_version';

  bool _bannerVisible = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().watchAuthState();
    _evaluateBannerVisibility();
  }

  Future<void> _evaluateBannerVisibility() async {
    final status = getIt<AppVersionStatus>();
    if (!status.softUpdateAvailable || status.latestVersion.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final dismissedFor = prefs.getString(_dismissedPrefsKey);
    if (!mounted) return;
    if (dismissedFor == status.latestVersion) return;
    setState(() => _bannerVisible = true);
  }

  Future<void> _onBannerDismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedPrefsKey, getIt<AppVersionStatus>().latestVersion);
    if (!mounted) return;
    setState(() => _bannerVisible = false);
  }

  Future<void> _onBannerUpdate() async {
    final url = getIt<AppVersionStatus>().storeUrl;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthCubit, BaseState>(
      listenWhen: (_, curr) => curr is AuthSignOutSuccessState || curr is AuthUnauthenticatedState,
      listener: (ctx, _) {
        ctx.router.replace(const LoginRoute());
      },
      child: AutoTabsScaffold(
        routes: [CalendarRoute(), StatsRoute(), HealthRoute(), ProfileRoute()],
        appBarBuilder: _bannerVisible
            ? (ctx, _) => PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: SafeArea(
                  bottom: false,
                  child: SoftUpdateBanner(
                    latestVersion: getIt<AppVersionStatus>().latestVersion,
                    onUpdate: _onBannerUpdate,
                    onDismiss: _onBannerDismiss,
                  ),
                ),
              )
            : null,
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
