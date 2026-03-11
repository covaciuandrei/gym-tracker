import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/primary_button.dart';
import 'package:gym_tracker/presentation/resources/app_colors.dart';

@RoutePage()
class LoginPage extends StatefulWidget implements AutoRouteWrapper {
  const LoginPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: this,
    );
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    setState(() => _errorMessage = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<AuthCubit, BaseState>(
      listener: (context, state) {
        if (state is AuthSignInSuccessState) {
          context.router.replaceAll([const MainShellRoute()]);
        } else if (state is AuthEmailNotVerifiedState) {
          setState(() => _errorMessage = l10n.authEmailNotVerified);
        } else if (state is AuthInvalidCredentialsState) {
          setState(() => _errorMessage = l10n.errorsInvalidCredentials);
        } else if (state is SomethingWentWrongState) {
          setState(() => _errorMessage = l10n.errorsUnknown);
        }
      },
      builder: (context, state) {
        final isLoading = state is PendingState;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      // ── Logo ────────────────────────────────────────
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.authLoginTitle,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 32),

                      // ── Error banner ─────────────────────────────────
                      if (_errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                color: AppColors.danger, fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Email ────────────────────────────────────────
                      CustomTextField(
                        controller: _emailController,
                        label: l10n.authLoginEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.errorsFieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ── Password ─────────────────────────────────────
                      CustomTextField(
                        controller: _passwordController,
                        label: l10n.authLoginPassword,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) => _submit(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.errorsFieldRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // ── Forgot password ──────────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              context.router.push(const ForgotPasswordRoute()),
                          child: Text(l10n.authLoginForgotPassword),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Submit ───────────────────────────────────────
                      PrimaryButton(
                        label: l10n.authLoginButton,
                        isLoading: isLoading,
                        onPressed: () => _submit(context),
                      ),
                      const SizedBox(height: 24),

                      // ── Register link ────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.authLoginNoAccount,
                            style: const TextStyle(
                                color: AppColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.router.push(const RegisterRoute()),
                            child: const Text('Register'),
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

