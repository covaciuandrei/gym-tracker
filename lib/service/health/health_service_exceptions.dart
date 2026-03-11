part of 'health_service.dart';

/// Thrown when an update targets a supplement product that no longer exists.
class SupplementProductNotFoundException implements Exception {
  const SupplementProductNotFoundException();
}
