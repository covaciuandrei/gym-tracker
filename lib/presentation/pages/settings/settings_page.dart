import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/assets/theme/theme_helper.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/primary_button.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';

// ── App version constant ──────────────────────────────────────────────────────

const _kAppVersion = '1.0.0';

@RoutePage()
class SettingsPage extends StatefulWidget implements AutoRouteWrapper {
  const SettingsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: this,
    );
  }

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ── Form controllers ──────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── Error display ─────────────────────────────────────────────────────────
  String? _changePasswordError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSavePassword(BuildContext context) {
    setState(() => _changePasswordError = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeHelper = getIt<ThemeHelper>();
    final localeHelper = getIt<LocaleHelper>();

    return BlocConsumer<AuthCubit, BaseState>(
      listener: (context, state) {
        if (state is AuthPasswordChangedState) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          setState(() => _changePasswordError = null);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(l10n.settingsPasswordChangedSuccess),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
        } else if (state is AuthInvalidCredentialsState) {
          setState(() => _changePasswordError = l10n.errorsInvalidCredentials);
        } else if (state is SomethingWentWrongState) {
          setState(() => _changePasswordError = l10n.errorsUnknown);
        }
      },
      builder: (context, state) {
        final isLoading = state is PendingState;
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsTitle)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── General ─────────────────────────────────────────────
                  _SectionHeader(title: l10n.settingsGeneral),
                  _ToggleTile(
                    label: l10n.settingsTheme,
                    value: themeHelper.isDark,
                    trueLabel: l10n.settingsThemeDark,
                    falseLabel: l10n.settingsThemeLight,
                    onChanged: (v) => themeHelper.setDark(v),
                  ),
                  const SizedBox(height: 8),
                  _LanguageTile(
                    label: l10n.settingsLanguage,
                    currentLocale: localeHelper.locale,
                    locales: LocaleHelper.supportedLocales,
                    localeLabel: (locale) => locale.languageCode == 'en'
                        ? l10n.settingsLanguageEn
                        : l10n.settingsLanguageRo,
                    onLocaleSelected: (locale) => localeHelper.setLocale(locale),
                  ),

                  const SizedBox(height: 32),

                  // ── Security ────────────────────────────────────────────
                  _SectionHeader(title: l10n.settingsSecurity),
                  Text(
                    l10n.settingsChangePassword,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),

                  if (_changePasswordError != null)
                    _ErrorBanner(message: _changePasswordError!),

                  CustomTextField(
                    controller: _currentPasswordController,
                    label: l10n.settingsCurrentPassword,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || v.isEmpty)
                        ? l10n.errorsFieldRequired
                        : null,
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _newPasswordController,
                    label: l10n.settingsNewPassword,
                    isPassword: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.errorsFieldRequired;
                      if (v.length < 6) return l10n.errorsPasswordTooShort;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: l10n.settingsConfirmPassword,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _onSavePassword(context),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l10n.errorsFieldRequired;
                      if (v != _newPasswordController.text) {
                        return l10n.errorsPasswordMismatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  PrimaryButton(
                    label: l10n.settingsSavePassword,
                    isLoading: isLoading,
                    onPressed: () => _onSavePassword(context),
                  ),

                  const SizedBox(height: 32),

                  // ── About ───────────────────────────────────────────────
                  _SectionHeader(title: l10n.settingsAbout),
                  _InfoRow(
                    label: l10n.settingsAppVersion,
                    value: _kAppVersion,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.settingsBuiltWith,
                    style: TextStyle(color: cs.outline),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.outline,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Toggle tile ───────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.trueLabel,
    required this.falseLabel,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final String trueLabel;
  final String falseLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: Text(label),
        subtitle: Text(
          value ? trueLabel : falseLabel,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// ── Language tile ─────────────────────────────────────────────────────────────

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.currentLocale,
    required this.locales,
    required this.localeLabel,
    required this.onLocaleSelected,
  });

  final String label;
  final Locale currentLocale;
  final List<Locale> locales;
  final String Function(Locale) localeLabel;
  final ValueChanged<Locale> onLocaleSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: DropdownButton<Locale>(
          value: currentLocale,
          underline: const SizedBox(),
          items: locales
              .map(
                (l) => DropdownMenuItem(value: l, child: Text(localeLabel(l))),
              )
              .toList(),
          onChanged: (l) {
            if (l != null) onLocaleSelected(l);
          },
        ),
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
        Text(value, style: TextStyle(color: cs.onSurface)),
      ],
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.error.withValues(alpha: 0.4)),
      ),
      child: Text(
        message,
        style: TextStyle(color: cs.error, fontSize: 13),
      ),
    );
  }
}

