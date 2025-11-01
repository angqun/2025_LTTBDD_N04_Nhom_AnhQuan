// lib/pages/story_model.dart
// BẢN CẬP NHẬT: ĐÃ THÊM 'timestamp'

import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String username;
  final String avatarUrl;
  final String storyImageUrl;
  bool isLiked;
  final String? musicUrl; 
  final Timestamp? timestamp; // <<< THÊM DÒNG NÀY

  Story({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.storyImageUrl,
    this.isLiked = false,
    this.musicUrl,
    this.timestamp, // <<< THÊM DÒNG NÀY
  });

  // Hàm để đọc dữ liệu từ Firestore
  factory Story.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Story(
      id: doc.id,
      username: data['username'] ?? 'No Username',
      avatarUrl: data['avatarUrl'] ?? '',
      storyImageUrl: data['storyImageUrl'] ?? '',
      isLiked: data['isLiked'] ?? false,
      musicUrl: data['musicUrl'], 
      timestamp: data['timestamp'], // <<< THÊM DÒNG NÀY
    );
  }
}