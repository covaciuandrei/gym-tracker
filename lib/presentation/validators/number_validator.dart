import 'package:gym_tracker/assets/localization/app_localizations.dart';

/// Validates that a string contains only numbers and is positive
class NumberValidator {
  static String? validatePositiveNumber(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      // Empty is allowed for optional fields
      return null;
    }

    // Remove whitespace and check if it contains only digits
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return null;
    }

    if (!RegExp(r'^\d+$').hasMatch(trimmedValue)) {
      return l10n.errorsNumbersOnly;
    }

    final number = int.tryParse(trimmedValue);
    if (number == null) {
      return l10n.errorsInvalidNumber;
    }

    if (number <= 0) {
      return l10n.errorsPositiveNumber;
    }

    return null;
  }

  static String? validateRequiredPositiveNumber(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.errorsFieldRequired;
    }

    return validatePositiveNumber(value, l10n);
  }
}
