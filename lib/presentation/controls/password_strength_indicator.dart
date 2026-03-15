import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';

/// Animated strength bar + requirements list shown below a password field.
///
/// Mirrors Angular `.password-strength` + `.password-requirements`:
///   bar height 4px · radii 2px · animated width/colour
///   requirements: 12px text, green (#10b981) when met
///
/// Hides itself completely when [controller] is empty.
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final pwd = controller.text;
        if (pwd.isEmpty) return const SizedBox.shrink();

        final l10n = AppLocalizations.of(context);
        final strength = _calcStrength(pwd);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SizedBox(
                      height: 4,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.outline,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            width: constraints.maxWidth * strength.fraction,
                            decoration: BoxDecoration(color: strength.color, borderRadius: BorderRadius.circular(2)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 52,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      key: ValueKey(strength),
                      strength.label(l10n),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: strength.color),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 16,
              runSpacing: 2,
              children: [
                _Requirement(l10n.authPasswordReqLength, pwd.length >= 8),
                _Requirement(l10n.authPasswordReqUppercase, pwd.contains(RegExp(r'[A-Z]'))),
                _Requirement(l10n.authPasswordReqLowercase, pwd.contains(RegExp(r'[a-z]'))),
                _Requirement(l10n.authPasswordReqNumber, pwd.contains(RegExp(r'[0-9]'))),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement(this.label, this.met);

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Text(
      '• $label',
      style: TextStyle(
        fontSize: 12,
        color: met ? const Color(0xFF10B981) : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

enum _PasswordStrength { weak, fair, strong }

extension _PasswordStrengthX on _PasswordStrength {
  double get fraction => switch (this) {
    _PasswordStrength.weak => 0.33,
    _PasswordStrength.fair => 0.66,
    _PasswordStrength.strong => 1.0,
  };

  Color get color => switch (this) {
    _PasswordStrength.weak => const Color(0xFFEF4444),
    _PasswordStrength.fair => const Color(0xFFEAB308),
    _PasswordStrength.strong => const Color(0xFF10B981),
  };

  String label(AppLocalizations l10n) => switch (this) {
    _PasswordStrength.weak => l10n.authPasswordStrengthWeak,
    _PasswordStrength.fair => l10n.authPasswordStrengthFair,
    _PasswordStrength.strong => l10n.authPasswordStrengthStrong,
  };
}

_PasswordStrength _calcStrength(String pwd) {
  var score = 0;
  if (pwd.length >= 8) score++;
  if (pwd.contains(RegExp(r'[A-Z]'))) score++;
  if (pwd.contains(RegExp(r'[a-z]'))) score++;
  if (pwd.contains(RegExp(r'[0-9]'))) score++;
  if (score <= 1) return _PasswordStrength.weak;
  if (score <= 2) return _PasswordStrength.fair;
  return _PasswordStrength.strong;
}
