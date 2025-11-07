// lib/pages/edit_field_page.dart
// CẬP NHẬT: Thêm 'noteKey' để hiển thị ghi chú đúng

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:btl/providers/language_provider.dart';

class EditFieldPage extends StatefulWidget {
  final String appBarTitle; 
  final String initialValue; 
  final String targetField;  
  final String noteKey; // <<< THÊM: Key cho ghi chú (VD: 'name_rules')

  const EditFieldPage({
    super.key,
    required this.appBarTitle,
    required this.initialValue,
    required this.targetField,
    required this.noteKey, // <<< THÊM
  });

  @override
  State<EditFieldPage> createState() => _EditFieldPageState();
}

class _EditFieldPageState extends State<EditFieldPage> {
  late final TextEditingController _controller;
  bool _isLoading = false;
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    
    _controller.addListener(() {
      final bool isChanged = _controller.text != widget.initialValue;
      final bool isNotEmpty = _controller.text.isNotEmpty;
      // Sửa lại: Nút "Xong" chỉ bật khi có thay đổi
      // (Nhưng vẫn cho lưu nếu giá trị là rỗng, tuỳ bạn)
      if (isChanged != _canSave) {
         setState(() {
          _canSave = isChanged; // Chỉ cần có thay đổi là cho lưu
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- PHẦN BACKEND (LƯU LÊN FIREBASE) ---
  Future<void> _saveChanges() async {
    // Cho phép lưu cả khi rỗng (để xoá tên)
    if (!_canSave || _isLoading) return; 

    setState(() { _isLoading = true; });

    final String newValue = _controller.text.trim();
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      setState(() { _isLoading = false; });
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
            widget.targetField: newValue, 
          });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Lỗi cập nhật: $e");
      setState(() { _isLoading = false; });
    }
  }


  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100], // Màu nền xám mờ như ảnh
      appBar: AppBar(
        backgroundColor: Colors.white, // Appbar vẫn trắng
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          // Nút Xong (khi chưa sửa) hoặc Hủy (khi đã sửa)
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.appBarTitle,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          _isLoading 
            ? Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
              )
            : TextButton(
                child: Text(
                  lang.get('done'), 
                  style: TextStyle(
                    color: _canSave ? Colors.blue : Colors.blue.withOpacity(0.5), // Mờ khi không thể lưu
                    fontSize: 17, 
                    fontWeight: FontWeight.bold
                  ),
                ),
                onPressed: _saveChanges, // Gọi hàm lưu
              )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gói TextField trong nền trắng
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8)
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  border: InputBorder.none, // Bỏ gạch chân
                  labelText: widget.appBarTitle,
                  labelStyle: TextStyle(color: Colors.grey[600], fontSize: 17),
                  suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.cancel_rounded, color: Colors.grey, size: 20),
                        onPressed: () => _controller.clear(),
                      )
                    : null,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Hiển thị ghi chú
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                lang.get(widget.noteKey), // <<< SỬA: Lấy ghi chú động
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}