// lib/login_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedLanguage = 'English';
  bool _isLoginMode = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HÀM XỬ LÝ LOGIC ---

  bool _isValidEmail(String email) {
    // RegEx chuẩn
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
      print('Lỗi đăng nhập: $message');
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
      // 1. Tạo User trong Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: _passwordController.text.trim(),
      );
      
      print('Đăng ký Auth thành công: ${userCredential.user?.email}');

      // 2. Lưu thông tin user vào Cloud Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'createdAt': Timestamp.now(),
          'ten': 'New User' 
        });
        print('Đã lưu user vào Firestore database.');
      }
      
      // <<< ĐÃ XÓA PHẦN GỬI EMAIL XÁC THỰC >>>

      // Tự động đăng nhập và chuyển trang
      print('Đăng ký và đăng nhập thành công. Sắp chuyển trang...');

    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email này đã được sử dụng.';
      } else if (e.code == 'invalid-email') { 
        message = 'Email không hợp lệ.';
      }
      print('Lỗi đăng ký: $message');
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
  // (Không thay đổi gì ở phần UI bên dưới)

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
                  _buildLanguageDropdown(),
                  const SizedBox(height: 50.0),
                  Text(
                    'AnhQuan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.satisfy(fontSize: 50, color: Colors.black),
                  ),
                  const SizedBox(height: 40.0),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isLoginMode
                        ? _buildLoginForm()   // Form Đăng nhập
                        : _buildSignUpForm(), // Form Đăng ký
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

  // --- WIDGET CON (Không thay đổi) ---

  Widget _buildLoginForm() {
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
          label: const Text('Continue with Facebook', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 30.0),
        _buildOrDivider(),
        const SizedBox(height: 30.0),
        _buildTextField("Email", false, _emailController),
        const SizedBox(height: 12.0),
        _buildTextField("Password", true, _passwordController),
        const SizedBox(height: 12.0),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('Forgot password?', style: TextStyle(color: Color(0xFF00376B), fontSize: 12.0, fontWeight: FontWeight.w500)),
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
          child: const Text('Log In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Don't have an account?", style: TextStyle(color: Colors.grey[600], fontSize: 13.0)),
            TextButton(
              onPressed: _toggleMode, 
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4.0), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('Sign up', style: TextStyle(color: Color(0xFF00376B), fontWeight: FontWeight.bold, fontSize: 13.0)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      key: ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tạo tài khoản mới',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
        ),
        const SizedBox(height: 30.0),
        _buildTextField("Email", false, _emailController),
        const SizedBox(height: 12.0),
        _buildTextField("Password", true, _passwordController),
        const SizedBox(height: 12.0),
        _buildTextField("Confirm Password", true, _confirmPasswordController),
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
          child: const Text('Sign Up', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 30.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Already have an account?", style: TextStyle(color: Colors.grey[600], fontSize: 13.0)),
            TextButton(
              onPressed: _toggleMode, 
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 4.0), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('Log In', style: TextStyle(color: Color(0xFF00376B), fontWeight: FontWeight.bold, fontSize: 13.0)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown() {
    return Align(
      alignment: Alignment.center,
      child: DropdownButton<String>(
        value: _selectedLanguage,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
        // ... (style) ...
        items: <String>['English', 'Tiếng Việt']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() { _selectedLanguage = newValue!; });
        },
      ),
    );
  }

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