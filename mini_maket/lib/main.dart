import 'package:flutter/material.dart';
import 'package:mini_maket/screens/admin/quanLyHoaDon.dart';
import 'package:mini_maket/screens/register_screen.dart';
import 'middleware/RoleGuard.dart';
import 'screens/login_screen.dart';
import 'screens/admin/homeadmin_screen.dart';
import 'screens/employee/homeemployee_screen.dart';
import 'middleware/RoleGuard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Market',
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/homeadmin': (context) => RoleGuard(
              child: HomeAdminScreen(),
              requiredRole: 'Admin',
            ),
        '/homeemployee': (context) => RoleGuard(
              child: HomeEmployeeScreen(),
              requiredRole: 'Employee',
            ),
      },
    );
  }
}
