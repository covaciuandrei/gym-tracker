import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

/// Low-level Firestore operations for deleting all data owned by a user.
///
/// Handles nested subcollections that Firestore does not auto-delete:
///   - `users/{uid}/trainingTypes/*`
///   - `users/{uid}/attendances/{YYYY-MM}/days/*`
///   - `users/{uid}/healthLogs/{YYYY-MM}/entries/*`
///   - `users/{uid}` (the profile document itself)
///
/// Global `supplementProducts` created by the user are intentionally kept
/// because they may be referenced by other users' supplement logs.
///
/// Deletions are performed **sequentially** so that a failure leaves the
/// remaining data intact and a retry is safe (Firestore deletes are
/// idempotent — deleting an already-deleted document is a no-op).
@injectable
class AccountCleanupSource {
  const AccountCleanupSource(this._db);

  final FirebaseFirestore _db;

  /// Firestore batch write hard limit.
  static const _batchLimit = 500;

  /// Deletes every Firestore document owned by [userId].
  ///
  /// Must be called **before** the Firebase Auth account is deleted, because
  /// security rules typically require the caller to be authenticated.
  ///
  /// Uses sequential deletion order so partial failure is predictable:
  /// healthLogs → attendances → trainingTypes → user profile.
  Future<void> deleteAllUserData({required String userId}) async {
    final userDoc = _db.collection('users').doc(userId);

    // Sequential — if one step fails the rest stays intact for retry.
    await _deleteNestedMonthCollections(
      parentCollection: userDoc.collection('healthLogs'),
      subcollectionName: 'entries',
    );
    await _deleteNestedMonthCollections(
      parentCollection: userDoc.collection('attendances'),
      subcollectionName: 'days',
    );
    await _deleteCollection(userDoc.collection('trainingTypes'));
    await userDoc.delete();
  }

  /// Deletes all documents in a flat collection, respecting the 500-doc
  /// batch limit. Safe to call on empty collections.
  Future<void> _deleteCollection(CollectionReference collection) async {
    final snaps = await collection.get();
    if (snaps.docs.isEmpty) return;

    for (int i = 0; i < snaps.docs.length; i += _batchLimit) {
      final batch = _db.batch();
      final end = (i + _batchLimit).clamp(0, snaps.docs.length);
      for (int j = i; j < end; j++) {
        batch.delete(snaps.docs[j].reference);
      }
      await batch.commit();
    }
  }

  /// Handles the two-level nesting pattern used by attendances and healthLogs.
  ///
  /// Structure:  `parentCollection/{YYYY-MM}/subcollectionName/{docId}`
  ///
  /// For each month document, deletes all child documents in the subcollection
  /// then deletes the month document itself.
  Future<void> _deleteNestedMonthCollections({
    required CollectionReference parentCollection,
    required String subcollectionName,
  }) async {
    final monthSnaps = await parentCollection.get();
    for (final monthDoc in monthSnaps.docs) {
      final childRef = monthDoc.reference.collection(subcollectionName);
      await _deleteCollection(childRef);
      await monthDoc.reference.delete();
    }
  }
}
