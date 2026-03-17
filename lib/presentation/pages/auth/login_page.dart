import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/presentation/helpers/onboarding_helper.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/error_banner.dart';
import 'package:gym_tracker/presentation/controls/form_card.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

@RoutePage()
class LoginPage extends StatefulWidget implements AutoRouteWrapper {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: this,
    );
  }
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onSignIn(BuildContext ctx) {
    ctx.read<AuthCubit>().signIn(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final labelStyle = tt.bodySmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: cs.onSurface,
    );

    return BlocConsumer<AuthCubit, BaseState>(
      listenWhen: (prev, curr) => curr is AuthSignInSuccessState,
      listener: (ctx, state) {
        if (state is AuthSignInSuccessState) {
          getIt<OnboardingHelper>().completeOnboarding();
          ctx.router.replace(const MainShellRoute());
        }
      },
      buildWhen: (prev, curr) => curr is! AuthSignInSuccessState,
      builder: (ctx, state) {
        final isLoading = state is PendingState;

        String? errorMessage;
        if (state is AuthInvalidCredentialsState) {
          errorMessage = l10n.errorsInvalidCredentials;
        } else if (state is AuthEmailNotVerifiedState) {
          errorMessage = l10n.authEmailNotVerified;
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

                      const EmojiText(
                        Emojis.biceps,
                        style: TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.authLoginWelcomeTitle,
                        style: tt.headlineLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.authLoginSubtitle,
                        style: tt.bodyLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      FormCard(
                        children: [
                          // Email
                          Text(l10n.authLoginEmail, style: labelStyle),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _emailCtrl,
                            label: l10n.authLoginEmail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 20),
                          // Password label row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.authLoginPassword, style: labelStyle),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () => ctx.router.push(
                                        const ForgotPasswordRoute(),
                                      ),
                                child: Text(
                                  l10n.authLoginForgotPassword,
                                  style: TextStyle(
                                    color: cs.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _passwordCtrl,
                            label: l10n.authLoginPassword,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: isLoading
                                ? null
                                : (_) => _onSignIn(ctx),
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 20),
                          // Error banner
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: errorMessage != null
                                ? Column(
                                    key: ValueKey(errorMessage),
                                    children: [
                                      ErrorBanner(message: errorMessage),
                                      const SizedBox(height: 20),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                          // Submit button
                          GradientButton(
                            label: l10n.authLoginButton,
                            isLoading: isLoading,
                            onTap: () => _onSignIn(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Divider(color: cs.outline, thickness: 1),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          Text(
                            l10n.authLoginNoAccount,
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 4),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: isLoading
                                ? null
                                : () =>
                                      ctx.router.replace(const RegisterRoute()),
                            child: Text(
                              l10n.authLoginSignUp,
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
