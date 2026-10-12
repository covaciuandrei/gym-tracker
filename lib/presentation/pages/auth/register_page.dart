import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/app_version_status.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/core/utils/app_date_formatter.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/body_type.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/error_banner.dart';
import 'package:gym_tracker/presentation/controls/form_card.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/controls/labeled_checkbox.dart';
import 'package:gym_tracker/presentation/controls/legal_consent_checkbox.dart';
import 'package:gym_tracker/presentation/controls/option_toggle.dart';
import 'package:gym_tracker/presentation/controls/password_match_indicator.dart';
import 'package:gym_tracker/presentation/controls/password_strength_indicator.dart';
import 'package:gym_tracker/presentation/controls/success_card.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

@RoutePage()
class RegisterPage extends StatefulWidget implements AutoRouteWrapper {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>(), child: this);
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _acceptedTerms = ValueNotifier<bool>(false);
  final _showConsentError = ValueNotifier<bool>(false);
  final _ageConfirmed = ValueNotifier<bool>(false);
  final _showAgeError = ValueNotifier<bool>(false);

  // Attached to the consent block so we can scroll it into view when the
  // user tries to submit without ticking it.
  final _consentBlockKey = GlobalKey();

  // Step 2 — optional, skippable personal details. Purely local form state
  // until `signUp` is called (rules.md ValueNotifier scope: local form drafts
  // are fine outside a cubit).
  final ValueNotifier<int> _step = ValueNotifier<int>(0);
  final _detailsFormKey = GlobalKey<FormState>();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final ValueNotifier<Sex?> _sex = ValueNotifier<Sex?>(null);
  final ValueNotifier<DateTime?> _birthDate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<BodyType?> _bodyType = ValueNotifier<BodyType?>(null);

  final LocaleHelper _localeHelper = getIt<LocaleHelper>();
  final AppVersionStatus _versionStatus = getIt<AppVersionStatus>();

  // These details only feed Health Insights, which is iOS-only.
  bool get _collectsPersonalDetails => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _acceptedTerms.dispose();
    _showConsentError.dispose();
    _ageConfirmed.dispose();
    _showAgeError.dispose();
    _step.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _sex.dispose();
    _birthDate.dispose();
    _bodyType.dispose();
    super.dispose();
  }

  void _onContinueFromCredentials(BuildContext ctx) {
    final formValid = _formKey.currentState?.validate() == true;

    var hasError = false;
    if (!_ageConfirmed.value) {
      _showAgeError.value = true;
      hasError = true;
    }
    if (!_acceptedTerms.value) {
      _showConsentError.value = true;
      hasError = true;
    }

    if (!formValid || hasError) {
      if (hasError) _scrollToConsent();
      return;
    }

    _showConsentError.value = false;
    _showAgeError.value = false;
    if (!_collectsPersonalDetails) {
      _onFinishRegistration(ctx, includeDetails: false);
      return;
    }
    _step.value = 1;
  }

  /// Finishes registration. [includeDetails] is `false` when the user taps
  /// "Skip" on the personal-details step — every optional field is then sent
  /// as `null` regardless of what (if anything) was typed.
  void _onFinishRegistration(BuildContext ctx, {required bool includeDetails}) {
    if (includeDetails && _detailsFormKey.currentState?.validate() != true) {
      return;
    }

    final lang = _localeHelper.locale.languageCode;
    final consent = <String, Object?>{
      'termsAccepted': true,
      'privacyAccepted': true,
      'ageConfirmed16Plus': true,
      'termsVersion': _versionStatus.termsVersion,
      'privacyVersion': _versionStatus.privacyVersion,
      'termsUrl': _versionStatus.termsUrlFor(lang),
      'privacyUrl': _versionStatus.privacyUrlFor(lang),
      'locale': lang,
    };

    ctx.read<AuthCubit>().signUp(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      displayName: _nicknameCtrl.text.trim(),
      language: lang,
      consent: consent,
      sex: includeDetails ? _sex.value : null,
      birthDate: includeDetails ? _birthDate.value : null,
      heightCm: includeDetails ? double.tryParse(_heightCtrl.text.trim()) : null,
      weightKg: includeDetails ? double.tryParse(_weightCtrl.text.trim()) : null,
      bodyType: includeDetails ? _bodyType.value : null,
    );
  }

  Future<void> _pickBirthDate(BuildContext ctx) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: ctx,
      initialDate: _birthDate.value ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      lastDate: now,
    );
    if (selected != null) _birthDate.value = selected;
  }

  void _scrollToConsent() {
    final ctx = _consentBlockKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut, alignment: 0.2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AuthCubit, BaseState>(
      buildWhen: (previous, current) =>
          current is PendingState ||
          current is AuthSignUpSuccessState ||
          current is AuthEmailAlreadyInUseState ||
          current is AuthWeakPasswordState ||
          current is SomethingWentWrongState,
      builder: (ctx, state) {
        final isLoading = state is PendingState;
        final isSuccess = state is AuthSignUpSuccessState;

        String? errorMessage;
        if (state is AuthEmailAlreadyInUseState) {
          errorMessage = l10n.errorsEmailAlreadyInUse;
        } else if (state is AuthWeakPasswordState) {
          errorMessage = l10n.errorsWeakPassword;
        } else if (state is SomethingWentWrongState) {
          errorMessage = l10n.errorsUnknown;
        }

        return Scaffold(
          backgroundColor: cs.surfaceContainerLow,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      const EmojiText(Emojis.biceps, style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.authRegisterTitle,
                        style: tt.headlineLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authRegisterSubtitle,
                        style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isSuccess
                            ? SuccessCard(
                                key: const ValueKey('success'),
                                title: l10n.authRegisterSuccess,
                                message: l10n.authRegisterSuccessMessage,
                                buttonLabel: l10n.authRegisterGoToLogin,
                                onAction: () => ctx.router.replace(const LoginRoute()),
                              )
                            : ValueListenableBuilder<int>(
                                key: const ValueKey('form'),
                                valueListenable: _step,
                                builder: (context, step, child) => AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: step == 0
                                      ? _RegisterCard(
                                          key: const ValueKey('credentials'),
                                          formKey: _formKey,
                                          nicknameCtrl: _nicknameCtrl,
                                          emailCtrl: _emailCtrl,
                                          passwordCtrl: _passwordCtrl,
                                          confirmCtrl: _confirmCtrl,
                                          acceptedTerms: _acceptedTerms,
                                          showConsentError: _showConsentError,
                                          ageConfirmed: _ageConfirmed,
                                          showAgeError: _showAgeError,
                                          consentBlockKey: _consentBlockKey,
                                          termsUrl: _versionStatus.termsUrlFor(_localeHelper.locale.languageCode),
                                          privacyUrl: _versionStatus.privacyUrlFor(_localeHelper.locale.languageCode),
                                          isLoading: isLoading,
                                          errorMessage: errorMessage,
                                          isFinalStep: !_collectsPersonalDetails,
                                          onContinue: () => _onContinueFromCredentials(ctx),
                                        )
                                      : _PersonalDetailsCard(
                                          key: const ValueKey('details'),
                                          formKey: _detailsFormKey,
                                          heightCtrl: _heightCtrl,
                                          weightCtrl: _weightCtrl,
                                          sex: _sex,
                                          birthDate: _birthDate,
                                          bodyType: _bodyType,
                                          isLoading: isLoading,
                                          errorMessage: errorMessage,
                                          onPickBirthDate: () => _pickBirthDate(ctx),
                                          onBack: () => _step.value = 0,
                                          onSkip: () => _onFinishRegistration(ctx, includeDetails: false),
                                          onFinish: () => _onFinishRegistration(ctx, includeDetails: true),
                                        ),
                                ),
                              ),
                      ),

                      if (!isSuccess) ...[
                        const SizedBox(height: 24),
                        Divider(color: cs.outline, thickness: 1),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              l10n.authRegisterHaveAccount,
                              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: isLoading ? null : () => ctx.router.replace(const LoginRoute()),
                              child: Text(
                                l10n.authRegisterSignIn,
                                style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ], // Wrap children
                        ), // Wrap
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({
    super.key,
    required this.formKey,
    required this.nicknameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.acceptedTerms,
    required this.showConsentError,
    required this.ageConfirmed,
    required this.showAgeError,
    required this.consentBlockKey,
    required this.termsUrl,
    required this.privacyUrl,
    required this.isLoading,
    required this.errorMessage,
    required this.isFinalStep,
    required this.onContinue,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nicknameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final ValueNotifier<bool> acceptedTerms;
  final ValueNotifier<bool> showConsentError;
  final ValueNotifier<bool> ageConfirmed;
  final ValueNotifier<bool> showAgeError;
  final GlobalKey consentBlockKey;
  final String termsUrl;
  final String privacyUrl;
  final bool isLoading;
  final String? errorMessage;
  final bool isFinalStep;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final labelStyle = tt.bodySmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface);

    return FormCard(
      formKey: formKey,
      children: [
        Text(l10n.authRegisterDisplayName, style: labelStyle),
        const SizedBox(height: 8),
        CustomTextField(
          controller: nicknameCtrl,
          label: l10n.authRegisterDisplayName,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          enabled: !isLoading,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return l10n.errorsFieldRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        Text(l10n.authRegisterEmail, style: labelStyle),
        const SizedBox(height: 8),
        CustomTextField(
          controller: emailCtrl,
          label: l10n.authRegisterEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          enabled: !isLoading,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return l10n.errorsFieldRequired;
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
              return l10n.errorsInvalidCredentials;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        Text(l10n.authRegisterPassword, style: labelStyle),
        const SizedBox(height: 8),
        CustomTextField(
          controller: passwordCtrl,
          label: l10n.authRegisterPassword,
          isPassword: true,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !isLoading,
          validator: (v) {
            if (v == null || v.isEmpty) return l10n.errorsFieldRequired;
            if (v.length < 8) return l10n.errorsPasswordTooShort;
            if (!v.contains(RegExp(r'[A-Z]')) || !v.contains(RegExp(r'[a-z]')) || !v.contains(RegExp(r'[0-9]'))) {
              return l10n.errorsWeakPassword;
            }
            return null;
          },
        ),
        PasswordStrengthIndicator(controller: passwordCtrl),
        const SizedBox(height: 20),

        Text(l10n.authRegisterConfirmPassword, style: labelStyle),
        const SizedBox(height: 8),
        CustomTextField(
          controller: confirmCtrl,
          label: l10n.authRegisterConfirmPassword,
          isPassword: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          enabled: !isLoading,
          onFieldSubmitted: isLoading ? null : (_) => onContinue(),
          validator: (v) {
            if (v == null || v.isEmpty) return l10n.errorsFieldRequired;
            if (v != passwordCtrl.text) {
              return l10n.errorsPasswordMismatch;
            }
            return null;
          },
        ),
        PasswordMatchIndicator(passwordCtrl: passwordCtrl, confirmCtrl: confirmCtrl),
        const SizedBox(height: 20),

        KeyedSubtree(
          key: consentBlockKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListenableBuilder(
                listenable: Listenable.merge([ageConfirmed, showAgeError]),
                builder: (_, _) => LabeledCheckbox(
                  value: ageConfirmed.value,
                  enabled: !isLoading,
                  onChanged: (v) {
                    ageConfirmed.value = v;
                    if (v) showAgeError.value = false;
                  },
                  label: Text(l10n.authAgeConfirm),
                  errorText: showAgeError.value ? l10n.authAgeRequired : null,
                ),
              ),
              const SizedBox(height: 8),
              LegalConsentCheckbox(
                accepted: acceptedTerms,
                showError: showConsentError,
                termsUrl: termsUrl,
                privacyUrl: privacyUrl,
                enabled: !isLoading,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: errorMessage != null
              ? Column(
                  key: ValueKey(errorMessage),
                  children: [
                    ErrorBanner(message: errorMessage!),
                    const SizedBox(height: 20),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        GradientButton(
          label: isFinalStep ? l10n.authRegisterButton : l10n.authRegisterContinue,
          isLoading: isLoading,
          onTap: onContinue,
        ),
      ],
    );
  }
}

class _PersonalDetailsCard extends StatelessWidget {
  const _PersonalDetailsCard({
    super.key,
    required this.formKey,
    required this.heightCtrl,
    required this.weightCtrl,
    required this.sex,
    required this.birthDate,
    required this.bodyType,
    required this.isLoading,
    required this.errorMessage,
    required this.onPickBirthDate,
    required this.onBack,
    required this.onSkip,
    required this.onFinish,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  final ValueNotifier<Sex?> sex;
  final ValueNotifier<DateTime?> birthDate;
  final ValueNotifier<BodyType?> bodyType;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onPickBirthDate;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final VoidCallback onFinish;

  String? _validateRange(String? value, {required double min, required double max, required String message}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null; // optional field
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed < min || parsed > max) return message;
    return null;
  }

  String _bodyTypeLabel(AppLocalizations l10n, BodyType type) => switch (type) {
    BodyType.lean => l10n.authPersonalDetailsBodyTypeLean,
    BodyType.athletic => l10n.authPersonalDetailsBodyTypeAthletic,
    BodyType.average => l10n.authPersonalDetailsBodyTypeAverage,
    BodyType.skinnyFat => l10n.authPersonalDetailsBodyTypeSkinnyFat,
    BodyType.higherBodyFat => l10n.authPersonalDetailsBodyTypeHigherBodyFat,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final labelStyle = tt.bodySmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface);

    return FormCard(
      formKey: formKey,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: isLoading ? null : onBack,
              icon: const Icon(Icons.arrow_back),
              tooltip: l10n.authPersonalDetailsBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.authPersonalDetailsTitle, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(l10n.authPersonalDetailsSubtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 20),

        Text(l10n.authPersonalDetailsSex, style: labelStyle),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: sex,
          builder: (_, _) => OptionToggle(
            selectedValue: sex.value?.storageValue ?? '',
            items: [
              OptionToggleItem(value: Sex.male.storageValue, label: l10n.authPersonalDetailsSexMale),
              OptionToggleItem(value: Sex.female.storageValue, label: l10n.authPersonalDetailsSexFemale),
            ],
            onSelect: (value) => sex.value = sex.value?.storageValue == value ? null : Sex.fromStorage(value),
          ),
        ),
        const SizedBox(height: 20),

        Text(l10n.authPersonalDetailsBirthDate, style: labelStyle),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: birthDate,
          builder: (_, _) => InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isLoading ? null : onPickBirthDate,
            child: InputDecorator(
              decoration: InputDecoration(
                hintText: l10n.authPersonalDetailsBirthDateHint,
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                birthDate.value == null ? l10n.authPersonalDetailsBirthDateHint : AppDateFormatter.format(birthDate.value!),
                style: tt.bodyLarge,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.authPersonalDetailsHeight, style: labelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: heightCtrl,
                    label: l10n.authPersonalDetailsHeight,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: !isLoading,
                    validator: (v) => _validateRange(v, min: 50, max: 260, message: l10n.errorsHeightInvalid),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.authPersonalDetailsWeight, style: labelStyle),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: weightCtrl,
                    label: l10n.authPersonalDetailsWeight,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: !isLoading,
                    validator: (v) => _validateRange(v, min: 20, max: 400, message: l10n.errorsWeightInvalid),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(l10n.authPersonalDetailsBodyType, style: labelStyle),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: bodyType,
          builder: (_, _) => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final type in BodyType.values)
                ChoiceChip(
                  label: Text(_bodyTypeLabel(l10n, type)),
                  selected: bodyType.value == type,
                  onSelected: (selected) => bodyType.value = selected ? type : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: errorMessage != null
              ? Column(
                  key: ValueKey(errorMessage),
                  children: [ErrorBanner(message: errorMessage!), const SizedBox(height: 20)],
                )
              : const SizedBox.shrink(),
        ),

        GradientButton(label: l10n.authRegisterButton, isLoading: isLoading, onTap: onFinish),
        const SizedBox(height: 12),
        Center(
          child: TextButton(onPressed: isLoading ? null : onSkip, child: Text(l10n.authRegisterSkip)),
        ),
      ],
    );
  }
}
