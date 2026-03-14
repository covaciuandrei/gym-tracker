/// Validates that a string contains only numbers and is positive
class NumberValidator {
  static String? validatePositiveNumber(String? value) {
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
      return 'Please enter only numbers';
    }

    final number = int.tryParse(trimmedValue);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number <= 0) {
      return 'Please enter a positive number';
    }

    return null;
  }

  static String? validateRequiredPositiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return validatePositiveNumber(value);
  }
}
