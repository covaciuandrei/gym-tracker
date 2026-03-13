import 'package:flutter/material.dart';

class MainListItem extends StatelessWidget {
  const MainListItem({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 4),
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: margin,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: leading,
        trailing: trailing,
        onTap: onTap,
        title: Text(title, style: tt.titleMedium),
      ),
    );
  }
}
