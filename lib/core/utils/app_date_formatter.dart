/// Formats complete calendar dates consistently across the app.
class AppDateFormatter {
  AppDateFormatter._();

  static final RegExp _isoDatePattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// Returns [date] in the fixed user-facing `dd.MM.yyyy` format.
  static String format(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day.$month.$year';
  }

  /// Converts a canonical `YYYY-MM-DD` date to the user-facing format.
  ///
  /// Returns `null` when [value] is not a valid canonical date.
  static String? tryFormatIsoDate(String value) {
    final match = _isoDatePattern.firstMatch(value.trim());
    if (match == null) return null;

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) return null;
    return format(date);
  }
}
