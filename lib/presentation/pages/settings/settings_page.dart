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
          curr is AuthSignOutSuccessState || curr is AuthUnauthenticatedState || curr is SomethingWentWrongState,
      listener: (ctx, state) {
        if (state is AuthSignOutSuccessState || state is AuthUnauthenticatedState) {
          ctx.router.replace(const LoginRoute());
          return;
        }
        if (state is SomethingWentWrongState) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.errorsUnknown)));
        }
      },
      builder: (ctx, state) {
        final isSigningOut = state is PendingState;

        return BlocBuilder<SettingsCubit, BaseState>(
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
                                  Divider(indent: 16, endIndent: 16, color: cs.outline, height: 1),
                                  LabeledValueTile(
                                    icon: Icons.code,
                                    label: l10n.settingsBuiltWith,
                                    value: 'Flutter + Firebase',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _SectionHeader(title: l10n.settingsSecurity.toUpperCase()),
                              SurfaceSectionCard(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.lock_outline, color: cs.primary),
                                    title: Text(l10n.settingsChangePassword),
                                    subtitle: Text(
                                      '••••••••',
                                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                    trailing: TextButton(
                                      onPressed: () => ctx.router.push(const ChangePasswordRoute()),
                                      child: Text(l10n.settingsChangePassword),
                                    ),
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
                              _SectionHeader(title: l10n.profileAccount.toUpperCase()),
                              Card(
                                margin: EdgeInsets.zero,
                                elevation: 0,
                                color: cs.surfaceContainerHigh,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.logout, color: cs.error),
                                      title: Text(l10n.profileSignOut, style: tt.titleMedium?.copyWith(color: cs.error)),
                                      trailing: isSigningOut
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                                            )
                                          : Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                                      onTap: isSigningOut ? null : () => ctx.read<AuthCubit>().signOut(),
                                    ),
                                  ],
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
      child: Text(title, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 1.2)),
    );
  }
}
