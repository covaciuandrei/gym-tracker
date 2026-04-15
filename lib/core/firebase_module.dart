import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

/// Provides Firebase SDK singletons to the [get_it] container.
///
/// The actual `.instance` calls are deferred until the factory is first
/// resolved — by which point [Firebase.initializeApp()] has already been
/// awaited in [main].
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;
}
