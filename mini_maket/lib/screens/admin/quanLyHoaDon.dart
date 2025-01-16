import 'package:flutter/material.dart';
import 'package:mini_maket/services/InvoiceService.dart';
import 'package:mini_maket/services/token_storage.dart';

class QuanLyHoaDonScreen extends StatefulWidget {
  @override
  _QuanLyHoaDonScreenState createState() => _QuanLyHoaDonScreenState();
}

class _QuanLyHoaDonScreenState extends State<QuanLyHoaDonScreen> {
  List<Map<String, dynamic>> invoices = []; // Danh sách hóa đơn
  List<Map<String, dynamic>> filteredInvoices = []; // Danh sách hóa đơn sau khi lọc

  // Controller cho ô tìm kiếm
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchInvoices(); // Fetch invoices when initializing
  }

  // Hàm lấy hóa đơn từ API
  Future<void> _fetchInvoices() async {
  try {
    final data = await InvoiceService.fetchInvoices();
    setState(() {
      invoices = data;
      filteredInvoices = invoices;
    });

    // In ra log các hóa đơn
    for (var invoice in invoices) {
      print('Mã hóa đơn: ${invoice['invoice_id']}');
      print('Người tạo (user_id): ${invoice['user_id']}');
      
      // Kiểm tra xem 'products' có tồn tại không và nếu có, in ra sản phẩm
      if (invoice['products'] != null && invoice['products'] is List) {
        print('Sản phẩm trong hóa đơn:');
        for (var product in invoice['products']) {
          print(' - ${product['product_name']} | Số lượng: ${product['quantity']} | Giá: ${product['total_amount']}đ');
        }
      } else {
        print('Không có sản phẩm trong hóa đơn.');
      }
    }
  } catch (e) {
    print('Lỗi khi kết nối API: $e');
    setState(() {
      filteredInvoices = [];
    });
  }
}


  // Hàm lọc hóa đơn theo từ khóa
  void _filterInvoices(String query) {
    final filtered = invoices.where((invoice) {
      final invoiceId = invoice['invoice_id'].toString().toLowerCase();
      final userName = invoice['user_name'].toString().toLowerCase();
      //chuyển đổi chữ thường
      final searchQuery = query.toLowerCase();
      
      return invoiceId.contains(searchQuery) || userName.contains(searchQuery);
    }).toList();

  //Cập nhật trạng thái
    setState(() {
      filteredInvoices = filtered;
    });
  }

  // Hàm xem chi tiết hóa đơn
void _showInvoiceDetails(int invoiceId, String totalAmount, String userId, String createdAt) async {
  print(invoiceId);
  try {
    // Gọi API lấy chi tiết hóa đơn bằng cách truyền invoice_id
    final details = await InvoiceService.fetchInvoiceDetails(invoiceId);

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



  // Hàm xóa hóa đơn
  void deleteInvoice(String invoiceId) async {
  // Hiển thị hộp thoại xác nhận
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Xóa hóa đơn'),
        content: Text('Bạn có chắc chắn muốn xóa hóa đơn này?'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                // Gọi API xóa hóa đơn
                await InvoiceService.deleteInvoice(invoiceId);

                // Xóa hóa đơn khỏi danh sách local
                setState(() {
                  invoices.removeWhere((invoice) => invoice['invoice_id'].toString() == invoiceId);
                  filteredInvoices = invoices;
                });

                // Đóng hộp thoại sau khi xóa thành công
                Navigator.pop(context);

                // Hiển thị thông báo thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hóa đơn đã được xóa thành công.')),
                );
              } catch (e) {
                print('Lỗi khi xóa hóa đơn: $e');
                Navigator.pop(context);

                // Hiển thị thông báo lỗi
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi xóa hóa đơn: $e')),
                );
              }
            },
            child: Text('Xóa'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Hủy'),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý hóa đơn'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm hóa đơn',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _filterInvoices(searchController.text),
                ),
              ),
            ),
            Expanded(
              child: filteredInvoices.isEmpty
                  ? Center(child: Text('Không có hóa đơn nào'))
                  : ListView.builder(
                      itemCount: filteredInvoices.length,
                      itemBuilder: (context, index) {
                        final invoice = filteredInvoices[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text('Hóa đơn #${invoice['invoice_id']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Người tạo: ${invoice['user_id']}'),
                                Text('Ngày tạo: ${invoice['created_at']}'),
                                Text('Tổng tiền: ${invoice['total_amount']} đ'),
                                SizedBox(height: 8),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
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
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Chuyển invoice_id thành String khi gọi hàm deleteInvoice
                                    deleteInvoice(invoice['invoice_id'].toString());
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
