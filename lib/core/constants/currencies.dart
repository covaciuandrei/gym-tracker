const String fallbackCurrencyCode = 'EUR';

const Set<String> supportedCurrencyCodes = <String>{'EUR', 'GBP', 'RON', 'USD'};

String normalizeCurrencyCode(String? currency) {
  final normalized = currency?.trim().toUpperCase();
  return supportedCurrencyCodes.contains(normalized) ? normalized! : fallbackCurrencyCode;
}
