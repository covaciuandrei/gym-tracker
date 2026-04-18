import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/error_banner.dart';
import 'package:gym_tracker/presentation/controls/form_card.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/controls/legal_consent_checkbox.dart';
import 'package:gym_tracker/presentation/controls/password_match_indicator.dart';
import 'package:gym_tracker/presentation/controls/password_strength_indicator.dart';
import 'package:gym_tracker/presentation/controls/success_card.dart';
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
  // final _nicknameCtrl = TextEditingController();
  // final _emailCtrl = TextEditingController();
  // final _passwordCtrl = TextEditingController();
  // final _confirmCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController(text: 'Andrei');
  final _emailCtrl = TextEditingController(text: 'etticov@gmail.com');
  final _passwordCtrl = TextEditingController(text: 'Test1234');
  final _confirmCtrl = TextEditingController(text: 'Test1234');

  final _acceptedTerms = ValueNotifier<bool>(false);
  final _showConsentError = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _acceptedTerms.dispose();
    _showConsentError.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext ctx) {
    if (_formKey.currentState?.validate() != true) return;
    if (!_acceptedTerms.value) {
      _showConsentError.value = true;
      return;
    }
    _showConsentError.value = false;
    ctx.read<AuthCubit>().signUp(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      displayName: _nicknameCtrl.text.trim(),
    );
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
                            : _RegisterCard(
                                key: const ValueKey('form'),
                                formKey: _formKey,
                                nicknameCtrl: _nicknameCtrl,
                                emailCtrl: _emailCtrl,
                                passwordCtrl: _passwordCtrl,
                                confirmCtrl: _confirmCtrl,
                                acceptedTerms: _acceptedTerms,
                                showConsentError: _showConsentError,
                                isLoading: isLoading,
                                errorMessage: errorMessage,
                                onSubmit: () => _onSubmit(ctx),
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
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nicknameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final ValueNotifier<bool> acceptedTerms;
  final ValueNotifier<bool> showConsentError;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;

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
          onFieldSubmitted: isLoading ? null : (_) => onSubmit(),
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

        LegalConsentCheckbox(accepted: acceptedTerms, showError: showConsentError, enabled: !isLoading),
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

        GradientButton(label: l10n.authRegisterButton, isLoading: isLoading, onTap: onSubmit),
      ],
    );
  }
}
