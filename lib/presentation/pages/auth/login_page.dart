import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/error_banner.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';


@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onSignIn() {
    setState(() => _error = null);
    context.read<AuthCubit>().signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<AuthCubit, BaseState>(
      listener: (ctx, state) {
        if (state is AuthSignInSuccessState) {
          ctx.router.replace(const MainShellRoute());
        } else if (state is AuthInvalidCredentialsState) {
          setState(() => _error = l10n.errorsInvalidCredentials);
        } else if (state is AuthEmailNotVerifiedState) {
          setState(() => _error = l10n.authEmailNotVerified);
        } else if (state is SomethingWentWrongState) {
          setState(() => _error = l10n.errorsUnknown);
        }
      },
      builder: (ctx, state) {
        final isLoading = state is PendingState;

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
                      // ── Header ─────────────────────────────────────────
                      const Text('💪', style: TextStyle(fontSize: 48)),
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
                      // ── Card ───────────────────────────────────────────
                      _LoginCard(
                        emailCtrl: _emailCtrl,
                        passwordCtrl: _passwordCtrl,
                        isLoading: isLoading,
                        error: _error,
                        onSignIn: _onSignIn,
                      ),
                      const SizedBox(height: 24),
                      // ── Footer ─────────────────────────────────────────
                      Divider(color: cs.outline, thickness: 1),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                : () => context.router
                                    .replace(const RegisterRoute()),
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

// ── Login card ────────────────────────────────────────────────────────────────

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.error,
    required this.onSignIn,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final String? error;
  final VoidCallback onSignIn;

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email
            Text(l10n.authLoginEmail, style: labelStyle),
            const SizedBox(height: 8),
            CustomTextField(
              controller: emailCtrl,
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
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: isLoading
                      ? null
                      : () => context.router
                          .push(const ForgotPasswordRoute()),
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
              controller: passwordCtrl,
              label: l10n.authLoginPassword,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: isLoading ? null : (_) => onSignIn(),
              enabled: !isLoading,
            ),
            const SizedBox(height: 20),
            // Error banner
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: error != null
                  ? Column(
                      key: ValueKey(error),
                      children: [
                        ErrorBanner(message: error!),
                        const SizedBox(height: 20),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            // Submit button
            GradientButton(
              label: l10n.authLoginButton,
              isLoading: isLoading,
              onTap: onSignIn,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gradient button ───────────────────────────────────────────────────────────



