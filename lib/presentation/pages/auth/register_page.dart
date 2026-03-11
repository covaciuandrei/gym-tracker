import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/primary_button.dart';

@RoutePage()
class RegisterPage extends StatefulWidget implements AutoRouteWrapper {
  const RegisterPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: this,
    );
  }

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _successShown = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    setState(() => _errorMessage = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<AuthCubit, BaseState>(
      listener: (context, state) {
        if (state is AuthSignUpSuccessState) {
          setState(() => _successShown = true);
        } else if (state is AuthEmailAlreadyInUseState) {
          setState(() => _errorMessage = l10n.errorsEmailAlreadyInUse);
        } else if (state is AuthWeakPasswordState) {
          setState(() => _errorMessage = l10n.errorsPasswordTooShort);
        } else if (state is SomethingWentWrongState) {
          setState(() => _errorMessage = l10n.errorsUnknown);
        }
      },
      builder: (context, state) {
        final isLoading = state is PendingState;
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.authRegisterTitle),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _successShown
                    ? _buildSuccess(context, l10n)
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // ── Error banner ─────────────────────────
                            if (_errorMessage != null) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: cs.error
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: cs.error
                                          .withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: cs.error),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // ── Email ─────────────────────────────────
                            CustomTextField(
                              controller: _emailController,
                              label: l10n.authRegisterEmail,
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

                            // ── Password ──────────────────────────────
                            CustomTextField(
                              controller: _passwordController,
                              label: l10n.authRegisterPassword,
                              isPassword: true,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.newPassword],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.errorsFieldRequired;
                                }
                                if (value.length < 6) {
                                  return l10n.errorsPasswordTooShort;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // ── Confirm password ──────────────────────
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: l10n.authRegisterConfirmPassword,
                              isPassword: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              onFieldSubmitted: (_) => _submit(context),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.errorsFieldRequired;
                                }
                                if (value != _passwordController.text) {
                                  return l10n.errorsPasswordMismatch;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // ── Submit ────────────────────────────────
                            PrimaryButton(
                              label: l10n.authRegisterButton,
                              isLoading: isLoading,
                              onPressed: () => _submit(context),
                            ),
                            const SizedBox(height: 24),

                            // ── Login link ────────────────────────────
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.authRegisterHaveAccount,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                  TextButton(
                                    onPressed: () => context.maybePop(),
                                    child: const Text('Log In'),
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildSuccess(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_outlined,
              size: 36, color: cs.primary),
        ),
        const SizedBox(height: 20),
        Text(
          'Check your email',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a verification link to ${_emailController.text.trim()}.\n'
          'Please verify your email before logging in.',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: l10n.authLoginButton,
          onPressed: () => context.maybePop(),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

