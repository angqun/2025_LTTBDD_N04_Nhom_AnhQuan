// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// <<< HAI DÒNG QUAN TRỌNG ĐỂ SỬA LỖI ẢNH TRƯỚC >>>
import 'home_screen.dart';
import 'login_page.dart';

// 1. HÀM MAIN (Khởi tạo Firebase)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

// 2. LỚP MyApp
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BTL Flutter',
      home: AuthWrapper(), // Dùng AuthWrapper làm trang chủ
    );
  }
}

// 3. LỚP AuthWrapper (Rất quan trọng)
// Widget "gác cổng" tự động chuyển trang
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      
      builder: (context, snapshot) {
        // Trạng thái 1: Đang chờ kết nối
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Trạng thái 2: Nếu user ĐÃ ĐĂNG NHẬP (snapshot có dữ liệu)
        if (snapshot.hasData) {
          return HomeScreen(); // Tự động vào Home
        }

        // Trạng thái 3: Nếu user CHƯA ĐĂNG NHẬP
        else {
          return LoginPage(); // Tự động về Login
        }
      },
    );
  }
}