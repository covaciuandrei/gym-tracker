import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/assets/theme/theme_helper.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/app_version_status.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/core/utils/legal_url_launcher.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/settings/settings_cubit.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';
import 'package:gym_tracker/presentation/controls/labeled_value_tile.dart';
import 'package:gym_tracker/presentation/controls/option_toggle.dart';
import 'package:gym_tracker/presentation/controls/surface_section_card.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';

@RoutePage()
class SettingsPage extends StatefulWidget implements AutoRouteWrapper {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(create: (_) => getIt<SettingsCubit>()),
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
      ],
      child: this,
    );
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final ThemeHelper _themeHelper = getIt<ThemeHelper>();
  final LocaleHelper _localeHelper = getIt<LocaleHelper>();
  final AppVersionStatus _versionStatus = getIt<AppVersionStatus>();

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().init();
  }

  void _onSignOut(BuildContext ctx) {
    ctx.read<AuthCubit>().signOut();
  }

  Future<void> _openUrl(String url) => launchLegalUrl(url);

  Future<void> _onDeleteAccount(BuildContext ctx) async {
    final password = await _showDeleteAccountDialog(ctx);
    if (password == null || password.isEmpty) return;
    if (!ctx.mounted) return;
    ctx.read<AuthCubit>().deleteAccount(currentPassword: password);
  }

  Future<String?> _showDeleteAccountDialog(BuildContext ctx) {
    final l10n = AppLocalizations.of(ctx);
    final cs = Theme.of(ctx).colorScheme;
    final controller = TextEditingController();

    return showDialog<String>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.settingsDeleteAccountTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsDeleteAccountMessage),
            const SizedBox(height: 16),
            CustomTextField(controller: controller, label: l10n.settingsDeleteAccountPasswordHint, isPassword: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: Text(l10n.calendarCancel)),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(controller.text),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: Text(l10n.settingsDeleteAccountConfirm),
          ),
        ],
      ),
    );
    // controller is intentionally not disposed here — the dialog's dismiss
    // animation still references the TextFormField/controller tree, so eager
    // disposal causes use-after-dispose. The controller has no external
    // subscriptions and will be garbage-collected shortly after the dialog
    // is fully removed.
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocListener<AuthCubit, BaseState>(
      listenWhen: (_, curr) =>
          curr is PendingState ||
          curr is AuthSignOutSuccessState ||
          curr is AuthAccountDeletedState ||
          curr is AuthInvalidCredentialsState ||
          curr is SomethingWentWrongState,
      listener: (ctx, state) {
        if (state is PendingState) {
          showDialog<void>(
            context: ctx,
            barrierDismissible: false,
            builder: (_) => const PopScope(canPop: false, child: Center(child: CircularProgressIndicator())),
          );
          return;
        }

        // Dismiss loading dialog if one is showing.
        if (Navigator.of(ctx).canPop()) {
          Navigator.of(ctx).pop();
        }

        if (state is AuthSignOutSuccessState || state is AuthAccountDeletedState) {
          ctx.router.replace(const LoginRoute());
          return;
        }
        if (state is AuthInvalidCredentialsState) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.errorsInvalidCredentials)));
          return;
        }
        if (state is SomethingWentWrongState) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.errorsUnknown)));
        }
      },
      child: BlocBuilder<SettingsCubit, BaseState>(
        buildWhen: (_, curr) => curr is PendingState || curr is SettingsReadyState,
        builder: (ctx, settingsState) {
          final version = settingsState is SettingsReadyState ? settingsState.appVersion : '-';

          return ListenableBuilder(
            listenable: Listenable.merge([_themeHelper, _localeHelper]),
            builder: (_, _) {
              return Scaffold(
                backgroundColor: cs.surfaceContainerLow,
                appBar: GymAppBar(title: l10n.settingsTitle),
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionHeader(title: l10n.settingsAbout.toUpperCase()),
                            SurfaceSectionCard(
                              children: [
                                LabeledValueTile(
                                  icon: Icons.info_outline,
                                  label: l10n.settingsAppVersion,
                                  value: version,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _SectionHeader(title: l10n.settingsLegal.toUpperCase()),
                            SurfaceSectionCard(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.description_outlined, color: cs.primary),
                                  title: Text(l10n.settingsTerms),
                                  trailing: Icon(Icons.open_in_new, color: cs.onSurfaceVariant, size: 20),
                                  onTap: () => _openUrl(_versionStatus.termsUrlFor(_localeHelper.locale.languageCode)),
                                ),
                                Divider(indent: 16, endIndent: 16, color: cs.outline, height: 1),
                                ListTile(
                                  leading: Icon(Icons.privacy_tip_outlined, color: cs.primary),
                                  title: Text(l10n.settingsPrivacy),
                                  trailing: Icon(Icons.open_in_new, color: cs.onSurfaceVariant, size: 20),
                                  onTap: () =>
                                      _openUrl(_versionStatus.privacyUrlFor(_localeHelper.locale.languageCode)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _SectionHeader(title: l10n.profileAccount.toUpperCase()),
                            SurfaceSectionCard(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.lock_outline, color: cs.primary),
                                  title: Text(l10n.settingsChangePassword),
                                  trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                                  onTap: () => ctx.router.push(const ChangePasswordRoute()),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _SectionHeader(title: l10n.settingsGeneral.toUpperCase()),
                            SurfaceSectionCard(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    _themeHelper.isDark ? Icons.dark_mode : Icons.light_mode,
                                    color: cs.primary,
                                  ),
                                  title: Text(l10n.settingsTheme),
                                  subtitle: Text(
                                    _themeHelper.isDark ? l10n.settingsThemeDark : l10n.settingsThemeLight,
                                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  trailing: Switch(
                                    value: _themeHelper.isDark,
                                    onChanged: (v) => _themeHelper.setDark(v),
                                    activeThumbColor: cs.primary,
                                  ),
                                ),
                                Divider(indent: 16, endIndent: 16, color: cs.outline, height: 1),
                                ListTile(
                                  leading: Icon(Icons.language, color: cs.primary),
                                  title: Text(l10n.settingsLanguage),
                                  subtitle: Text(
                                    _localeHelper.locale.languageCode == 'ro'
                                        ? l10n.settingsLanguageRo
                                        : l10n.settingsLanguageEn,
                                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  trailing: OptionToggle(
                                    selectedValue: _localeHelper.locale.languageCode,
                                    items: [
                                      OptionToggleItem(value: 'en', label: l10n.settingsLanguageEn),
                                      OptionToggleItem(value: 'ro', label: l10n.settingsLanguageRo),
                                    ],
                                    onSelect: (code) {
                                      _localeHelper.setLocale(Locale(code));
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _SectionHeader(title: l10n.settingsActions.toUpperCase()),
                            SurfaceSectionCard(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.logout, color: cs.primary),
                                  title: Text(l10n.settingsSignOut),
                                  onTap: () => _onSignOut(ctx),
                                ),
                                Divider(indent: 16, endIndent: 16, color: cs.outline, height: 1),
                                ListTile(
                                  leading: Icon(Icons.delete_forever, color: cs.error),
                                  title: Text(l10n.settingsDeleteAccount, style: TextStyle(color: cs.error)),
                                  onTap: () => _onDeleteAccount(ctx),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 1.2)),
    );
  }
}
