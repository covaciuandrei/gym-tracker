import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/assets/theme/theme_helper.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/settings/settings_cubit.dart';
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
        BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>()),
        BlocProvider<SettingsCubit>(create: (_) => getIt<SettingsCubit>()),
      ],
      child: this,
    );
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final ThemeHelper _themeHelper = getIt<ThemeHelper>();
  final LocaleHelper _localeHelper = getIt<LocaleHelper>();

  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<AuthCubit, BaseState>(
      listenWhen: (_, curr) =>
          curr is AuthSignOutSuccessState ||
          curr is AuthUnauthenticatedState ||
          curr is SomethingWentWrongState,
      listener: (ctx, state) {
        if (state is AuthSignOutSuccessState ||
            state is AuthUnauthenticatedState) {
          ctx.router.replace(const LoginRoute());
          return;
        }
        if (state is SomethingWentWrongState) {
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(SnackBar(content: Text(l10n.errorsUnknown)));
        }
      },
      builder: (ctx, state) {
        final isSigningOut = state is PendingState;

        return BlocBuilder<SettingsCubit, BaseState>(
          buildWhen: (_, curr) =>
              curr is PendingState || curr is SettingsReadyState,
          builder: (ctx, settingsState) {
            final version = settingsState is SettingsReadyState
                ? settingsState.appVersion
                : '-';

            return ListenableBuilder(
              listenable: Listenable.merge([_themeHelper, _localeHelper]),
              builder: (_, __) {
                return Scaffold(
                  backgroundColor: cs.surfaceContainerLow,
                  appBar: AppBar(title: Text(l10n.settingsTitle)),
                  body: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionHeader(
                                title: l10n.settingsAbout.toUpperCase(),
                              ),
                              _SettingsCard(
                                children: [
                                  _InfoTile(
                                    icon: Icons.info_outline,
                                    label: l10n.settingsAppVersion,
                                    value: version,
                                  ),
                                  Divider(
                                    indent: 16,
                                    endIndent: 16,
                                    color: cs.outline,
                                    height: 1,
                                  ),
                                  _InfoTile(
                                    icon: Icons.code,
                                    label: l10n.settingsBuiltWith,
                                    value: 'Flutter + Firebase',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _SectionHeader(
                                title: l10n.settingsSecurity.toUpperCase(),
                              ),
                              _SettingsCard(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      Icons.lock_outline,
                                      color: cs.primary,
                                    ),
                                    title: Text(l10n.settingsChangePassword),
                                    subtitle: Text(
                                      '••••••••',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                    trailing: TextButton(
                                      onPressed: () => ctx.router.push(
                                        const ChangePasswordRoute(),
                                      ),
                                      child: Text(l10n.settingsChangePassword),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _SectionHeader(
                                title: l10n.settingsGeneral.toUpperCase(),
                              ),
                              _SettingsCard(
                                children: [
                                  ListTile(
                                    leading: Icon(
                                      _themeHelper.isDark
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                      color: cs.primary,
                                    ),
                                    title: Text(l10n.settingsTheme),
                                    subtitle: Text(
                                      _themeHelper.isDark
                                          ? l10n.settingsThemeDark
                                          : l10n.settingsThemeLight,
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                    trailing: Switch(
                                      value: _themeHelper.isDark,
                                      onChanged: (v) => _themeHelper.setDark(v),
                                      activeColor: cs.primary,
                                    ),
                                  ),
                                  Divider(
                                    indent: 16,
                                    endIndent: 16,
                                    color: cs.outline,
                                    height: 1,
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.language,
                                      color: cs.primary,
                                    ),
                                    title: Text(l10n.settingsLanguage),
                                    subtitle: Text(
                                      _localeHelper.locale.languageCode == 'ro'
                                          ? l10n.settingsLanguageRo
                                          : l10n.settingsLanguageEn,
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                    trailing: _LanguageToggle(
                                      currentCode:
                                          _localeHelper.locale.languageCode,
                                      onSelect: (code) =>
                                          _localeHelper.setLocale(Locale(code)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Center(
                                child: TextButton(
                                  onPressed: isSigningOut
                                      ? null
                                      : () => ctx.read<AuthCubit>().signOut(),
                                  child: isSigningOut
                                      ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: cs.primary,
                                          ),
                                        )
                                      : Text(
                                          l10n.profileSignOut,
                                          style: TextStyle(color: cs.error),
                                        ),
                                ),
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
        );
      },
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
      child: Text(
        title,
        style: tt.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant),
      title: Text(label),
      trailing: Text(value, style: TextStyle(color: cs.onSurfaceVariant)),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.currentCode, required this.onSelect});

  final String currentCode;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    Widget langButton({required String code, required String label}) {
      final selected = currentCode == code;
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSelect(code),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        langButton(code: 'en', label: l10n.settingsLanguageEn),
        const SizedBox(width: 8),
        langButton(code: 'ro', label: l10n.settingsLanguageRo),
      ],
    );
  }
}
