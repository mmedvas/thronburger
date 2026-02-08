import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

/// Customer Repository
/// Handles customer authentication (Phone OTP) and profile management
class CustomerRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Store verification ID for phone auth (Mobile)
  String? _verificationId;
  // Store confirmation result for phone auth (Web)
  ConfirmationResult? _confirmationResult;

  CustomerRepository(this._auth, this._firestore);

  /// Send OTP to phone number
  Future<void> sendOtp(String phone) async {
    // Format phone number (ensure it starts with +)
    final formattedPhone = phone.startsWith('+') ? phone : '+$phone';

    if (kIsWeb) {
      // Web Implementation
      _confirmationResult = await _auth.signInWithPhoneNumber(formattedPhone);
    } else {
      // Explicitly disable reCAPTCHA - use silent verification
      // (Play Integrity on Android, APNs on iOS)
      await _auth.setSettings(forceRecaptchaFlow: false);

      // Mobile Implementation
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception('Phone verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    }
  }

  /// Verify OTP and sign in
  Future<UserCredential> verifyOtp(String phone, String token) async {
    if (kIsWeb) {
      if (_confirmationResult == null) {
        throw Exception(
          'Verification result not found. Please request OTP first.',
        );
      }
      return await _confirmationResult!.confirm(token);
    } else {
      if (_verificationId == null) {
        throw Exception('Verification ID not found. Please request OTP first.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: token,
      );

      return await _auth.signInWithCredential(credential);
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get customer profile
  Future<Customer?> getCustomer(String userId) async {
    final customerDoc = await _firestore
        .collection('customers')
        .doc(userId)
        .get();

    if (!customerDoc.exists) return null;

    // Get addresses subcollection
    final addressesSnapshot = await _firestore
        .collection('customers')
        .doc(userId)
        .collection('addresses')
        .orderBy('is_default', descending: true)
        .orderBy('created_at', descending: true)
        .get();

    final addresses = addressesSnapshot.docs
        .map((doc) => _sanitizeData(doc.data(), doc.id, customerId: userId))
        .toList();

    final data = customerDoc.data()!;
    return Customer.fromJson({
      ..._sanitizeData(data, customerDoc.id),
      'addresses': addresses,
    });
  }

  /// Create or update customer profile
  Future<Customer> upsertCustomer({
    required String userId,
    required String phone,
    String? name,
    String? email,
  }) async {
    await _firestore.collection('customers').doc(userId).set({
      'phone': phone,
      'name': name,
      'email': email,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final customer = await getCustomer(userId);
    return customer!;
  }

  /// Update customer name
  Future<Customer> updateName(String userId, String name) async {
    await _firestore.collection('customers').doc(userId).update({
      'name': name,
      'updated_at': FieldValue.serverTimestamp(),
    });

    final customer = await getCustomer(userId);
    return customer!;
  }

  /// Get customer addresses
  Future<List<Address>> getAddresses(String customerId) async {
    final snapshot = await _firestore
        .collection('customers')
        .doc(customerId)
        .collection('addresses')
        .orderBy('is_default', descending: true)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => Address.fromJson(
            _sanitizeData(doc.data(), doc.id, customerId: customerId),
          ),
        )
        .toList();
  }

  /// Add new address
  Future<Address> addAddress(Address address) async {
    // Ensure customer profile exists before adding address
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Check if customer profile exists, create if not
    final customerDoc = await _firestore
        .collection('customers')
        .doc(address.customerId)
        .get();

    if (!customerDoc.exists) {
      // Create customer profile first
      await _firestore.collection('customers').doc(address.customerId).set({
        'phone': user.phoneNumber ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    // If this is the first/default address, unset others
    if (address.isDefault) {
      final addressesSnapshot = await _firestore
          .collection('customers')
          .doc(address.customerId)
          .collection('addresses')
          .where('is_default', isEqualTo: true)
          .get();

      for (var doc in addressesSnapshot.docs) {
        await doc.reference.update({'is_default': false});
      }
    }

    final docRef = await _firestore
        .collection('customers')
        .doc(address.customerId)
        .collection('addresses')
        .add({
          'customer_id': address.customerId,
          'label': address.label,
          'area': address.area,
          'street': address.street,
          'building': address.building,
          'apartment': address.apartment,
          'landmark': address.landmark,
          'notes': address.notes,
          'is_default': address.isDefault,
          'created_at': FieldValue.serverTimestamp(),
        });

    final newDoc = await docRef.get();
    return Address.fromJson(
      _sanitizeData(newDoc.data()!, newDoc.id, customerId: address.customerId),
    );
  }

  /// Update address
  Future<Address> updateAddress(Address address) async {
    if (address.isDefault) {
      final addressesSnapshot = await _firestore
          .collection('customers')
          .doc(address.customerId)
          .collection('addresses')
          .where('is_default', isEqualTo: true)
          .get();

      for (var doc in addressesSnapshot.docs) {
        if (doc.id != address.id) {
          await doc.reference.update({'is_default': false});
        }
      }
    }

    await _firestore
        .collection('customers')
        .doc(address.customerId)
        .collection('addresses')
        .doc(address.id)
        .update({
          'label': address.label,
          'area': address.area,
          'street': address.street,
          'building': address.building,
          'apartment': address.apartment,
          'landmark': address.landmark,
          'notes': address.notes,
          'is_default': address.isDefault,
        });

    final updatedDoc = await _firestore
        .collection('customers')
        .doc(address.customerId)
        .collection('addresses')
        .doc(address.id)
        .get();

    return Address.fromJson(
      _sanitizeData(
        updatedDoc.data()!,
        updatedDoc.id,
        customerId: address.customerId,
      ),
    );
  }

  /// Delete address
  Future<void> deleteAddress(String customerId, String addressId) async {
    await _firestore
        .collection('customers')
        .doc(customerId)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  /// Delete customer account and all associated data
  /// Required by App Store and Play Store policies
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final userId = user.uid;

    // 1. Delete all addresses (subcollection)
    final addressesSnapshot = await _firestore
        .collection('customers')
        .doc(userId)
        .collection('addresses')
        .get();

    for (var doc in addressesSnapshot.docs) {
      await doc.reference.delete();
    }

    // 2. Delete customer profile document
    await _firestore.collection('customers').doc(userId).delete();

    // 3. Delete Firebase Auth account
    await user.delete();
  }

  /// Set default address
  Future<void> setDefaultAddress(String customerId, String addressId) async {
    // Unset all defaults
    final addressesSnapshot = await _firestore
        .collection('customers')
        .doc(customerId)
        .collection('addresses')
        .where('is_default', isEqualTo: true)
        .get();

    for (var doc in addressesSnapshot.docs) {
      await doc.reference.update({'is_default': false});
    }

    // Set new default
    await _firestore
        .collection('customers')
        .doc(customerId)
        .collection('addresses')
        .doc(addressId)
        .update({'is_default': true});
  }

  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Convert Firestore data to JSON compatible map
  /// Handles Timestamp -> String conversion
  Map<String, dynamic> _sanitizeData(
    Map<String, dynamic> data,
    String id, {
    String? customerId,
  }) {
    final result = <String, dynamic>{
      ...data,
      'id': id,
      'customer_id': ?customerId,
    };

    result.forEach((key, value) {
      if (value is Timestamp) {
        result[key] = value.toDate().toIso8601String();
      }
    });

    return result;
  }
}
