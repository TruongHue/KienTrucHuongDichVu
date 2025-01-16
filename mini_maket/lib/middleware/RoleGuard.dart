import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_maket/screens/login_screen.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final String requiredRole;

  RoleGuard({required this.child, required this.requiredRole});

  Future<bool> _checkAccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? role = prefs.getString('role');
    return role == requiredRole;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAccess(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData && snapshot.data == true) {
          return child; // Vai trò hợp lệ, truy cập được
        } else {
          return LoginScreen(); // Vai trò không hợp lệ, quay lại trang đăng nhập
        }
      },
    );
  }
}
