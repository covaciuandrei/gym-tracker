/// Formats a price stored in minor units (e.g. 2999 = 29.99) as a
/// human-readable string with the appropriate currency symbol.
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Formats [minor] units with the given ISO 4217 [currency] code.
  ///
  /// Trailing zeros after the decimal point are dropped when the amount is a
  /// whole number (e.g. 3000 → "30 €" not "30.00 €").
  static String format(int minor, String currency) {
    final formatted = toInputValue(minor);
    return switch (currency) {
      'EUR' => '$formatted €',
      'USD' => '\$$formatted',
      'GBP' => '£$formatted',
      'RON' => '$formatted lei',
      _ => '$formatted $currency',
    };
  }

  /// Converts a major-unit input into minor units without floating-point math.
  ///
  /// Both `.` and `,` are accepted as decimal separators. Values must be
  /// non-negative and may contain at most two fractional digits.
  static int? parseMinor(String input) {
    final normalized = input.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(normalized)) return null;

    final parts = normalized.split('.');
    final major = int.tryParse(parts.first);
    if (major == null) return null;

    final fraction = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));
    return major * 100 + fraction;
  }

  /// Converts minor units into a form-friendly major-unit value.
  static String toInputValue(int minor) {
    final sign = minor < 0 ? '-' : '';
    final absolute = minor.abs();
    final major = absolute ~/ 100;
    final fraction = absolute % 100;
    if (fraction == 0) return '$sign$major';
    return '$sign$major.${fraction.toString().padLeft(2, '0')}';
  }
}
