// lib/pages/post_model.dart
// BẢN CẬP NHẬT: THÊM HÀM ĐỌC TỪ FIRESTORE

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id; // <-- ID của document trên Firestore
  final String username;
  final String avatarUrl;
  final String imageUrl;
  final String caption;
  final String likeCount;
  bool isLiked;
  bool isBookmarked;

  Post({
    required this.id, // <-- Cần ID
    required this.username,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
    required this.likeCount,
    this.isLiked = false,
    this.isBookmarked = false,
  });

  // THAY ĐỔI 1: Thêm một "factory constructor"
  // Hàm này dùng để chuyển đổi một DocumentSnapshot từ Firestore thành đối tượng Post
  factory Post.fromFirestore(DocumentSnapshot doc) {
    // Lấy dữ liệu dưới dạng Map
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Post(
      id: doc.id, // Lấy ID của document
      username: data['username'] ?? 'No Username',
      avatarUrl: data['avatarUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      likeCount: data['likeCount'] ?? '0 lượt thích',
      isLiked: data['isLiked'] ?? false,
      isBookmarked: data['isBookmarked'] ?? false,
    );
  }
}