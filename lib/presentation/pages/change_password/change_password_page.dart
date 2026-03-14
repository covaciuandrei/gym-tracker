import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';
import 'package:gym_tracker/presentation/controls/set_password_card.dart';

@RoutePage()
class ChangePasswordPage extends StatefulWidget implements AutoRouteWrapper {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>(), child: this);
  }
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext ctx) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ctx.read<AuthCubit>().changePassword(
      currentPassword: _currentPasswordCtrl.text,
      newPassword: _newPasswordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<AuthCubit, BaseState>(
      listenWhen: (_, curr) => curr is AuthPasswordChangedState || curr is SomethingWentWrongState,
      listener: (ctx, state) {
        if (state is AuthPasswordChangedState) {
          _formKey.currentState?.reset();
          _currentPasswordCtrl.clear();
          _newPasswordCtrl.clear();
          _confirmPasswordCtrl.clear();
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.settingsPasswordChangedSuccess)));
          return;
        }

        if (state is SomethingWentWrongState) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.errorsUnknown)));
        }
      },
      builder: (ctx, state) {
        final isLoading = state is PendingState;

        String? errorMessage;
        if (state is AuthInvalidCredentialsState) {
          errorMessage = l10n.errorsInvalidCredentials;
        }

        return Scaffold(
          backgroundColor: cs.surfaceContainerLow,
          appBar: GymAppBar(title: l10n.settingsChangePassword),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SetPasswordCard(
                    title: l10n.settingsChangePassword,
                    buttonLabel: l10n.settingsSavePassword,
                    formKey: _formKey,
                    currentPasswordCtrl: _currentPasswordCtrl,
                    passwordCtrl: _newPasswordCtrl,
                    confirmCtrl: _confirmPasswordCtrl,
                    isLoading: isLoading,
                    onSubmit: () => _onSubmit(ctx),
                    errorMessage: errorMessage,
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
