import 'package:injectable/injectable.dart';

import 'package:gym_tracker/core/constants/currencies.dart';
import 'package:gym_tracker/data/remote/user/user_source.dart';
import 'package:gym_tracker/model/body_type.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/model/user.dart';

@injectable
class UserService {
  const UserService(this._source);

  final UserSource _source;

  /// Returns the user profile for [userId], or null if not found.
  Future<User?> getById({required String userId}) => _source.getById(userId: userId);

  /// Creates the user profile document on sign-up.
  ///
  /// [sex], [birthDate], [heightCm], [weightKg] and [bodyType] are all
  /// independently optional — the registration personal-details step is
  /// skippable in whole or in part.
  Future<void> createUser({
    required String userId,
    required String email,
    required String displayName,
    required String language,
    required String currency,
    required Map<String, Object?> consent,
    Sex? sex,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    BodyType? bodyType,
  }) => _source.create(
    userId: userId,
    email: email,
    displayName: displayName,
    language: language,
    currency: normalizeCurrencyCode(currency),
    consent: consent,
    sex: sex,
    birthDate: birthDate,
    heightCm: heightCm,
    weightKg: weightKg,
    bodyType: bodyType,
  );

  /// Persists the account-level currency used to prefill new money records.
  Future<void> updateCurrency({required String userId, required String currency}) {
    final normalized = currency.trim().toUpperCase();
    if (!supportedCurrencyCodes.contains(normalized)) {
      throw ArgumentError.value(currency, 'currency', 'Unsupported currency');
    }
    return _source.updateCurrency(userId: userId, currency: normalized);
  }

  /// Records a returning login.
  Future<void> recordLogin({required String userId}) => _source.recordLogin(userId: userId);
}
