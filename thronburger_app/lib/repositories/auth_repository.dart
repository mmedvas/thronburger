import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Authentication Repository
/// Handles staff authentication via Firebase Auth
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create profile document
    if (fullName != null) {
      await _firestore
          .collection('profiles')
          .doc(userCredential.user!.uid)
          .set({
            'id': userCredential.user!.uid,
            'full_name': fullName,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });
    }

    return userCredential;
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get user profile
  Future<UserProfile?> getProfile(String userId) async {
    final profileDoc = await _firestore
        .collection('profiles')
        .doc(userId)
        .get();

    if (!profileDoc.exists) return null;

    // Get user role
    final roleDoc = await _firestore.collection('user_roles').doc(userId).get();

    final role = roleDoc.exists ? (roleDoc.data()?['role'] as String?) : null;

    return UserProfile.fromJson(
      profileDoc.data()!,
      roleValue: role,
      documentId: userId,
    );
  }

  /// Check if user has specific role
  Future<bool> hasRole(String userId, AppRole role) async {
    final roleDoc = await _firestore.collection('user_roles').doc(userId).get();

    if (!roleDoc.exists) return false;

    final userRole = roleDoc.data()?['role'] as String?;
    return userRole == role.value;
  }

  /// Update user profile name
  Future<void> updateProfile({
    required String userId,
    required String fullName,
  }) async {
    await _firestore.collection('profiles').doc(userId).update({
      'full_name': fullName,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
