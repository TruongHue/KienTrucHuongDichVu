import 'package:flutter/material.dart';
import 'package:mini_maket/services/api_service.dart';
import 'package:mini_maket/services/token_storage.dart';

class SanPhamScreen extends StatefulWidget {
  @override
  _SanPhamScreenState createState() => _SanPhamScreenState();
}

class _SanPhamScreenState extends State<SanPhamScreen> {
  List<Map<String, dynamic>> products = [];
  final Map<String, Map<String, dynamic>> selectedProducts = {};
  String searchQuery = '';
  String? token;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    String? storedToken = await TokenStorage.getToken();
    setState(() {
      token = storedToken;
    });
    if (token != null && token!.isNotEmpty) {
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts() async {
    if (token == null || token!.isEmpty) {
      print('Token không hợp lệ');
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.getProducts(token!);
      setState(() {
        products = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredProducts {
    return products
        .where((product) =>
            product['name']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            product['id'].toString().toLowerCase().contains(searchQuery.toLowerCase())||
            product['code'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  int _calculateTotal() {
    int total = 0;
    selectedProducts.forEach((key, value) {
      total += (value['quantity'] as int) * (value['price'] as int);
    });
    return total;
  }

  void _updateProductQuantityInInvoice(String productId, int quantityChange) {
    setState(() {
      final product = selectedProducts[productId];
      final productInStore = products.firstWhere((p) => p['id'] == productId);

      if (product != null && productInStore != null) {
        final newQuantity = product['quantity'] + quantityChange;
        final newStockQuantity = productInStore['quantity'] - quantityChange;

        if (newStockQuantity >= 0 && newQuantity >= 0) {
          product['quantity'] = newQuantity;
          productInStore['quantity'] = newStockQuantity;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Số lượng không đủ trong kho')),
          );
        }
      }
    });
  }

  void _removeProductFromInvoice(String productId) {
    setState(() {
      final product = selectedProducts[productId];
      final productInStore = products.firstWhere((p) => p['id'] == productId);

      if (product != null && productInStore != null) {
        productInStore['quantity'] += product['quantity'];
        selectedProducts.remove(productId);
      }
    });
  }

  void _cancelInvoice() {
    setState(() {
      selectedProducts.forEach((productId, product) {
        final productInStore = products.firstWhere((p) => p['id'] == productId);
        if (productInStore != null) {
          productInStore['quantity'] += product['quantity'];
        }
      });
      selectedProducts.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã hủy hóa đơn')),
    );
  }

  Future<void> _showConfirmationDialog() async {
    final bool confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xác nhận thanh toán'),
          content: Text(
              'Bạn có chắc chắn muốn thanh toán hóa đơn với tổng tiền ${_calculateTotal()}đ không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      await _handleInvoiceSubmission();
    }
  }

  Future<int?> getUserId() async {
  final credentials = await TokenStorage.getCredentials();
  final idString = credentials['id'];

  if (idString != null && idString.isNotEmpty) {
    return int.tryParse(idString);
  }
  return null;
}


  Future<void> _handleInvoiceSubmission() async {
  if (token == null || token!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Token không hợp lệ.')),
    );
    return;
  }

  // Tính tổng tiền
  int totalAmount = 0;
  List<Map<String, dynamic>> details = [];

  selectedProducts.forEach((key, product) {
    // Kiểm tra giá trị của product['code'], nếu null thì gán giá trị mặc định
    String productCode = product['code'] ?? 'Không có mã'; // Thay giá trị mặc định theo ý bạn

    totalAmount += (product['quantity'] as int) * (product['price'] as double).toInt();
    details.add({
      'product_name': product['name'],
      'product_code': productCode, // Sử dụng giá trị của productCode
      'quantity': product['quantity'],
      'unit_price': product['price'],
      'total_price': product['quantity'] * product['price'],
    });
  });

  // Dữ liệu gửi lên backend
  Map<String, dynamic> invoiceData = {
    'user_id': await getUserId(), // Thay bằng user_id thực tế nếu cần
    'total_amount': totalAmount,
    'details': details,
  };

  try {
    bool success = await ApiService.createInvoice(invoiceData);

    if (success) {
       for (var product in selectedProducts.values) {
        print("Product ID: ${product['id']}, Quantity: ${product['quantity']}");
           await ApiService.updateProductQuantity(
          int.parse(product['id'].toString()), 
          int.parse(product['quantity'].toString())
      );    
    }

      setState(() {
        selectedProducts.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hóa đơn thanh toán thành công!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thanh toán thất bại. Vui lòng thử lại.')),
      );
    }
  } catch (e) {
    print('Error creating invoice: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Có lỗi xảy ra.')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        color: Colors.grey[200],
                        child: GridView.builder(
                          padding: EdgeInsets.all(8.0),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Card(
                              elevation: 3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/${product['image_url']}',
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.error, color: Colors.red);
                                    },
                                  ),
                                  SizedBox(height: 5),
                                  Text(product['name'],
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Mã sản phẩm: ${product['code'].toString()}'),
                                  Text('ID sản phẩm: ${product['id'].toString()}'),
                                  Text('Giá: ${product['price']}đ'),
                                  SizedBox(height: 5),
                                  Text(
                                    'Còn: ${product['quantity']}',
                                    style: TextStyle(
                                      color: product['quantity'] > 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  ElevatedButton(
                                    onPressed: product['quantity'] > 0
                                        ? () {
                                            setState(() {
                                              // Kiểm tra nếu sản phẩm đã có trong giỏ hàng, thì chỉ cần tăng số lượng
                                              if (selectedProducts.containsKey(product['id'])) {
                                                selectedProducts[product['id']]?['quantity']++;
                                              } else {
                                                // Nếu chưa có, thêm sản phẩm vào giỏ hàng
                                                selectedProducts[product['id']] = {
                                                  'id': product['id'],
                                                  'code' : product['code'],
                                                  'name': product['name'],
                                                  'price': double.tryParse(product['price'].toString()) ?? 0.0,
                                                  'quantity': 1,
                                                };
                                              }

                                              // **Cập nhật số lượng kho và giỏ hàng ở đây một lần**
                                              final productInStore = products.firstWhere((p) => p['id'] == product['id']);
                                              if (productInStore != null) {
                                                final newStockQuantity = productInStore['quantity'] - 1;
                                                if (newStockQuantity >= 0) {
                                                  productInStore['quantity'] = newStockQuantity; // Cập nhật lại số lượng trong kho
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Số lượng không đủ trong kho')),
                                                  );
                                                }
                                              }
                                            });
                                          }
                                        : null,
                                    child: Text('Thêm vào hóa đơn'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hóa đơn',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Divider(),
                Expanded(
                  child: selectedProducts.isEmpty
                      ? Center(
                          child: Text(
                            'Chưa có sản phẩm nào trong hóa đơn',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: selectedProducts.length,
                          itemBuilder: (context, index) {
                            final productId =
                                selectedProducts.keys.elementAt(index);
                            final product = selectedProducts[productId]!;

                            return ListTile(
                              title: Text(product['name']),
                              subtitle: Text(
                                'Số lượng: ${product['quantity']} x ${product['price']}đ',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (product['quantity'] > 1) {
                                          _updateProductQuantityInInvoice(productId, -1);
                                        } else {
                                          _removeProductFromInvoice(productId);
                                        }
                                      });
                                    },
                                  ),
                                  Text('${product['quantity']}'),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        _updateProductQuantityInInvoice(productId, 1);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _removeProductFromInvoice(productId);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Tổng cộng: ${_calculateTotal()}đ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: selectedProducts.isNotEmpty
                          ? _showConfirmationDialog
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50), // Tăng kích thước của nút Thanh toán
                        backgroundColor: Colors.green, // Làm nổi bật với màu sắc
                        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Thay đổi kiểu chữ
                      ),
                      child: Text('Thanh toán'),
                    ),
                    ElevatedButton(
                      onPressed: selectedProducts.isNotEmpty
                          ? _cancelInvoice
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Màu đỏ cho nút Hủy
                        minimumSize: Size(100, 40), // Giảm kích thước của nút Hủy
                        textStyle: TextStyle(fontSize: 14), // Kiểu chữ nhỏ hơn
                      ),
                      child: Text('Hủy hóa đơn'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
