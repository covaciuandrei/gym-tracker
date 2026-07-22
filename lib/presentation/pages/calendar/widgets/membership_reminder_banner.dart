import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/utils/app_date_formatter.dart';
import 'package:gym_tracker/model/gym_membership.dart';

class MembershipReminderBanner extends StatelessWidget {
  const MembershipReminderBanner({
    super.key,
    required this.membership,
    required this.onAction,
    required this.onDismiss,
  });

  final GymMembership? membership;
  final VoidCallback onAction;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final expiredMembership = membership;
    final title = expiredMembership == null ? l10n.membershipCalendarMissingTitle : l10n.membershipCalendarExpiredTitle;
    final message = expiredMembership == null
        ? l10n.membershipCalendarMissingMessage
        : l10n.membershipCalendarExpiredMessage(
            expiredMembership.gymName,
            AppDateFormatter.format(expiredMembership.validUntil),
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: expiredMembership == null ? colorScheme.outline : colorScheme.error.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            expiredMembership == null ? Icons.card_membership_outlined : Icons.event_busy_outlined,
            color: expiredMembership == null ? colorScheme.primary : colorScheme.error,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(expiredMembership == null ? l10n.membershipAdd : l10n.membershipRenew),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.membershipCalendarDismiss,
            visualDensity: VisualDensity.compact,
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }
}
