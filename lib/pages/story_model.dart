// lib/pages/story_model.dart
// BẢN CẬP NHẬT: THÊM musicUrl

import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String username;
  final String avatarUrl;
  final String storyImageUrl;
  bool isLiked;
  final String? musicUrl; // <<< THÊM DÒNG NÀY (dấu ? nghĩa là có thể null)

  Story({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.storyImageUrl,
    this.isLiked = false,
    this.musicUrl, // <<< THÊM DÒNG NÀY
  });

  factory Story.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Story(
      id: doc.id,
      username: data['username'] ?? 'No Username',
      avatarUrl: data['avatarUrl'] ?? '',
      storyImageUrl: data['storyImageUrl'] ?? '',
      isLiked: data['isLiked'] ?? false,
      musicUrl: data['musicUrl'], // <<< THÊM DÒNG NÀY (sẽ là null nếu không có)
    );
  }
}