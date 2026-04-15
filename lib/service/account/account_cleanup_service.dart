import 'package:gym_tracker/data/remote/account/account_cleanup_source.dart';
import 'package:injectable/injectable.dart';

/// Orchestrates full account data cleanup by delegating to
/// [AccountCleanupSource].
///
/// This is a thin service layer — all Firestore logic lives in the source.
@injectable
class AccountCleanupService {
  const AccountCleanupService(this._source);

  final AccountCleanupSource _source;

  /// Deletes every Firestore document owned by [userId].
  ///
  /// Must be called **before** the Firebase Auth account is deleted, because
  /// security rules typically require the caller to be authenticated.
  Future<void> deleteAllUserData({required String userId}) =>
      _source.deleteAllUserData(userId: userId);
}
