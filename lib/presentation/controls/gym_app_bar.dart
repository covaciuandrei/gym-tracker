import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// A reusable AppBar component for the gym tracker app
///
/// Provides consistent styling and behavior across all pages.
/// Supports automatic back navigation, custom actions, and flexible title display.
class GymAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GymAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.titleWidget,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.showBackButton,
  });

  /// The title text to display in the AppBar
  final String title;

  /// Optional widget to use as title instead of text
  final Widget? titleWidget;

  /// Optional actions to display on the right side of the AppBar
  final List<Widget>? actions;

  /// Whether to automatically show a back button when appropriate
  final bool automaticallyImplyLeading;

  /// Whether to explicitly show/hide back button (overrides automatic detection)
  final bool? showBackButton;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom background color, defaults to theme's surface color
  final Color? backgroundColor;

  /// Custom foreground color, defaults to theme's onSurface color
  final Color? foregroundColor;

  /// Custom elevation, defaults to 0
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine if we should show back button
    final canPop = context.router.canPop();
    final shouldShowBack = showBackButton ?? (automaticallyImplyLeading && canPop);

    return AppBar(
      title:
          titleWidget ??
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: foregroundColor ?? colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.transparent,
      surfaceTintColor: colorScheme.surfaceTint,
      automaticallyImplyLeading: false, // We handle this manually
      leading: shouldShowBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: foregroundColor ?? colorScheme.onSurface, size: 20),
              onPressed: () => context.router.maybePop(),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
