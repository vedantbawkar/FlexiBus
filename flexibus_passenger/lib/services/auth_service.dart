// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _usersCollection =
      _firestore.collection('passengers');

  static Future<void> initialize() async {
    // No special initialization needed for Firebase Auth
  }

  static Future<bool> login(String email, String password) async {
    try {
      // Sign in with email and password
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user exists
      if (userCredential.user != null) {
        // Get user profile from Firestore
        final userData = await _getUserData(userCredential.user!.uid);

        // If user doesn't have a profile, create one
        if (userData == null) {
          await _createUserProfile(userCredential.user!);
        }

        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  static Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String idProofType,
    required String idProofValue,
    required int age,
    required String gender,
    required String phone,
    required bool isVerified,
    required bool isSecurityDepositPaid,
    required bool isBanned,
    required bool hasBooked,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user profile in Firestore
        await _usersCollection.doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'idProofType': idProofType,
          'idProofValue': idProofValue,
          'age': age,
          'gender': gender,
          'phone': phone,
          'isVerified': isVerified,
          'isSecurityDepositPaid': isSecurityDepositPaid,
          'isBanned': isBanned,
          'hasBooked': hasBooked,
          'createdAt': DateTime.now(),
        });

        return true;
      }
      return false;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }

  static Map<String, dynamic>? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return {
      'id': user.uid,
      'email': user.email,
      'name': user.displayName ?? 'User',
    };
  }

  static bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Helper method to get user data from Firestore
  static Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();

      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Helper method to create user profile in Firestore
  static Future<void> _createUserProfile(User user) async {
    await _usersCollection.doc(user.uid).set({
      'name': user.displayName ?? 'User',
      'email': user.email,
      'idProofType': null,
      'idProofValue': null,
      'age': 25,
      'gender': 'Not specified',
      'phone': 9999999999,
      'isVerified': false,
      'isSecurityDepositPaid': false,
      'isBanned': false,
      'hasBooked': false,
      'createdAt': DateTime.now(),
    });
  }

  // Get current user with Firestore data
  static Future<Map<String, dynamic>?> getCurrentUserWithProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Get user profile from Firestore
    final userData = await _getUserData(user.uid);

    if (userData != null) {
      return {
        'id': user.uid,
        'email': user.email,
        'name': userData['name'] ?? 'User',
        'idProofType': userData['idProofType'],
        'idProofValue': userData['idProofValue'],
        'age': userData['age'],
        'gender': userData['gender'],
        'phone': userData['phone'],
        'isVerified': userData['isVerified'],
        'isSecurityDepositPaid': userData['isSecurityDepositPaid'],
        'isBanned': userData['isBanned'],
        'hasBooked': userData['hasBooked'],
        'createdAt': userData['createdAt'],
      };
    }

    return {
      'id': user.uid,
      'email': user.email,
      'name': user.displayName ?? 'User',
      'idProofType': null,
      'idProofValue': null,
      'age': 25,
      'gender': 'Not specified',
      'phone': 9999999999,
      'isVerified': false,
      'isSecurityDepositPaid': false,
      'isBanned': false,
      'hasBooked': false,
      'createdAt': DateTime.now(),
    };
  }

  static void resetPassword(String email) {
    _auth.sendPasswordResetEmail(email: email).then((_) {
      print('Password reset email sent to $email');
    }).catchError((error) {
      print('Error sending password reset email: $error');
    });
  }
}
