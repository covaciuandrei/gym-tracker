import 'package:gym_tracker/data/health_insights/health_repository.dart';
import 'package:gym_tracker/data/remote/account/account_cleanup_source.dart';
import 'package:injectable/injectable.dart';

/// Orchestrates full account data cleanup by delegating to
/// [AccountCleanupSource] and dropping the on-device Apple Health cache.
///
/// This is a thin service layer — all Firestore logic lives in the source.
@injectable
class AccountCleanupService {
  const AccountCleanupService(this._source, this._healthRepository);

  final AccountCleanupSource _source;
  final HealthRepository _healthRepository;

  /// Deletes every Firestore document owned by [userId].
  ///
  /// Must be called **before** the Firebase Auth account is deleted, because
  /// security rules typically require the caller to be authenticated.
  Future<void> deleteAllUserData({required String userId}) async {
    await _source.deleteAllUserData(userId: userId);
    await _healthRepository.clearCache();
  }
}
