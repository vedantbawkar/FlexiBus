// services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<void> initialize() async {
    // No special initialization needed for Firebase Auth
  }

  Future<User?> registerOperator(
    String name,
    String email,
    String password,
    String phone,
    String address,
    String gender,
    String dob,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        await _firestore.collection('fleet_operators').doc(uid).set({
          'name': name,
          'gender': gender,
          'dob': dob,
          'phone': phone,
          'address': address,
          'email': email,
          'role': 'FleetOperator',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    }
  }

  Future<User?> registerDriver(
    String name,
    String email,
    String password,
    String fleetOperatorId,
    String phone,
    String address,
    String gender,
    String dob,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        await _firestore.collection('ride_pilots').doc(uid).set({
          'name': name,
          'gender': gender,
          'dob': dob,
          'phone': phone,
          'address': address,
          'email': email,
          'fleetOperatorId': fleetOperatorId,
          'role': 'RidePilot',
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Registration failed: ${e.message}');
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<AuthUtils> getUserRole(String uid) async {
    try {
      // Check in 'operators' collection
      final operatorDoc =
          await _firestore.collection('fleet_operators').doc(uid).get();
      if (operatorDoc.exists && operatorDoc.data() != null) {
        return AuthUtils(
          'FleetOperator',
          operatorDoc.data()!['status'] ?? "pending",
        );
      }

      // Check in 'drivers' collection
      final driverDoc =
          await _firestore.collection('ride_pilots').doc(uid).get();
      if (driverDoc.exists && driverDoc.data() != null) {
        return AuthUtils('RidePilot', driverDoc.data()!['status'] ?? "pending");
      }

      // If user not found in either collection
      return AuthUtils("none", "pending");
    } catch (e) {
      throw Exception('Failed to fetch role: $e');
    }
  }
}

class AuthUtils {
  String role;
  String status;

  AuthUtils(this.role, this.status);
}
