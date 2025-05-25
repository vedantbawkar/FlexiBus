// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _role;
  String? _fleetOperatorId;

  User? get user => _user;
  String? get role => _role;
  String? get fleetOperatorId => _fleetOperatorId;
  bool get isAuthenticated => _user != null;

  set role(String? value) {
    _role = value;
    notifyListeners();
  }
  set fleetOperatorId(String? value) {
    _fleetOperatorId = value;
    notifyListeners();
  }

  AuthProvider() {
    _listenToAuthChanges();
  }

  Future<void> register(String email, String password, String role, {String? fleetOperatorId}) async {
    try {
      _user = await _authService.register(email, password, role);
      _role = role;
      if (role == 'RidePilot') {
        _fleetOperatorId = fleetOperatorId;
      } else if (role == 'FleetOperator') {
        _fleetOperatorId = _user!.uid; // Set fleet operator ID to the user's UID
      } else {
        _fleetOperatorId = null; // Reset fleet operator ID for other roles
      } 
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _user = await _authService.signIn(email, password);
      if (_user != null) {
        _role = await _authService.getUserRole(_user!.uid);
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _role = null;
    notifyListeners();
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      _role = user != null ? await _authService.getUserRole(user.uid) : null;
      notifyListeners();
    });
  }
}
