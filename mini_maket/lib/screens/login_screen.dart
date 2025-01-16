import 'package:flutter/material.dart';
import 'package:mini_maket/screens/register_screen.dart';
import '../services/api_service.dart'; // Đảm bảo import đúng
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool isLoading = false;

  // Hàm đăng nhập
void _login() async {
  if (_nameController.text.isEmpty || _passwordController.text.isEmpty) {
    setState(() {
      _errorMessage = 'Username and Password are required.';
    });
    return;
  }

  setState(() {
    isLoading = true;
    _errorMessage = ''; // Reset lỗi trước khi gọi API
  });

  try {
    final response = await ApiService.login(
      _nameController.text ,
      _passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (response.containsKey('token') && response.containsKey('role') && response.containsKey('id')) {
      String token = response['token'];
      String role = response['role'];
      String userId = response['id'].toString();

      // Lưu token, role và ID
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', _nameController.text);
      await prefs.setString('role', role);
      await prefs.setString('id', userId);

      // Điều hướng dựa trên vai trò
      if (role == 'Admin') {
        Navigator.pushReplacementNamed(context, '/homeadmin');
      } else if (role == 'Employee') {
        Navigator.pushReplacementNamed(context, '/homeemployee');
      }
    }
  } catch (e) {
    // Xử lý lỗi trả về từ API
    setState(() {
      isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.3,
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.blue.shade100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      prefixIcon: Icon(Icons.person, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue.shade700),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue.shade700),
                      ),
                    ),
                    obscureText: true,
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                  SizedBox(height: 24),
                  if (isLoading)
                    CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(150, 40),
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text("Login", style: TextStyle(color: Colors.white)),
                    ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()),
                      );
                    },
                    child: Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
