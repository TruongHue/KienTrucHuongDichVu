import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_maket/services/token_storage.dart';

class InvoiceEmployeeService {
  static Future<List<Map<String, dynamic>>> fetchInvoices() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token không hợp lệ');
      }
      
      // Lấy userId từ getUserId()
      final userId = await getUserId();
      if (userId == null) {
        throw Exception('User ID không hợp lệ');
      }

      // Gọi API với userId
      final response = await http.get(
        Uri.parse('http://localhost:8002/api/invoices/user/$userId'), // API endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Không thể tải dữ liệu hóa đơn. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi kết nối API: $e');
    }
  }

  static Future<List<dynamic>> fetchInvoiceDetails(int invoiceId) async {
  print(invoiceId);
      final token = await TokenStorage.getToken();

  // Thêm header vào yêu cầu HTTP
  final response = await http.get(
    Uri.parse('http://localhost:8002/api/invoices/$invoiceId/details'),
    headers: {
      'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    print(response.body);  // In ra dữ liệu nhận được
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load invoice details');
  }
}

  static Future<int?> getUserId() async {
    final credentials = await TokenStorage.getCredentials();
    final idString = credentials['id'];

    if (idString != null && idString.isNotEmpty) {
      return int.tryParse(idString);
    }
    return null;
  }
}
