import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mini_maket/services/token_storage.dart'; // Import TokenStorage

class QuanLySanPhamScreen extends StatefulWidget {
  @override
  _QuanLySanPhamScreenState createState() => _QuanLySanPhamScreenState();
}

class _QuanLySanPhamScreenState extends State<QuanLySanPhamScreen> {
  String searchQuery = ''; // Biến để lưu giá trị tìm kiếm
  List<Map<String, dynamic>> products = []; // Danh sách sản phẩm

  Future<void> fetchProducts() async {
  try {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Chưa cung cấp token");
    }

    // Gửi yêu cầu GET tới server
    final response = await http.get(
      Uri.parse('http://localhost:8001/api/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // In ra log phản hồi từ server để kiểm tra
      print('Response Body: ${response.body}');

      // Giải mã JSON từ phản hồi
      List<dynamic> data = json.decode(response.body);

      if (data.isEmpty) {
        throw Exception('Không có sản phẩm');
      }

      setState(() {
        products = data.map((item) {
          return {
            'id': item['id'].toInt() ,
            'name': item['name'],
            'price': item['price'], 
            'code': item['code'],
            'quantity': item['quantity'],
            'description' : item['description'],
            'image_url': item['image_url'] ?? 'https://via.placeholder.com/150',
          };
        }).toList();
      });
    } else {
      throw Exception('Không thể tải dữ liệu, mã phản hồi: ${response.statusCode}');
    }
  } catch (e) {
    print("Error fetching products: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Có lỗi xảy ra khi tải sản phẩm: $e')),
    );
  }
}


@override
void initState() {
  super.initState();
  // Dùng Future.delayed để gọi hàm async
  Future.delayed(Duration.zero, () {
    fetchProducts();  // Gọi hàm để lấy sản phẩm khi màn hình được tạo
  });
}


  // Lọc sản phẩm theo từ khóa tìm kiếm
  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final name = product['name'].toLowerCase();
      final code = product['code'].toString().toLowerCase();
      final id = product['id'].toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return name.contains(query) || code.contains(query) || id.contains(query);
    }).toList();
  }

  Future<void> _addProduct(String name, String code, double price, int quantity, String imageUrl, String description) async {
  try {
    final token = await TokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception("Chưa cung cấp token");
    }

    final response = await http.post(
      Uri.parse('http://localhost:8001/api/products'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'code': code,
        'price': price,
        'quantity': quantity,
        'image_url': imageUrl,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      fetchProducts();  // Cập nhật lại danh sách sản phẩm
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sản phẩm đã được thêm thành công')),
      );
    } else if (response.statusCode == 400) {
      // Lấy thông báo lỗi từ server và hiển thị cho người dùng
      final errorResponse = json.decode(response.body);
      final errorMessage = errorResponse['message'] ?? 'Không xác định lỗi';
      throw Exception(errorMessage);
    } else {
      throw Exception('Không thể thêm sản phẩm, mã phản hồi: ${response.statusCode}');
    }
  } catch (e) {
    print("Lỗi khi thêm sản phẩm: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Có lỗi xảy ra khi thêm sản phẩm: $e')),
    );
  }
}


void _showAddProductDialog() {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String code = '';
  double price = 0.0;
  int quantity = 0;
  String description = '';
  String? imageName; // Tên ảnh
  Uint8List? imageBytes; // Dữ liệu ảnh dưới dạng byte array

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Thêm sản phẩm mới'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Tên sản phẩm'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  return null;
                },
                onChanged: (value) => name = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mã sản phẩm'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mã sản phẩm';
                  }
                  return null;
                },
                onChanged: (value) => code = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá';
                  }
                  // Kiểm tra giá phải là số thực và lớn hơn 0
                  final parsedValue = double.tryParse(value);
                  if (parsedValue == null) {
                    return 'Giá phải là một số hợp lệ';
                  }
                  if (parsedValue <= 0) {
                    return 'Giá phải lớn hơn 0';
                  }
                  return null;
                },
                onChanged: (value) => price = double.tryParse(value) ?? 0.0,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Số lượng'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số lượng';
                  }
                  // Kiểm tra số lượng phải là số nguyên và lớn hơn 0
                  final parsedValue = int.tryParse(value);
                  if (parsedValue == null) {
                    return 'Số lượng phải là một số nguyên hợp lệ';
                  }
                  if (parsedValue <= 0) {
                    return 'Số lượng phải lớn hơn 0';
                  }
                  return null;
                },
                onChanged: (value) => quantity = int.tryParse(value) ?? 0,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Chi tiết sản phẩm'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập chi tiết sản phẩm';
                  }
                  return null;
                },
                onChanged: (value) => description = value,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Mở file picker để chọn ảnh
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );
                  if (result != null) {
                    // Lấy dữ liệu byte array và tên file ảnh
                    setState(() {
                      imageBytes = result.files.single.bytes;
                      imageName = result.files.single.name;
                    });
                    print('Tên ảnh: $imageName');
                      print('imageBytes: ${imageBytes?.length}');

                  }
                },
                child: Text(imageName == null ? 'Chọn ảnh' : 'Đổi ảnh'),
              ),
        
              // Hiển thị ảnh đã chọn nếu có
              if (imageName != null)
                Column(
                  children: [
                    SizedBox(height: 10),
                    Text('Tên ảnh: $imageName'),
                    SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        imageBytes!,
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              // Nếu không có ảnh, hiển thị thông báo
              if (imageBytes == null)
                Column(
                  children: [
                    SizedBox(height: 10),
                    Text('Chưa chọn ảnh'),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                _addProduct(name, code, price, quantity, imageName ?? '', description);
                Navigator.of(context).pop();
              }
            },
            child: Text('Thêm'),
          ),
        ],
      );
    },
  );
}


