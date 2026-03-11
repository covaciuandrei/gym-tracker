import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/auth_user.dart';

@RoutePage()
class ProfilePage extends StatefulWidget implements AutoRouteWrapper {
  const ProfilePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: this,
    );
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<AuthCubit>().watchAuthState();
      } catch (_) {
        // Firebase not yet initialized.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocConsumer<AuthCubit, BaseState>(
      listener: (context, state) {
        if (state is AuthSignOutSuccessState || state is AuthUnauthenticatedState) {
          context.router.replaceAll([const LoginRoute()]);
        }
      },
      builder: (context, state) {
        final user = state is AuthAuthenticatedState ? state.user : null;
        final isLoading = state is PendingState;
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.profileTitle)),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),

                // ── Avatar ────────────────────────────────────────────
                _Avatar(user: user),
                const SizedBox(height: 16),

                // ── Display name ──────────────────────────────────────
                if (user?.displayName != null) ...[
                  Text(
                    user!.displayName!,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                ],

                // ── Email ─────────────────────────────────────────────
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                const SizedBox(height: 10),

                // ── Verified badge ────────────────────────────────────
                if (user?.emailVerified ?? false)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: cs.primary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified,
                            size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          l10n.profileEmailVerified,
                          style: TextStyle(
                              fontSize: 12, color: cs.primary),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                // ── Manage section ────────────────────────────────────
                _SectionHeader(title: l10n.profileManage),
                _MenuTile(
                  icon: Icons.fitness_center_outlined,
                  label: l10n.profileWorkoutTypes,
                  onTap: () => context.router.push(const WorkoutTypesRoute()),
                ),
                _MenuTile(
                  icon: Icons.settings_outlined,
                  label: l10n.profileSettings,
                  onTap: () => context.router.push(const SettingsRoute()),
                ),

                const SizedBox(height: 16),

                // ── Account section ───────────────────────────────────
                _SectionHeader(title: l10n.profileAccount),
                _MenuTile(
                  icon: Icons.logout,
                  label: l10n.profileSignOut,
                  iconColor: cs.error,
                  textColor: cs.error,
                  isLoading: isLoading,
                  onTap: () => context.read<AuthCubit>().signOut(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Avatar widget ─────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final AuthUser? user;

  String get _initial {
    final displayName = user?.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      return displayName[0].toUpperCase();
    }
    final email = user?.email;
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary, width: 2),
      ),
      child: Center(
        child: Text(
          _initial,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ── Menu tile ─────────────────────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: iconColor ?? cs.onSurfaceVariant, size: 22),
        title: Text(
          label,
          style: TextStyle(color: textColor ?? cs.onSurface),
        ),
        trailing: isLoading
            ? null
            : Icon(Icons.chevron_right, color: cs.outline),
        onTap: isLoading ? null : onTap,
      ),
    );
  }
}

