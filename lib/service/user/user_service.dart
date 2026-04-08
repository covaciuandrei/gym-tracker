import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/remote/user/user_source.dart';
import 'package:gym_tracker/model/user.dart';

@injectable
class UserService {
  const UserService(this._source);

  final UserSource _source;

  /// Returns the user profile for [userId], or null if not found.
  Future<User?> getById({required String userId}) =>
      _source.getById(userId: userId);

  /// Creates the user profile document on sign-up.
  Future<void> createUser({
    required String userId,
    required String email,
    required String displayName,
  }) => _source.create(userId: userId, email: email, displayName: displayName);

  /// Records a returning login.
  Future<void> recordLogin({required String userId}) =>
      _source.recordLogin(userId: userId);
}
