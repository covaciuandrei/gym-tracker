import 'package:gym_tracker/assets/localization/app_localizations.dart';

extension MonthNames on AppLocalizations {
  /// First three letters of the localized month name, matching the Stats charts' labels.
  String monthShort(int month) {
    final full = switch (month) {
      1 => monthsJanuary,
      2 => monthsFebruary,
      3 => monthsMarch,
      4 => monthsApril,
      5 => monthsMay,
      6 => monthsJune,
      7 => monthsJuly,
      8 => monthsAugust,
      9 => monthsSeptember,
      10 => monthsOctober,
      11 => monthsNovember,
      _ => monthsDecember,
    };
    return full.length <= 3 ? full : full.substring(0, 3);
  }
}
