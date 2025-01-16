import 'package:flutter/material.dart';
import 'package:mini_maket/services/UserService.dart';

class QuanLyUserScreen extends StatefulWidget {
  @override
  _QuanLyUserScreenState createState() => _QuanLyUserScreenState();
}

class _QuanLyUserScreenState extends State<QuanLyUserScreen> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();
  String? _selectedRole;
  List<String> roles = ['All', 'Admin', 'Employee'];
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  // Hàm lấy danh sách người dùng từ API
  Future<void> _fetchUsers() async {
    try {
      final fetchedUsers = await _userService.fetchUsers();
      setState(() {
        users = fetchedUsers;
        filteredUsers = List.from(users);
        isLoading = false;
      });
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  // Hàm lọc danh sách người dùng theo từ khóa tìm kiếm và role
  void _filterUsers() {
    final query = _searchController.text;
    setState(() {
      filteredUsers = _userService.filterUsers(users, query, _selectedRole);
    });
  }

  // Hàm xóa người dùng
  Future<void> _deleteUser(String userId) async {
    try {
      await _userService.deleteUser(userId);
      setState(() {
        users.removeWhere((user) => user['id'].toString() == userId);
        filteredUsers = List.from(users);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xóa người dùng thành công')));
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  // Hàm hiển thị dialog thông báo lỗi
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị thông báo xác nhận xóa người dùng
  Future<void> _showDeleteConfirmationDialog(String userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng này?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(userId);
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm người dùng',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: Text('Chọn vai trò'),
              value: _selectedRole,
              items: roles.map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                  _filterUsers();
                });
              },
              isExpanded: true,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(child: Text('Không có người dùng nào phù hợp.'))
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 5,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(user['id'].toString(),
                                    style: TextStyle(color: Colors.white)),
                              ),
                              title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${user['email']}'),
                                  Text('Role: ${user['role']}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(user['id'].toString());
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
