import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'access_token';
  static const String _keyToken = 'auth_token';
  static const String _keyName  = 'full_name';
  static const String _keyEmail = 'email';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

  }
  static Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('full_name');
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }



  static Future<void> saveUserData(String name, String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyName, name);
  await prefs.setString(_keyEmail, email);
  }

  // static Future<void> clearToken() async {
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.remove(_keyToken);
  // await prefs.remove(_keyName);
  // await prefs.remove(_keyEmail);
  // }
}