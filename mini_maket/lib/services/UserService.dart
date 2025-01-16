import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final String apiUrl = 'http://localhost:8000/api/users'; // URL của API

  // Hàm lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Lấy token đã lưu trong SharedPreferences
  }

  // Hàm lấy danh sách người dùng từ API
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw 'Token không hợp lệ hoặc không tồn tại.';
    }

    final response = await http.get(
      Uri.parse('$apiUrl/users'),
      headers: {
        'Authorization': 'Bearer $token', // Gửi token trong header
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => Map<String, dynamic>.from(user)).toList();
    } else {
      throw 'Không thể lấy danh sách người dùng.';
    }
  }

  // Hàm xóa người dùng từ API
  Future<void> deleteUser(String userId) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw 'Token không hợp lệ hoặc không tồn tại.';
    }

    final response = await http.delete(
      Uri.parse('$apiUrl/users/$userId'),
      headers: {
        'Authorization': 'Bearer $token', // Gửi token trong header
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw 'Không thể xóa người dùng.';
    }
  }

  // Hàm lọc danh sách người dùng theo từ khóa tìm kiếm và role
  List<Map<String, dynamic>> filterUsers(List<Map<String, dynamic>> users, String query, String? selectedRole) {
    query = query.toLowerCase();
    return users.where((user) {
      final name = user['name'].toLowerCase();
      final email = user['email'].toLowerCase();
      final role = user['role'].toLowerCase();

      bool matchesSearch = name.contains(query) || email.contains(query);
      bool matchesRole = selectedRole == 'All' || role == selectedRole?.toLowerCase();

      return matchesSearch && matchesRole;
    }).toList();
  }
}
