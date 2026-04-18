import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/utils/legal_url_launcher.dart';
import 'package:gym_tracker/presentation/controls/labeled_checkbox.dart';

/// Reusable consent checkbox shown on the Register page above the submit
/// button.
///
/// Renders a `Checkbox` next to a localized sentence
/// *"I have read and agree to the Terms of Service and Privacy Policy"*,
/// with both document names rendered as tappable links that open the
/// provided URLs in the external browser (via [launchLegalUrl], which
/// enforces https and dismisses the keyboard first).
///
/// State is owned by the parent via two `ValueNotifier<bool>`s:
///   * [accepted] — whether the checkbox is ticked.
///   * [showError] — whether the inline "you must accept…" error should be
///     visible. The parent sets this to `true` when the user tries to submit
///     without accepting, and back to `false` whenever the user toggles the
///     checkbox on.
///
/// URL resolution is intentionally **not** performed by this widget — the
/// parent is expected to pass fully resolved localized URLs. This keeps the
/// leaf widget free of `getIt` / locale plumbing and makes it trivially
/// pumpable in tests.
class LegalConsentCheckbox extends StatefulWidget {
  const LegalConsentCheckbox({
    super.key,
    required this.accepted,
    required this.showError,
    required this.termsUrl,
    required this.privacyUrl,
    this.enabled = true,
  });

  final ValueNotifier<bool> accepted;
  final ValueNotifier<bool> showError;
  final String termsUrl;
  final String privacyUrl;
  final bool enabled;

  @override
  State<LegalConsentCheckbox> createState() => _LegalConsentCheckboxState();
}

class _LegalConsentCheckboxState extends State<LegalConsentCheckbox> {
  // Recognizers are created once and reused across rebuilds. The `onTap`
  // closures capture `this` and read the current URL from `widget.*` at tap
  // time, so parent-driven URL changes are picked up without swapping
  // callbacks on every build.
  late final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer()..onTap = _handleTermsTap;
  late final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer()..onTap = _handlePrivacyTap;

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _handleTermsTap() {
    if (!widget.enabled) return;
    launchLegalUrl(widget.termsUrl);
  }

  void _handlePrivacyTap() {
    if (!widget.enabled) return;
    launchLegalUrl(widget.privacyUrl);
  }

  void _onChanged(bool value) {
    widget.accepted.value = value;
    if (value) {
      widget.showError.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: Listenable.merge([widget.accepted, widget.showError]),
      builder: (context, _) {
        final bodyStyle = tt.bodyMedium?.copyWith(color: cs.onSurface, height: 1.4);
        final linkStyle = bodyStyle?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: cs.primary,
        );

        return LabeledCheckbox(
          value: widget.accepted.value,
          enabled: widget.enabled,
          onChanged: _onChanged,
          errorText: widget.showError.value ? l10n.legalConsentRequired : null,
          label: Semantics(
            container: true,
            label: _plainSentence(l10n),
            child: ExcludeSemantics(
              child: Text.rich(_buildSpan(l10n: l10n, bodyStyle: bodyStyle, linkStyle: linkStyle)),
            ),
          ),
        );
      },
    );
  }

  /// Builds the rich-text span by locating the two localized labels inside
  /// the template message (`legalConsentMessage`) and wrapping each
  /// occurrence in a styled, tappable span. Using a single ICU message with
  /// `{terms}` / `{privacy}` placeholders means translators control word
  /// order; we find the labels in the substituted output rather than
  /// concatenating fragments.
  TextSpan _buildSpan({required AppLocalizations l10n, TextStyle? bodyStyle, TextStyle? linkStyle}) {
    final termsLabel = l10n.legalConsentTermsLabel;
    final privacyLabel = l10n.legalConsentPrivacyLabel;
    final message = l10n.legalConsentMessage(termsLabel, privacyLabel);

    final children = <InlineSpan>[];
    var cursor = 0;
    while (cursor < message.length) {
      final termsIdx = message.indexOf(termsLabel, cursor);
      final privacyIdx = message.indexOf(privacyLabel, cursor);

      // Find whichever label appears next (if either does).
      final nextIdx = _firstOf(termsIdx, privacyIdx);
      if (nextIdx == -1) {
        children.add(TextSpan(text: message.substring(cursor)));
        break;
      }

      if (nextIdx > cursor) {
        children.add(TextSpan(text: message.substring(cursor, nextIdx)));
      }

      final isTerms = nextIdx == termsIdx;
      final label = isTerms ? termsLabel : privacyLabel;
      children.add(
        TextSpan(text: label, style: linkStyle, recognizer: isTerms ? _termsRecognizer : _privacyRecognizer),
      );
      cursor = nextIdx + label.length;
    }

    return TextSpan(style: bodyStyle, children: children);
  }

  static int _firstOf(int a, int b) {
    if (a < 0) return b;
    if (b < 0) return a;
    return a < b ? a : b;
  }

  String _plainSentence(AppLocalizations l10n) =>
      l10n.legalConsentMessage(l10n.legalConsentTermsLabel, l10n.legalConsentPrivacyLabel);
}
