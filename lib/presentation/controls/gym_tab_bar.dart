import 'package:flutter/material.dart';

/// A styled tab bar that matches the app's pill-toggle design.
///
/// - [controller] – the [TabController] to drive.
/// - [tabs] – list of tab label strings.
/// - [centered] – if true, the bar is wrapped in a centered, compact container
///   (calendar style). If false, it stretches full-width (stats style).
class GymTabBar extends StatelessWidget {
  const GymTabBar({super.key, this.controller, required this.tabs, this.centered = false, this.labelPadding});

  final TabController? controller;
  final List<String> tabs;
  final bool centered;
  final EdgeInsetsGeometry? labelPadding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bar = TabBar(
      controller: controller,
      isScrollable: centered,
      tabAlignment: centered ? TabAlignment.center : TabAlignment.fill,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      dividerHeight: 0,
      padding: EdgeInsets.zero,
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF8A9BB5),
      indicatorWeight: 0,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
      unselectedLabelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 15),
      labelPadding: labelPadding ?? const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorPadding: EdgeInsets.zero,
      indicator: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(10)),
      tabs: tabs
          // .map((t) => Text(t))
          .map((t) => Text(t, style: TextStyle(fontSize: 12)))
          .toList(),
    );

    final container = Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2535) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(5),
      child: centered ? IntrinsicWidth(child: bar) : bar,
    );

    return centered ? Center(child: container) : container;
  }
}
