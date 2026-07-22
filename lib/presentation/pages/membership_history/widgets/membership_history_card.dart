import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/utils/app_date_formatter.dart';
import 'package:gym_tracker/core/utils/currency_formatter.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

enum MembershipCardAction { renew, edit, delete }

class MembershipHistoryCard extends StatelessWidget {
  const MembershipHistoryCard({
    super.key,
    required this.membership,
    required this.onRenew,
    required this.onEdit,
    required this.onDelete,
  });

  final GymMembership membership;
  final VoidCallback onRenew;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = _statusDetails(context, l10n);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                EmojiText(Emojis.creditCard, style: textTheme.headlineSmall),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    membership.gymName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge,
                  ),
                ),
                PopupMenuButton<MembershipCardAction>(
                  tooltip: l10n.membershipMoreActions,
                  onSelected: (action) => _handleAction(action),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: MembershipCardAction.renew,
                      child: _ActionLabel(icon: Icons.replay_outlined, label: l10n.membershipRenew),
                    ),
                    PopupMenuItem(
                      value: MembershipCardAction.edit,
                      child: _ActionLabel(icon: Icons.edit_outlined, label: l10n.membershipEdit),
                    ),
                    PopupMenuItem(
                      value: MembershipCardAction.delete,
                      child: _ActionLabel(
                        icon: Icons.delete_outline,
                        label: l10n.membershipDelete,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${AppDateFormatter.format(membership.startDate)} – '
              '${AppDateFormatter.format(membership.validUntil)}',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${CurrencyFormatter.format(membership.priceMinor, membership.currency)} · '
                    '${_durationLabel(l10n)}',
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.label,
                    style: textTheme.labelMedium?.copyWith(color: status.color, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAction(MembershipCardAction action) {
    switch (action) {
      case MembershipCardAction.renew:
        onRenew();
      case MembershipCardAction.edit:
        onEdit();
      case MembershipCardAction.delete:
        onDelete();
    }
  }

  _MembershipStatusDetails _statusDetails(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    if (membership.isUpcomingAt(now)) {
      return _MembershipStatusDetails(label: l10n.membershipStatusUpcoming, color: colorScheme.tertiary);
    }
    if (membership.isExpiredAt(now)) {
      return _MembershipStatusDetails(label: l10n.membershipStatusExpired, color: colorScheme.outline);
    }
    return _MembershipStatusDetails(
      label: l10n.membershipDaysRemaining(membership.daysRemainingAt(now)),
      color: colorScheme.primary,
    );
  }

  String _durationLabel(AppLocalizations l10n) => switch (membership.duration) {
    MembershipDuration.oneMonth => l10n.membershipDurationOneMonth,
    MembershipDuration.threeMonths => l10n.membershipDurationThreeMonths,
    MembershipDuration.sixMonths => l10n.membershipDurationSixMonths,
    MembershipDuration.twelveMonths => l10n.membershipDurationTwelveMonths,
  };
}

class _MembershipStatusDetails {
  const _MembershipStatusDetails({required this.label, required this.color});

  final String label;
  final Color color;
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(label, style: textTheme.bodyMedium?.copyWith(color: color)),
      ],
    );
  }
}
