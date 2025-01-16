import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Thay bằng màn hình đăng nhập của bạn

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // Hàm tải thông tin người dùng
  void _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Người dùng';
    });
  }

  // Hàm đăng xuất
  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa toàn bộ thông tin
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Chuyển về màn hình đăng nhập
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chào, $username!'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: _logout, // Gọi hàm đăng xuất
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Thêm sản phẩm'),
              Tab(text: 'Sửa sản phẩm'),
              Tab(text: 'Xóa sản phẩm'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('Thêm sản phẩm')),
            Center(child: Text('Sửa sản phẩm')),
            Center(child: Text('Xóa sản phẩm')),
          ],
        ),
      ),
    );
  }
}