void _editProduct(int productId, String currentPrice, String currentQuantity, String code) {
  TextEditingController priceController = TextEditingController(text: currentPrice);
  TextEditingController quantityController = TextEditingController(text: currentQuantity);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Chỉnh sửa sản phẩm $code',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trường chỉnh sửa giá
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá sản phẩm',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              // Trường chỉnh sửa số lượng
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số lượng',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String updatedPrice = priceController.text.trim();
              String updatedQuantity = quantityController.text.trim();

              // Kiểm tra dữ liệu nhập vào
              if (updatedPrice.isEmpty || updatedQuantity.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
                );
                return;
              }

              try {
                // Gọi API để cập nhật sản phẩm
                await updateProduct(productId, updatedPrice, updatedQuantity);
                await fetchProducts();  
                // Thông báo cập nhật thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cập nhật sản phẩm thành công')),
                );

                Navigator.pop(context); // Đóng dialog
                setState(() {}); // Cập nhật lại giao diện

              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi cập nhật sản phẩm')),
                );
              }
            },
            child: Text('Lưu'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog nếu nhấn Hủy
            },
            child: Text('Hủy'),
          ),
        ],
      );
    },
  );
}


void _deleteProduct(int productId) async {
  print("Đang gọi hàm xóa sản phẩm với ID: $productId");

  // Kiểm tra kiểu dữ liệu của productId và product['id']
  print("productId type: ${productId.runtimeType}");

  // Hiển thị hộp thoại xác nhận trước khi xóa
  bool? confirmDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa sản phẩm này không?'),
        actions: <Widget>[
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop(false); // Không xóa, đóng hộp thoại
            },
          ),
          TextButton(
            child: Text('Xóa'),
            onPressed: () {
              Navigator.of(context).pop(true); // Xóa sản phẩm
            },
          ),
        ],
      );
    },
  );

  if (confirmDelete != null && confirmDelete) {
    try {
      final token = await TokenStorage.getToken(); // Lấy token từ SharedPreferences

      if (token == null || token.isEmpty) {
        throw Exception("Chưa cung cấp token");
      }

      final response = await http.delete(
        Uri.parse('http://localhost:8001/api/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Thêm Authorization header với token
        },
      );

      if (response.statusCode == 200) {
        // Nếu xóa thành công, cập nhật lại danh sách sản phẩm
        setState(() {
          // Kiểm tra kiểu dữ liệu và chuyển kiểu khi cần thiết
          products.removeWhere((product) => product['id'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sản phẩm đã được xóa')),
        );
      } else if (response.statusCode == 401) {
        throw Exception('Token không hợp lệ hoặc đã hết hạn');
      } else {
        throw Exception('Không thể xóa sản phẩm');
      }
    } catch (e) {
      print("Error deleting product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Có lỗi xảy ra khi xóa sản phẩm')),
      );
    }
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý sản phẩm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Tìm kiếm sản phẩm',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Cập nhật từ khóa tìm kiếm
                });
              },
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? Center(child: CircularProgressIndicator()) // Hiển thị loading khi chưa có sản phẩm
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/${product['image_url']}', // Đảm bảo tên hình đúng
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Nếu không thể tải hình ảnh, hiển thị thông báo lỗi
                                print("Lỗi tải hình ảnh: ${product['image_url']}"); // Debug lỗi tên hình ảnh
                                return Icon(Icons.error, color: Colors.red);
                              },
                            ),
                          ),
                          title: Text(
                            product['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mã sản phẩm: ${product['code']}'),
                              Text('Giá: ${product['price']}đ'),
                              Text('Số lượng: ${product['quantity']}'),
                              Text('ID sản phẩm: ${product['id']}'),
                              Text('Chi tiết sản phẩm: ${product['description']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _editProduct(
                                    int.parse(product['id'].toString()),  // ID giữ nguyên là int
                                    product['price'].toString(),          // Ép kiểu sang String
                                    product['quantity'].toString(),
                                    product['code'].toString(),       // Ép kiểu sang String
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                _deleteProduct(product['id']);
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,  // Mở dialog thêm sản phẩm
        child: Icon(Icons.add),
      ),
    );
  }
  
  updateProduct(int productId, String price, String quantity) async {
     try {
      final token = await TokenStorage.getToken();
      final response = await http.put(
        Uri.parse('http://localhost:8001/api/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'price': price,
          'quantity': quantity,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi cập nhật sản phẩm');
      }
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
  }





