import 'package:flutter/material.dart';

class OptionToggleItem {
  const OptionToggleItem({required this.value, required this.label});

  final String value;
  final String label;
}

class OptionToggle extends StatelessWidget {
  const OptionToggle({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onSelect,
    this.spacing = 8,
  });

  final String selectedValue;
  final List<OptionToggleItem> items;
  final ValueChanged<String> onSelect;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _OptionToggleButton(
            item: items[index],
            selected: selectedValue == items[index].value,
            onTap: () => onSelect(items[index].value),
          ),
          if (index < items.length - 1) SizedBox(width: spacing),
        ],
      ],
    );
  }
}

class _OptionToggleButton extends StatelessWidget {
  const _OptionToggleButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final OptionToggleItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          item.label,
          style: TextStyle(
            color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
