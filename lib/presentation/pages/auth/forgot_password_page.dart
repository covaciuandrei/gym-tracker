import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/auth_footer_link.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/error_banner.dart';
import 'package:gym_tracker/presentation/controls/form_card.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/controls/success_card.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

@RoutePage()
class ForgotPasswordPage extends StatefulWidget implements AutoRouteWrapper {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>(), child: this);
  }
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext ctx) {
    if (_formKey.currentState?.validate() != true) return;
    ctx.read<AuthCubit>().resetPassword(_emailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<AuthCubit, BaseState>(
      buildWhen: (previous, current) =>
          current is PendingState || current is AuthPasswordResetSentState || current is SomethingWentWrongState,
      builder: (ctx, state) {
        final isLoading = state is PendingState;
        final isSuccess = state is AuthPasswordResetSentState;

        String? errorMessage;
        if (state is SomethingWentWrongState) {
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

                      const EmojiText(Emojis.lockedWithKey, style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.authForgotPasswordTitle,
                        style: tt.headlineLarge?.copyWith(fontSize: 28, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authForgotPasswordSubtitle,
                        style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isSuccess
                            ? SuccessCard(
                                key: const ValueKey('success'),
                                icon: Emojis.email,
                                title: l10n.authForgotPasswordSuccessTitle,
                                message: l10n.authForgotPasswordSent,
                                buttonLabel: l10n.authForgotPasswordBack,
                                onAction: () => ctx.router.replace(const LoginRoute()),
                              )
                            : _ForgotPasswordCard(
                                key: const ValueKey('form'),
                                formKey: _formKey,
                                emailCtrl: _emailCtrl,
                                isLoading: isLoading,
                                errorMessage: errorMessage,
                                onSubmit: () => _onSubmit(ctx),
                              ),
                      ),

                      if (!isSuccess) ...[
                        const SizedBox(height: 24),
                        AuthFooterLink(
                          prompt: '',
                          actionLabel: l10n.authForgotPasswordBack,
                          enabled: !isLoading,
                          onTap: () => ctx.router.replace(const LoginRoute()),
                        ),
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

class _ForgotPasswordCard extends StatelessWidget {
  const _ForgotPasswordCard({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
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
        Text(l10n.authForgotPasswordEmail, style: labelStyle),
        const SizedBox(height: 8),
        CustomTextField(
          controller: emailCtrl,
          label: l10n.authForgotPasswordEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          enabled: !isLoading,
          onFieldSubmitted: isLoading ? null : (_) => onSubmit(),
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

        GradientButton(label: l10n.authForgotPasswordButton, isLoading: isLoading, onTap: onSubmit),
      ],
    );
  }
}
