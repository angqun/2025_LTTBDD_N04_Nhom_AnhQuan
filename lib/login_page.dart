// lib/login_page.dart
// BẢN HOÀN CHỈNH: ĐÃ DỊCH NÚT FACEBOOK

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:provider/provider.dart';

// (Giả sử tên dự án là 'btl' và bạn đã tạo 2 file này)
import 'package:btl/providers/language_provider.dart'; 
import 'package:btl/l10n/app_strings.dart'; 


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Xóa '_selectedLanguage' vì Provider sẽ quản lý
  bool _isLoginMode = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HÀM XỬ LÝ LOGIC ---
  // (Giữ nguyên toàn bộ code logic của bạn)

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z]{2,})+$"
    );
    return emailRegex.hasMatch(email);
  }

  Future<void> _logIn() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Định dạng email không hợp lệ!')),
      );
      return; 
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );
      print('Đăng nhập thành công, AuthWrapper sẽ tự động chuyển trang.');
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Sai email hoặc mật khẩu. Vui lòng thử lại.';
      } else if (e.code == 'invalid-email') { 
        message = 'Email không hợp lệ.';
      }
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _signUp() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final email = _emailController.text.trim(); 
    if (!_isValidEmail(email)) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Định dạng email không hợp lệ!')),
      );
      return; 
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Mật khẩu nhập lại không khớp!')),
      );
      return; 
    }
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: _passwordController.text.trim(),
      );
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'createdAt': Timestamp.now(),
          'ten': 'New User' 
        });
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email này đã được sử dụng.';
      } else if (e.code == 'invalid-email') { 
        message = 'Email không hợp lệ.';
      }
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }
  
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- GIAO DIỆN (UI) ---

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // LẤY PROVIDER NGÔN NGỮ (listen: true)
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.05),
                  
                  _buildLanguageDropdown(lang), // Sửa lại hàm này
                  
                  const SizedBox(height: 50.0),
                  Text(
                    'AnhQuan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.satisfy(fontSize: 50, color: Colors.black),
                  ),
                  const SizedBox(height: 40.0),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    // Truyền 'lang' vào các hàm build form
                    child: _isLoginMode
                        ? _buildLoginForm(lang)
                        : _buildSignUpForm(lang),
                  ),

                  SizedBox(height: size.height * 0.1),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET CON (ĐÃ SỬA ĐỂ DÙNG 'lang') ---

  Widget _buildLoginForm(LanguageProvider lang) {
    return Column(
      key: ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () { print('Nút Facebook (không có backend)'); },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            elevation: 0,
          ),
          icon: const Icon(FontAwesomeIcons.facebookSquare, size: 20),
          // <<< SỬA LỖI Ở ĐÂY: DÙNG lang.get()
          label: Text(
            lang.get('continue_with_facebook'), // Đã dịch
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(height: 30.0),
        _buildOrDivider(),
        const SizedBox(height: 30.0),
        
        // Dùng 'lang.get()' để lấy text
        _buildTextField(lang.get('email_hint'), false, _emailController),
        const SizedBox(height: 12.0),
        _buildTextField(lang.get('password_hint'), true, _passwordController),
        
        const SizedBox(height: 12.0),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text(
              lang.get('forgot_password'), // Đã dịch
              style: TextStyle(color: Color(0xFF00376B), fontSize: 12.0, fontWeight: FontWeight.w500)
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: _logIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 99, 184, 240),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            elevation: 0.0,
          ),
          child: Text(
            lang.get('login_button_text'), // Đã dịch
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lang.get('no_account'), // Đã dịch
              style: TextStyle(color: Colors.grey[600], fontSize: 13.0)
            ),
            TextButton(
              onPressed: _toggleMode, 
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4.0), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(
                lang.get('sign_up'), // Đã dịch
                style: TextStyle(color: Color(0xFF00376B), fontWeight: FontWeight.bold, fontSize: 13.0)
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpForm(LanguageProvider lang) {
    return Column(
      key: ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          lang.get('create_new_account'), // Đã dịch
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        const SizedBox(height: 30.0),
        
        _buildTextField(lang.get('email_hint'), false, _emailController),
        const SizedBox(height: 12.0),
        _buildTextField(lang.get('password_hint'), true, _passwordController),
        const SizedBox(height: 12.0),
        _buildTextField(lang.get('confirm_password_hint'), true, _confirmPasswordController),
        
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: _signUp, 
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 99, 184, 240),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            elevation: 0.0,
          ),
          child: Text(
            lang.get('sign_up'), // Đã dịch
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lang.get('already_have_account'), // Đã dịch
              style: TextStyle(color: Colors.grey[600], fontSize: 13.0)
            ),
            TextButton(
              onPressed: _toggleMode, 
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4.0), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(
                lang.get('login_button_text'), // Đã dịch
                style: TextStyle(color: Color(0xFF00376B), fontWeight: FontWeight.bold, fontSize: 13.0)
              ),
            ),
          ],
        ),
      ],
    );
  }

  // LẬP TRÌNH LẠI HÀM NÀY ĐỂ KẾT NỐI VỚI PROVIDER
  Widget _buildLanguageDropdown(LanguageProvider lang) {
    return Align(
      alignment: Alignment.center,
      child: DropdownButton<String>(
        value: lang.locale.languageCode, // Lấy 'vi' hoặc 'en' từ provider
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        underline: Container(), // Ẩn gạch chân
        items: <String>['vi', 'en'] // Giá trị thực
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            // Hiển thị text 'Tiếng Việt' hoặc 'English'
            // Lấy từ file AppStrings (cần import)
            child: Text(
              value == 'vi' ? AppStrings.vi['language_name']! : AppStrings.en['language_name']!,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue == null) return;
          // Gọi hàm setLanguage trong provider
          Provider.of<LanguageProvider>(context, listen: false)
              .setLanguage(Locale(newValue));
        },
      ),
    );
  }

  // (Các hàm build UI phụ trợ này được giữ nguyên từ code của bạn)
  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: Colors.grey[300]),
        const SizedBox(height: 8.0),
        Text('from', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 2.0),
        const Text('FACEBOOK', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(String hintText, bool isPassword, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(fontSize: 14.0, color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0), borderSide: BorderSide(color: Colors.grey[500]!)),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[400])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('OR', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12.0)),
        ),
        Expanded(child: Divider(color: Colors.grey[400])),
      ],
    );
  }
}