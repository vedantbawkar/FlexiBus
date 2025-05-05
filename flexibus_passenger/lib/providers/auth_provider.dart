// lib/providers/auth_provider.dart
import 'package:flexibus_passenger/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _user = await AuthService.getCurrentUserWithProfile();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Call Firebase service directly
      final success = await AuthService.login(email, password);
      if (success) {
        await _loadUser();
      }
      return success;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
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
      _isLoading = true;
      notifyListeners();

      final success = await AuthService.register(
        name: name,
        email: email,
        password: password,
        idProofType: idProofType,
        idProofValue: idProofValue,
        age: age,
        gender: gender,
        phone: phone,
        isVerified: isVerified,
        isSecurityDepositPaid: isSecurityDepositPaid,
        isBanned: isBanned,
        hasBooked: hasBooked,
      );

      if (success) {
        await _loadUser();
      }
      return success;
    } catch (e) {
      print('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.logout();
    _user = null;

    _isLoading = false;
    notifyListeners();
  }

  resetPassword(String email) {
    // Implement password reset logic here
    // For example, you can call a method from AuthService to send a password reset email
    AuthService.resetPassword(email);
  }
}
