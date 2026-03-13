import 'package:flutter/material.dart';

class SurfaceSectionCard extends StatelessWidget {
  const SurfaceSectionCard({
    super.key,
    required this.children,
    this.borderRadius = 16,
  });

  final List<Widget> children;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(children: children),
    );
  }
}
