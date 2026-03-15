import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/error_state.dart';
import 'package:gym_tracker/presentation/controls/form_card.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/controls/set_password_card.dart';
import 'package:gym_tracker/presentation/controls/success_card.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

@RoutePage()
class AuthActionPage extends StatefulWidget implements AutoRouteWrapper {
  const AuthActionPage({super.key, @QueryParam('mode') this.mode = '', @QueryParam('oobCode') this.oobCode = ''});

  final String mode;
  final String oobCode;

  @override
  State<AuthActionPage> createState() => _AuthActionPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>(), child: this);
  }
}

class _AuthActionPageState extends State<AuthActionPage> {
  bool _initiated = false;

  /// Stored once [AuthPasswordResetCodeVerifiedState] arrives, used to keep
  /// the form visible while the subsequent [PendingState] (submit) is active.
  String? _resetEmail;

  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initiated) {
      _initiated = true;
      _initAction();
    }
  }

  void _initAction() {
    final cubit = context.read<AuthCubit>();
    if (widget.mode == 'verifyEmail') {
      cubit.verifyEmail(widget.oobCode);
    } else if (widget.mode == 'resetPassword') {
      cubit.verifyPasswordResetCode(widget.oobCode);
    }
  }

  void _onPasswordReset(BuildContext ctx) {
    if (_formKey.currentState?.validate() != true) return;
    ctx.read<AuthCubit>().confirmPasswordReset(oobCode: widget.oobCode, newPassword: _passwordCtrl.text);
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Unknown mode — render error page directly without entering the cubit flow.
    if (widget.mode != 'verifyEmail' && widget.mode != 'resetPassword') {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        backgroundColor: cs.surfaceContainerLow,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    ErrorStateWidget(
                      message: l10n.errorsUnknown,
                      actions: [
                        GradientButton(
                          label: l10n.authActionBackToSignIn,
                          isLoading: false,
                          onTap: () => context.router.replace(const LoginRoute()),
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
    }

    return BlocConsumer<AuthCubit, BaseState>(
      listenWhen: (_, curr) => curr is AuthPasswordResetCodeVerifiedState,
      listener: (_, state) {
        if (state is AuthPasswordResetCodeVerifiedState) {
          setState(() => _resetEmail = state.email);
        }
      },
      buildWhen: (_, curr) =>
          curr is PendingState ||
          curr is AuthEmailVerifiedState ||
          curr is AuthPasswordResetCodeVerifiedState ||
          curr is AuthPasswordResetConfirmedState ||
          curr is AuthInvalidActionCodeState ||
          curr is SomethingWentWrongState,
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: cs.surfaceContainerLow,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: _buildContent(ctx, state)),
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

  Widget _buildContent(BuildContext ctx, BaseState state) {
    final l10n = AppLocalizations.of(ctx);
    final isLoading = state is PendingState;

    if (isLoading && _resetEmail == null) {
      return _LoadingCard(
        key: const ValueKey('loading'),
        message: widget.mode == 'verifyEmail' ? l10n.authActionVerifyingEmail : l10n.authActionValidatingLink,
      );
    }

    if (state is AuthEmailVerifiedState) {
      return SuccessCard(
        key: const ValueKey('email-verified'),
        icon: Emojis.checkMark,
        title: l10n.authActionEmailVerifiedTitle,
        message: l10n.authActionEmailVerifiedMessage,
        buttonLabel: l10n.authRegisterGoToLogin,
        onAction: () => ctx.router.replace(const LoginRoute()),
      );
    }

    if (state is AuthPasswordResetCodeVerifiedState || (isLoading && _resetEmail != null)) {
      return SetPasswordCard(
        key: const ValueKey('reset-form'),
        title: l10n.authActionSetNewPasswordTitle,
        subtitle: (_resetEmail?.isNotEmpty ?? false) ? l10n.authActionCreateNewPasswordFor(_resetEmail!) : null,
        buttonLabel: l10n.authActionResetPasswordButton,
        formKey: _formKey,
        passwordCtrl: _passwordCtrl,
        confirmCtrl: _confirmCtrl,
        isLoading: isLoading,
        onSubmit: () => _onPasswordReset(ctx),
      );
    }

    if (state is AuthPasswordResetConfirmedState) {
      return SuccessCard(
        key: const ValueKey('password-reset'),
        icon: Emojis.party,
        title: l10n.authActionPasswordResetTitle,
        message: l10n.authActionPasswordResetMessage,
        buttonLabel: l10n.authRegisterGoToLogin,
        onAction: () => ctx.router.replace(const LoginRoute()),
      );
    }

    final errorMessage = state is AuthInvalidActionCodeState ? l10n.errorsInvalidActionCode : l10n.errorsUnknown;

    return _ErrorCard(
      key: ValueKey('error-${state.runtimeType}'),
      message: errorMessage,
      mode: widget.mode,
      onGoToLogin: () => ctx.router.replace(const LoginRoute()),
      onRequestNewLink: () => ctx.router.replace(const ForgotPasswordRoute()),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return FormCard(
      children: [
        const Center(child: SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 3))),
        const SizedBox(height: 24),
        Text(
          message,
          style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    super.key,
    required this.message,
    required this.mode,
    required this.onGoToLogin,
    required this.onRequestNewLink,
  });

  final String message;
  final String mode;
  final VoidCallback onGoToLogin;
  final VoidCallback onRequestNewLink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isResetMode = mode == 'resetPassword';

    return ErrorStateWidget(
      message: message,
      actions: [
        GradientButton(
          label: isResetMode ? l10n.authActionRequestNewLink : l10n.authActionBackToSignIn,
          isLoading: false,
          onTap: isResetMode ? onRequestNewLink : onGoToLogin,
        ),
        if (isResetMode) ...[
          const SizedBox(height: 12),
          TextButton(onPressed: onGoToLogin, child: Text(l10n.authActionBackToSignIn)),
        ],
      ],
    );
  }
}
