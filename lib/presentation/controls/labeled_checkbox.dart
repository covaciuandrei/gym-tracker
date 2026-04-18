import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  final bool value;
  final Widget label;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final String? errorText;

  void _handleToggle() {
    if (!enabled) return;
    onChanged(!value);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: enabled ? _handleToggle : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 48x48 minimum tap target per Material accessibility
                // guidelines. The visual checkbox stays compact inside.
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Checkbox(
                      value: value,
                      onChanged: enabled ? (_) => _handleToggle() : null,
                      activeColor: cs.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Padding(padding: const EdgeInsets.only(top: 14), child: label),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Text(errorText!, style: tt.bodySmall?.copyWith(color: cs.error)),
          ),
        ],
      ],
    );
  }
}
