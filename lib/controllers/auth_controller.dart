import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  Future<void> checkLogin() async {
    _isLoggedIn = await _service.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final success = await _service.login(username, password);
    _isLoggedIn = success;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _service.logout();
    _isLoggedIn = false;
    notifyListeners();
  }
}
