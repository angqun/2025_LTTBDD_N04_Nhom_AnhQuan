// lib/models/reel_model.dart
// BẢN CẬP NHẬT: Thêm 'isLiked' (giữ lại albumArtUrl)

import 'package:cloud_firestore/cloud_firestore.dart';

class Reel {
  final String id; 
  final String videoUrl;
  final String username;
  final String avatarUrl;
  final String musicName;
  final String albumArtUrl;  // <<< GIỮ NGUYÊN TRƯỜNG NÀY
  final String caption;
  final String likeCount;
  final String commentCount;
  final String repostCount;  
  final String sendCount;
  final Timestamp? timestamp; 
  bool isLiked; // <<< THÊM 1: Thêm trường isLiked

  Reel({
    required this.id, 
    required this.videoUrl,
    required this.username,
    required this.avatarUrl,
    required this.musicName,
    required this.albumArtUrl, // <<< GIỮ NGUYÊN
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.repostCount, 
    required this.sendCount,
    this.timestamp, 
    this.isLiked = false, // <<< THÊM 2: Thêm vào constructor
  });

  factory Reel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Reel(
      id: doc.id,
      videoUrl: data['videoUrl'] ?? '',
      username: data['username'] ?? 'No Username',
      avatarUrl: data['avatarUrl'] ?? '',
      musicName: data['musicName'] ?? 'Original Audio',
      albumArtUrl: data['albumArtUrl'] ?? '', // <<< GIỮ NGUYÊN
      caption: data['caption'] ?? '',
      likeCount: data['likeCount'] ?? '0',
      commentCount: data['commentCount'] ?? '0',
      repostCount: data['repostCount'] ?? '0', 
      sendCount: data['sendCount'] ?? '0',
      isLiked: data['isLiked'] ?? false, // <<< THÊM 3: Đọc từ Firebase
      timestamp: data['timestamp'],
    );
  }
}