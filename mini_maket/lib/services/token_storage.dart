import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }

  static Future<void> saveCredentials(String token, String role, int id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
    prefs.setString('role', role);
    prefs.setString('id', id.toString());
  }

  static Future<Map<String, String>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final role = prefs.getString('role') ?? '';
    final id = prefs.getString('id') ?? '';
    return {'token': token, 'role': role, 'id': id};
  }
}
