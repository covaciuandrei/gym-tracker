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
class ForgotPasswordPage extends StatefulWidget implements AutoRouteWrapper {
  const ForgotPasswordPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: this,
    );
  }

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthCubit>().resetPassword(_emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<AuthCubit, BaseState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSentState) {
          setState(() => _emailSent = true);
        } else if (state is SomethingWentWrongState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorsUnknown)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PendingState;
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.authForgotPasswordTitle),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _emailSent
                    ? _buildSuccess(context, l10n)
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Enter your email address and we\'ll send you a link to reset your password.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
                            ),
                            const SizedBox(height: 24),
                            CustomTextField(
                              controller: _emailController,
                              label: l10n.authForgotPasswordEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.email],
                              onFieldSubmitted: (_) => _submit(context),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.errorsFieldRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              label: l10n.authForgotPasswordButton,
                              isLoading: isLoading,
                              onPressed: () => _submit(context),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () => context.maybePop(),
                                child: Text(l10n.authForgotPasswordBack),
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
          child: Icon(Icons.send_outlined, size: 36, color: cs.primary),
        ),
        const SizedBox(height: 20),
        Text(
          'Email Sent',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.authForgotPasswordSent,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: l10n.authForgotPasswordBack,
          onPressed: () => context.maybePop(),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

