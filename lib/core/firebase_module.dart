import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

/// Provides Firebase SDK singletons to the [get_it] container.
///
/// This module is required so that [AuthService] can receive [FirebaseAuth]
/// via constructor injection. The actual [FirebaseAuth.instance] call is
/// deferred until the factory is first resolved — by which point
/// [Firebase.initializeApp()] has already been awaited in [main].
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
}
