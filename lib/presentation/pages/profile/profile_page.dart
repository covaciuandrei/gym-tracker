import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/auth_user.dart';
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';

@RoutePage()
class ProfilePage extends StatefulWidget implements AutoRouteWrapper {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(create: (_) => getIt<AuthCubit>(), child: this);
  }
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().watchAuthState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<AuthCubit, BaseState>(
      listenWhen: (_, curr) =>
          curr is AuthSignOutSuccessState || curr is AuthUnauthenticatedState || curr is SomethingWentWrongState,
      listener: (ctx, state) {
        if (state is AuthSignOutSuccessState || state is AuthUnauthenticatedState) {
          ctx.router.replace(const LoginRoute());
          return;
        }
        if (state is SomethingWentWrongState) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.errorsUnknown)));
        }
      },
      builder: (ctx, state) {
        final isSigningOut = state is PendingState;
        final user = state is AuthAuthenticatedState ? state.user : null;

        return Scaffold(
          backgroundColor: cs.surfaceContainerLow,
          appBar: GymAppBar(title: l10n.profileTitle, showBackButton: false),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _UserCard(user: user),
                      const SizedBox(height: 24),
                      _SectionHeader(title: l10n.profileManage.toUpperCase()),
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: cs.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.fitness_center, color: cs.primary),
                              title: Text(l10n.profileWorkoutTypes),
                              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                              onTap: () => ctx.router.push(const WorkoutTypesRoute()),
                            ),
                            Divider(indent: 16, endIndent: 16, color: cs.outline, height: 1),
                            ListTile(
                              leading: Icon(Icons.settings, color: cs.primary),
                              title: Text(l10n.profileSettings),
                              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                              onTap: () => ctx.router.push(const SettingsRoute()),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(title: l10n.profileAccount.toUpperCase()),
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: cs.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.lock_outline, color: cs.primary),
                              title: Text(l10n.settingsChangePassword),
                              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                              onTap: () => ctx.router.push(const ChangePasswordRoute()),
                            ),
                            Divider(indent: 16, endIndent: 16, color: cs.outline, height: 1),
                            ListTile(
                              leading: Icon(Icons.logout, color: cs.error),
                              title: Text(l10n.profileSignOut, style: tt.titleMedium?.copyWith(color: cs.error)),
                              trailing: isSigningOut
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                                    )
                                  : Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                              onTap: isSigningOut ? null : () => ctx.read<AuthCubit>().signOut(),
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
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 1.2)),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final displayName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user!.displayName!.trim()
        : 'Gym Tracker User';
    final email = (user?.email != null && user!.email!.trim().isNotEmpty) ? user!.email!.trim() : '-';
    final initialSource = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user!.displayName!
        : (user?.email ?? '?');
    final initial = initialSource.characters.first.toUpperCase();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: cs.primaryContainer,
              child: Text(
                initial,
                style: tt.headlineSmall?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (user?.emailVerified == true) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 16, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          l10n.profileEmailVerified,
                          style: tt.labelSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
