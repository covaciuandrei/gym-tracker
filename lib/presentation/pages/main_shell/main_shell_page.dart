import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/app_version_status.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/big_update_bottom_sheet.dart';
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
  /// which the user last tapped "Remind me later". Paired with
  /// [_dismissedAtPrefsKey] to enforce a 3-day cool-down before re-showing
  /// the bottom sheet for the same version.
  static const String _dismissedVersionPrefsKey = 'big_update_dismissed_version';

  /// SharedPreferences key storing the UTC epoch millis at which the user
  /// last dismissed the big-update bottom sheet for [_dismissedVersionPrefsKey].
  static const String _dismissedAtPrefsKey = 'big_update_dismissed_at_ms';

  /// How long a per-version "Remind me later" dismissal is honored before the
  /// bottom sheet becomes eligible to re-appear.
  static const Duration _dismissalCoolDown = Duration(days: 3);

  /// Delay before presenting the big-update bottom sheet after the shell has
  /// mounted. Gives the home tab a moment to paint so the sheet slides in on
  /// top of a settled UI instead of competing with first-frame layout.
  static const Duration _bottomSheetPresentationDelay = Duration(seconds: 5);

  bool _bottomSheetShown = false;

  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().watchAuthState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowBigUpdateSheet());
  }

  /// Decides whether to show the big-update bottom sheet on first main-shell
  /// open. Skips when:
  ///   * no big jump was detected by the splash cubit,
  ///   * `latestVersion` is empty (should not happen in ok state),
  ///   * the sheet was already shown this frame, or
  ///   * the user dismissed the same version within [_dismissalCoolDown].
  Future<void> _maybeShowBigUpdateSheet() async {
    if (_bottomSheetShown) return;
    final status = getIt<AppVersionStatus>();
    if (!status.bigUpdateAvailable || status.latestVersion.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final dismissedVersion = prefs.getString(_dismissedVersionPrefsKey);
    final dismissedAtMs = prefs.getInt(_dismissedAtPrefsKey);
    if (dismissedVersion == status.latestVersion && dismissedAtMs != null) {
      final dismissedAt = DateTime.fromMillisecondsSinceEpoch(dismissedAtMs);
      if (DateTime.now().difference(dismissedAt) < _dismissalCoolDown) return;
    }

    await Future<void>.delayed(_bottomSheetPresentationDelay);
    if (!mounted) return;
    _bottomSheetShown = true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetCtx) => BigUpdateBottomSheet(
        latestVersion: status.latestVersion,
        onUpdate: () {
          Navigator.of(sheetCtx).pop();
          _launchStoreUrl();
        },
        onLater: () {
          Navigator.of(sheetCtx).pop();
          _persistDismissal();
        },
      ),
    );
  }

  Future<void> _persistDismissal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedVersionPrefsKey, getIt<AppVersionStatus>().latestVersion);
    await prefs.setInt(_dismissedAtPrefsKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _launchStoreUrl() async {
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
