import 'package:flutter/material.dart';

class PullToRefresh extends StatelessWidget {
  const PullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.notificationPredicate = defaultScrollNotificationPredicate,
  });

  static const ScrollPhysics alwaysScrollablePhysics = AlwaysScrollableScrollPhysics();

  final RefreshCallback onRefresh;
  final Widget child;
  final ScrollNotificationPredicate notificationPredicate;

  static bool verticalScrollNotification(ScrollNotification notification) {
    return notification.metrics.axis == Axis.vertical;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return RefreshIndicator.adaptive(
      color: cs.primary,
      backgroundColor: cs.surface,
      notificationPredicate: notificationPredicate,
      onRefresh: onRefresh,
      child: child,
    );
  }
}
