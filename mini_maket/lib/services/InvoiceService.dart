import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mini_maket/services/token_storage.dart';

class InvoiceService {
  static Future<List<Map<String, dynamic>>> fetchInvoices() async {
  try {
    final token = await TokenStorage.getToken(); // Lấy token từ SharedPreferences
    if (token == null || token.isEmpty) {
      throw Exception('Token không hợp lệ');
    }

    final response = await http.get(
      Uri.parse('http://localhost:8002/api/invoices'), // API trả về tất cả hóa đơn
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // Kiểm tra xem data có phải là một danh sách hợp lệ không
      if (data == null || data.isEmpty) {
        throw Exception('Không có dữ liệu hóa đơn');
      }

      // Lọc hóa đơn theo user_id nếu cần
      
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


  static Future<void> deleteInvoice(String invoiceId) async {
    try {
      final token = await TokenStorage.getToken();
      final response = await http.delete(
        Uri.parse('http://localhost:8002/api/invoices/$invoiceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Không thể xóa hóa đơn. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa hóa đơn: $e');
    }
  }

  
  static Future<bool> createInvoice(Map<String, dynamic> invoiceData) async {
    final response = await http.post(
      Uri.parse('http://localhost:8002/api/invoices'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(invoiceData),
    );

    return response.statusCode == 201;
  }
}
