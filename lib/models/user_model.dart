// lib/models/user_model.dart
// BẢN CẬP NHẬT: THÊM toJson/fromJson ĐỂ LƯU VÀO BỘ NHỚ

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert'; // <<< THÊM 1: Cần để mã hóa JSON

class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String email;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.email,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'] ?? '',
      email: data['email'] ?? '',
    );
  }

  // <<< THÊM 2: HÀM ĐỂ BIẾN Model THÀNH Map (để lưu)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'email': email,
    };
  }

  // <<< THÊM 3: HÀM ĐỂ BIẾN Map THÀNH Model (để tải)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '', // Thêm ?? '' để an toàn
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      email: json['email'] ?? '',
    );
  }
}