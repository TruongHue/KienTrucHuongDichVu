import 'package:flutter/material.dart';
import 'package:mini_maket/screens/admin/quanLyHoaDon.dart';
import 'package:mini_maket/screens/admin/quanLySanPham.dart';
import 'package:mini_maket/screens/admin/quanLyUser.dart';
import 'package:mini_maket/screens/sanPham.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAdminScreen extends StatefulWidget {
  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? username;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUserInfo();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Người dùng';
    });
  }

  void _logout() async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Xác nhận đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            child: Text('Hủy'),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại
            },
          ),
          TextButton(
            child: Text('Đồng ý'),
            onPressed: () async {
              // Tiến hành đăng xuất
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Điều hướng đến màn hình đăng nhập
              Navigator.of(context).pop(); // Đóng hộp thoại trước
              Navigator.pushReplacementNamed(context, '/login');
            },
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
        backgroundColor: Colors.blue[400], // Màu xanh nhạt hơn
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
            SizedBox(width: 10),
            Text(
              'Chào admin, $username!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blue[100], // Màu sáng cho icon khi chưa chọn
          tabs: [
            Tab(icon: Icon(Icons.home), text: "Trang chủ"),
            Tab(icon: Icon(Icons.shopping_basket), text: "Sản phẩm"),
            Tab(icon: Icon(Icons.people), text: "Người dùng"),
            Tab(icon: Icon(Icons.receipt), text: "Hóa đơn"),
          ],
        ),
        elevation: 3, // Giảm độ dày của header
      ),
      body: Container(
        color: Colors.blue[50], // Nền xanh nhạt cho body
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent(SanPhamScreen(), "Quản lý trang chủ"),
            _buildTabContent(QuanLySanPhamScreen(), "Quản lý sản phẩm"),
            _buildTabContent(QuanLyUserScreen(), "Quản lý người dùng"),
            _buildTabContent(QuanLyHoaDonScreen(), "Quản lý hóa đơn"),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[400], // Cùng màu xanh với AppBar
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý hệ thống',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Icon(Icons.settings, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Widget child, String title) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue[200]!, width: 1.5),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.blue[100]!,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color.fromRGBO(21, 101, 192, 1),
            ),
          ),
          Divider(color: Colors.blue[200]),
          Expanded(child: child),
        ],
      ),
    );
  }
}
