import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/constants/currencies.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/membership/membership_cubit.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/presentation/controls/confirmation_dialog.dart';
import 'package:gym_tracker/presentation/controls/empty_state.dart';
import 'package:gym_tracker/presentation/controls/error_state.dart';
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';
import 'package:gym_tracker/presentation/controls/membership_form_sheet.dart';
import 'package:gym_tracker/presentation/controls/primary_fab.dart';
import 'package:gym_tracker/presentation/controls/pull_to_refresh.dart';
import 'package:gym_tracker/presentation/pages/membership_history/widgets/membership_history_card.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

@RoutePage()
class MembershipHistoryPage extends StatelessWidget implements AutoRouteWrapper {
  const MembershipHistoryPage({super.key, this.startAddFlow = false, this.testUserId});

  final bool startAddFlow;
  final String? testUserId;

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<MembershipCubit>(create: (_) => getIt<MembershipCubit>(), child: this);
  }

  @override
  Widget build(BuildContext context) {
    final userId = testUserId ?? getIt<FirebaseAuth>().currentUser!.uid;
    return MembershipHistoryView(userId: userId, startAddFlow: startAddFlow);
  }
}

class MembershipHistoryView extends StatefulWidget {
  const MembershipHistoryView({super.key, required this.userId, this.startAddFlow = false, this.showBackButton = true});

  final String userId;
  final bool startAddFlow;
  final bool showBackButton;

  @override
  State<MembershipHistoryView> createState() => _MembershipHistoryViewState();
}

class _MembershipHistoryViewState extends State<MembershipHistoryView> {
  bool _initialAddFlowHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<MembershipCubit>().load(userId: widget.userId);
      if (!mounted || !widget.startAddFlow || _initialAddFlowHandled) return;
      _initialAddFlowHandled = true;
      final state = context.read<MembershipCubit>().state;
      if (state is MembershipsReadyState) {
        await _startCreateFlow(state.memberships, defaultCurrency: state.defaultCurrency);
      }
    });
  }

  Future<void> _startCreateFlow(
    List<GymMembership> memberships, {
    required String defaultCurrency,
    GymMembership? copyFrom,
  }) async {
    GymMembership? source = copyFrom;
    if (source == null && memberships.isNotEmpty) {
      final shouldCopy = await _askHowToCreate();
      if (shouldCopy == null || !mounted) return;
      if (shouldCopy) source = memberships.first;
    }

    final today = DateTime.now();
    final initial = source == null
        ? GymMembershipDraft(
            gymName: '',
            startDate: today,
            duration: MembershipDuration.oneMonth,
            priceMinor: 0,
            currency: normalizeCurrencyCode(defaultCurrency),
          )
        : GymMembershipDraft.fromMembership(source, startDate: today);

    final l10n = AppLocalizations.of(context);
    final draft = await showDialog<GymMembershipDraft>(
      context: context,
      builder: (_) =>
          MembershipFormSheet(title: source == null ? l10n.membershipAdd : l10n.membershipRenew, initial: initial),
    );
    if (draft == null || !mounted) return;
    await context.read<MembershipCubit>().create(userId: widget.userId, draft: draft);
  }

  Future<bool?> _askHowToCreate() {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.membershipCopyPromptTitle),
        content: Text(l10n.membershipCopyPromptMessage),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.calendarCancel)),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.membershipStartFresh)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(l10n.membershipCopyLast)),
        ],
      ),
    );
  }

  Future<void> _edit(GymMembership membership) async {
    final l10n = AppLocalizations.of(context);
    final draft = await showDialog<GymMembershipDraft>(
      context: context,
      builder: (_) =>
          MembershipFormSheet(title: l10n.membershipEdit, initial: GymMembershipDraft.fromMembership(membership)),
    );
    if (draft == null || !mounted) return;
    await context.read<MembershipCubit>().update(userId: widget.userId, current: membership, draft: draft);
  }

  Future<void> _delete(GymMembership membership) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmationDialog.show(
      context,
      title: l10n.membershipDeleteTitle,
      message: l10n.membershipDeleteConfirm(membership.gymName),
      cancelLabel: l10n.calendarCancel,
      confirmLabel: l10n.membershipDelete,
      confirmColor: Theme.of(context).colorScheme.error,
    );
    if (!confirmed || !mounted) return;
    await context.read<MembershipCubit>().delete(userId: widget.userId, membershipId: membership.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<MembershipCubit, BaseState>(
      listenWhen: (_, state) =>
          state is MembershipCreatedState || state is MembershipUpdatedState || state is MembershipDeletedState,
      listener: (context, state) {
        final message = switch (state) {
          MembershipCreatedState() => l10n.membershipCreated,
          MembershipUpdatedState() => l10n.membershipUpdated,
          MembershipDeletedState() => l10n.membershipDeleted,
          _ => '',
        };
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final memberships = state is MembershipsReadyState ? state.memberships : null;
        final defaultCurrency = state is MembershipsReadyState ? state.defaultCurrency : fallbackCurrencyCode;
        return Scaffold(
          backgroundColor: colorScheme.surfaceContainerLow,
          appBar: GymAppBar(title: l10n.membershipHistoryTitle, showBackButton: widget.showBackButton),
          floatingActionButton: memberships == null || memberships.isEmpty
              ? null
              : PrimaryFab(
                  tooltip: l10n.membershipAdd,
                  onPressed: () => _startCreateFlow(memberships, defaultCurrency: defaultCurrency),
                ),
          body: SafeArea(child: _buildBody(context, state, memberships, defaultCurrency)),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, BaseState state, List<GymMembership>? memberships, String defaultCurrency) {
    final l10n = AppLocalizations.of(context);
    if (state is SomethingWentWrongState) {
      return ErrorStateWidget(
        message: l10n.errorsUnknown,
        onRetry: () => context.read<MembershipCubit>().load(userId: widget.userId),
      );
    }
    if (memberships == null) return const _MembershipHistorySkeleton();
    if (memberships.isEmpty) {
      return EmptyStateWidget(
        emoji: Emojis.creditCard,
        title: l10n.membershipEmptyTitle,
        message: l10n.membershipEmptyMessage,
        actionLabel: l10n.membershipAddFirst,
        onAction: () => _startCreateFlow(memberships, defaultCurrency: defaultCurrency),
      );
    }

    return PullToRefresh(
      onRefresh: () => context.read<MembershipCubit>().load(userId: widget.userId),
      child: ListView.separated(
        physics: PullToRefresh.alwaysScrollablePhysics,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: memberships.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final membership = memberships[index];
          return MembershipHistoryCard(
            membership: membership,
            onRenew: () => _startCreateFlow(memberships, defaultCurrency: defaultCurrency, copyFrom: membership),
            onEdit: () => _edit(membership),
            onDelete: () => _delete(membership),
          );
        },
      ),
    );
  }
}

class _MembershipHistorySkeleton extends StatelessWidget {
  const _MembershipHistorySkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        height: 126,
        decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
