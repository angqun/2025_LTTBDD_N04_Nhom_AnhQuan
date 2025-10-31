// lib/main.dart
// BẢN HOÀN CHỈNH: ĐÃ SỬA LỖI IMPORT

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:provider/provider.dart'; 

// <<< CÁC DÒNG QUAN TRỌNG BỊ THIẾU
import 'package:shared_preferences/shared_preferences.dart'; 
// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/providers/language_provider.dart'; 
import 'package:btl/home_screen.dart';
import 'package:btl/login_page.dart';


// 1. HÀM MAIN
void main() async {
  // Đảm bảo Flutter sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Tải ngôn ngữ đã lưu trước khi chạy app
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language_code') ?? 'vi'; 
  
  runApp(
    ChangeNotifierProvider(
      // Truyền code đã tải vào Provider
      create: (context) => LanguageProvider(languageCode),
      child: MyApp(), 
    ),
  );
}

// 2. LỚP MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    // Dùng Consumer để build lại MaterialApp khi đổi ngôn ngữ
    return Consumer<LanguageProvider>(
      
      // Tối ưu hóa: 'child' (AuthWrapper) sẽ không bị build lại
      child: AuthWrapper(),
      
      builder: (context, languageProvider, child) {
        
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'BTL Flutter',
          
          // --- Cài đặt đa ngôn ngữ ---
          locale: languageProvider.locale, 
          supportedLocales: [
            Locale('en', ''),
            Locale('vi', ''),
          ],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          
          // Dùng 'child' đã được build sẵn để giữ state
          home: child, 
        );
      },
    );
  }
}

// 3. LỚP AuthWrapper (Không đổi)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return HomeScreen(); // Đã đăng nhập
        }
        else {
          return LoginPage(); // Chưa đăng nhập
        }
      },
    );
  }
}