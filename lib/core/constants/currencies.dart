const String fallbackCurrencyCode = 'EUR';

const Set<String> supportedCurrencyCodes = <String>{'EUR', 'GBP', 'RON', 'USD'};

String normalizeCurrencyCode(String? currency) {
  final normalized = currency?.trim().toUpperCase();
  return supportedCurrencyCodes.contains(normalized) ? normalized! : fallbackCurrencyCode;
}

String defaultCurrencyForLanguage(String languageCode) {
  final normalized = languageCode.trim().toLowerCase();
  final isRomanian = normalized == 'ro' || normalized.startsWith('ro-') || normalized.startsWith('ro_');
  return isRomanian ? 'RON' : fallbackCurrencyCode;
}
