// providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _role;
  String? _status;
  String? _fleetOperatorId;

  User? get user => _user;
  String? get role => _role;
  String? get status => _status;
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

  Future<void> register(
    String name,
    String email,
    String password,
    String role,
    String? fleetOperatorId,
    String phone,
    String address,
    String gender,
    String dob,
  ) async {
    try {
      _role = role;
      if (role == 'RidePilot') {
        _user = await _authService.registerDriver(
          name,
          email,
          password,
          fleetOperatorId!,
          phone,
          address,
          gender,
          dob,
        );
      } else if (role == 'FleetOperator') {
        _user = await _authService.registerOperator(
          name,
          email,
          password,
          phone,
          address,
          gender,
          dob,
        );
      } else {}
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      _user = await _authService.signIn(email, password);
      if (_user != null) {
        _role = (await _authService.getUserRole(_user!.uid)).role;
      }
      print("User" + _user.toString() + _role.toString());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    _role = null;
    _status = null;
    notifyListeners();
  }

  void _listenToAuthChanges() {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        final authResult = await _authService.getUserRole(user.uid);
        _role = authResult.role;
        _status = authResult.status;
      } else {
        _role = null;
        _status = null;
      }
      print("User" + _user.toString() + _role.toString());
      notifyListeners();
    });
  }
}
