import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a hosted legal document URL in the external browser.
///
/// Safety:
///   * Dismisses the keyboard first so the browser is not opened behind the
///     IME.
///   * Only accepts `https` URIs. Anything else (malformed, `http`,
///     `javascript:`, custom schemes, deep links) is rejected and the method
///     returns `false` without invoking `launchUrl`. This is defense in
///     depth against a compromised / misconfigured `appConfig` document.
///
/// Returns `true` when the platform reports the URL was opened, `false`
/// otherwise (invalid URI, unsupported scheme, or `launchUrl` returned
/// `false`).
Future<bool> launchLegalUrl(String url) async {
  FocusManager.instance.primaryFocus?.unfocus();

  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  if (uri.scheme != 'https') return false;
  if (uri.host.isEmpty) return false;

  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
