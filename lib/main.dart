import 'package:flutter/material.dart';
import './screens/HomeScreen.dart';
import './screens/loginScreen.dart'; // Import màn hình Login
import './screens/registerScreen.dart'; // Import màn hình Register

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login and Register Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Đặt màu chủ đạo cho ứng dụng
      ),
      // Định nghĩa các routes
      initialRoute: '/à', // Màn hình mặc định là trang Login
      routes: {
        '/login': (context) => const LoginScreen(), // Route cho trang Login
        '/register': (context) => const RegisterScreen(), // Route cho trang Register
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
