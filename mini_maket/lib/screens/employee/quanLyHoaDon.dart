import 'package:flutter/material.dart';
import 'package:mini_maket/services/InvoiceEmployeeService.dart';

class QuanLyHoaDonEmployeeScreen extends StatefulWidget {
  @override
  _QuanLyHoaDonEmployeeScreenState createState() => _QuanLyHoaDonEmployeeScreenState();
}

class _QuanLyHoaDonEmployeeScreenState extends State<QuanLyHoaDonEmployeeScreen> {
  List<Map<String, dynamic>> invoices = [];

  @override
  void initState() {
    super.initState();
    _fetchInvoices(); // Fetch invoices when initializing
  }

  // Fetch invoices from the API
  Future<void> _fetchInvoices() async {
    try {
      final data = await InvoiceEmployeeService.fetchInvoices();
      setState(() {
        invoices = data;
      });
    } catch (e) {
      print('Error fetching invoices: $e');
      setState(() {
        invoices = [];
      });
    }
  }

  // Show invoice details in a dialog
void _showInvoiceDetails(int invoiceId, String totalAmount, String userId, String createdAt) async {
  print(invoiceId);
  try {
    // Gọi API lấy chi tiết hóa đơn bằng cách truyền invoice_id
    final details = await InvoiceEmployeeService.fetchInvoiceDetails(invoiceId);

    // Hiển thị chi tiết trong AlertDialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Chi tiết hóa đơn',
            textAlign: TextAlign.center, // Căn giữa tiêu đề
            style: TextStyle(fontWeight: FontWeight.bold), // In đậm tiêu đề
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Thêm padding bên ngoài
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mã hóa đơn: $invoiceId',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Người tạo: $userId',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ngày tạo: $createdAt',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Chi tiết sản phẩm:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10), // Khoảng cách giữa tiêu đề và danh sách sản phẩm
                  Column(
                    children: (details as List).map<Widget>((product) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0), // Khoảng cách giữa các item
                        child: ListTile(
                          title: Text(
                            '${product['product_name']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Mã sản phẩm: ${product['product_code']} - Số lượng: ${product['quantity']} x ${product['unit_price']}đ',
                          ),
                          trailing: Text(
                            '${product['total_price']}đ',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Divider(),
                  SizedBox(height: 10), // Khoảng cách trước tổng tiền
                  Text(
                    'Tổng tiền: $totalAmount đ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueAccent, // Màu sắc nổi bật cho tổng tiền
                    ),
                  ),
                  SizedBox(height: 10), // Khoảng cách dưới
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Đóng'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    print('Lỗi khi lấy chi tiết hóa đơn: $e');
  }
}


  // Build the UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: invoices.isEmpty
            ? Center(child: CircularProgressIndicator()) // Show loading indicator when data is not available
            : ListView.builder(
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        'Hóa đơn #${invoice['invoice_id']}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ngày tạo: ${invoice['created_at']}', style: TextStyle(fontSize: 14)),
                          SizedBox(height: 6),
                          Text(
                            'Tổng tiền: ${invoice['total_amount']}đ',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                                  icon: Icon(Icons.remove_red_eye, color: Colors.blue),
                                  onPressed: () {
                                    // Truyền invoice_id dưới dạng String (nếu invoice['invoice_id'] là String)
                                    _showInvoiceDetails(
                                      int.parse(invoice['invoice_id'].toString()), 
                                      invoice['total_amount'].toString(),
                                      invoice['user_id'].toString(),
                                      invoice['created_at'].toString(),
                                    );
                                  },
                                ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
