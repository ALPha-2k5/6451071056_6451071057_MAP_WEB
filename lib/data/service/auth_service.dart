import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _key = "is_logged_in";
  Future<bool> login(String username, String password) async {
    if (username == "admin" && password == "123@456") {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}
