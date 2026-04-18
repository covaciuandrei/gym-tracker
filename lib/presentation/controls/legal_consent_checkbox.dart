import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_version_status.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reusable consent checkbox shown on the Register page above the submit
/// button.
///
/// Renders a single `Checkbox` next to a rich text reading
/// *"I have read and agree to the Terms of Service and Privacy Policy"*, with
/// both document names rendered as tappable links that open the localized
/// hosted page in an external browser.
///
/// State is owned by the parent via two `ValueNotifier<bool>`s:
///   * [accepted] — whether the checkbox is ticked.
///   * [showError] — whether the inline "you must accept…" error should be
///     visible. The parent sets this to `true` when the user tries to submit
///     without accepting, and back to `false` whenever the user toggles the
///     checkbox on.
///
/// URLs are resolved through [LocaleHelper] + [AppVersionStatus] (which
/// transparently falls back to the hardcoded constants in
/// `core/constants/legal_urls.dart` when remote config has not been
/// populated).
class LegalConsentCheckbox extends StatefulWidget {
  const LegalConsentCheckbox({super.key, required this.accepted, required this.showError, this.enabled = true});

  final ValueNotifier<bool> accepted;
  final ValueNotifier<bool> showError;
  final bool enabled;

  @override
  State<LegalConsentCheckbox> createState() => _LegalConsentCheckboxState();
}

class _LegalConsentCheckboxState extends State<LegalConsentCheckbox> {
  final TapGestureRecognizer _termsRecognizer = TapGestureRecognizer();
  final TapGestureRecognizer _privacyRecognizer = TapGestureRecognizer();

  final LocaleHelper _localeHelper = getIt<LocaleHelper>();
  final AppVersionStatus _versionStatus = getIt<AppVersionStatus>();

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!widget.enabled) return;
    widget.accepted.value = !widget.accepted.value;
    if (widget.accepted.value) {
      widget.showError.value = false;
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: Listenable.merge([widget.accepted, widget.showError, _localeHelper]),
      builder: (context, _) {
        final lang = _localeHelper.locale.languageCode;
        final termsUrl = _versionStatus.termsUrlFor(lang);
        final privacyUrl = _versionStatus.privacyUrlFor(lang);

        _termsRecognizer.onTap = widget.enabled ? () => _openUrl(termsUrl) : null;
        _privacyRecognizer.onTap = widget.enabled ? () => _openUrl(privacyUrl) : null;

        final bodyStyle = tt.bodyMedium?.copyWith(color: cs.onSurface, height: 1.4);
        final linkStyle = bodyStyle?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
          decorationColor: cs.primary,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: widget.enabled ? _toggle : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: widget.accepted.value,
                        onChanged: widget.enabled ? (_) => _toggle() : null,
                        activeColor: cs.primary,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(text: '${l10n.legalConsentPrefix} '),
                              TextSpan(text: l10n.legalConsentTerms, style: linkStyle, recognizer: _termsRecognizer),
                              TextSpan(text: ' ${l10n.legalConsentAnd} '),
                              TextSpan(
                                text: l10n.legalConsentPrivacy,
                                style: linkStyle,
                                recognizer: _privacyRecognizer,
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.showError.value) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Text(l10n.legalConsentRequired, style: tt.bodySmall?.copyWith(color: cs.error)),
              ),
            ],
          ],
        );
      },
    );
  }
}
