import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mini_maket/services/token_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000/api/users"; // Địa chỉ API của bạn

  // Đăng nhập và lấy token
static Future<Map<String, dynamic>> login(String name, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Nếu đăng nhập thành công
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return responseData; // Trả về token, role, id
    } else {
      // Nếu đăng nhập thất bại (statusCode != 200)
      final Map<String, dynamic> errorData = jsonDecode(response.body);
      throw Exception(errorData['message']); // Ném lỗi chứa thông báo từ API
    }
  } catch (e) {
    print('Login error: $e'); // In lỗi ra log
    rethrow; // Truyền lỗi về hàm gọi
  }
}

 // Đăng ký tài khoản
static Future<bool> register(String name, String email, String password) async {
  String role = 'Employee';
  try { 
    // In ra dữ liệu trước khi gửi yêu cầu
    print('Registering user:');
    print('Name: $name');
    print('Email: $email');
    print('Password: $password');
    print('Role: $role');

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: json.encode({'name': name, 'email': email, 'password': password, 'role': role}),
      headers: {'Content-Type': 'application/json'},
    );

    // In ra chi tiết response
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // In ra response từ server

    if (response.statusCode == 201) {
      return true;
    } else {
      // Log lỗi chi tiết từ response
      print('Error response: ${response.body}');
      final Map<String, dynamic> responseBody = json.decode(response.body);
      throw Exception(responseBody['message']);
    }
  } catch (e) {
    print('Error during registration: $e');
    rethrow;
  }
}




  // Lấy danh sách sản phẩm
  static Future<List<Map<String, dynamic>>> getProducts(String token) async {
  // Kiểm tra token
  if (token.isEmpty) {
    throw Exception("Token is required");
  }

  try {
    // Gửi yêu cầu GET đến server
    final response = await http.get(
      Uri.parse('http://localhost:8001/api/products'), // $baseUrl là URL của API
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Gửi token trong header
      },
    );

    // Kiểm tra mã phản hồi
    if (response.statusCode == 200) {
      final List<dynamic> responseBody = json.decode(response.body);
      print('Response Body: $responseBody');  // In ra để kiểm tra
        if (responseBody.isEmpty) {
          throw Exception('No products found');
        }
      // Chuyển đổi dữ liệu JSON thành danh sách sản phẩm
      return responseBody.map((product) {
        return {
          'id': product['id'].toString(),
          'name': product['name'],
          'code': product['code'],
          'price': product['price'],
          'quantity': product['quantity'],
          'description': product['description'],
          'image_url': product['image_url'], // Đảm bảo trường này có sẵn
        };
      }).toList();
    } else {
      // Nếu không nhận được mã thành công từ server
      throw Exception('Failed to load products. Server responded with status code ${response.statusCode}');
    }
  } catch (e) {
    // Bắt lỗi nếu có bất kỳ sự cố nào trong khi gửi yêu cầu
    print('Error fetching products: $e');
    throw Exception('Error fetching products: $e');
  }
}


  static Future<bool> createInvoice(Map<String, dynamic> invoiceData) async {
  // Ghi log dữ liệu gửi đi
  print('=== GỬI DỮ LIỆU TẠO HÓA ĐƠN ===');
  print('URL: http://localhost:8002/api/invoices');
  print('Headers: ${{
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${await TokenStorage.getToken()}'
  }}');
  print('Body: ${json.encode(invoiceData)}');
  print('================================');

  final token = await TokenStorage.getToken();
  if (token == null || token.isEmpty) {
    throw Exception("Chưa cung cấp token");
  }

  final response = await http.post(
    Uri.parse('http://localhost:8002/api/invoices'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode(invoiceData),
  );

  // Ghi log phản hồi từ server
  print('=== PHẢN HỒI TỪ SERVER ===');
  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');
  print('============================');

  return response.statusCode == 201;
}

 //cập nhật số lượng
static Future<void> updateProductQuantity(int productId, int quantity) async {
  final token = await TokenStorage.getToken();
  if (token == null || token.isEmpty) {
    throw Exception("Chưa cung cấp token");
  }

  final response = await http.put(
    Uri.parse('http://localhost:8001/api/products/$productId/decrease-quantity'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Gửi token trong header
    },
    body: jsonEncode({
      'id': productId,
      'quantity': quantity,
    }),
  );

  // Log chi tiết phản hồi
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception('Lỗi khi cập nhật số lượng sản phẩm: ${response.body}');
  }
}








static Future<bool> deleteInvoice(String token, String invoiceId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/invoices/$invoiceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Không thể xóa hóa đơn. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa hóa đơn: $e');
    }
  }
  
  
 
}
