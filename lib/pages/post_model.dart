// lib/pages/post_model.dart
// BẢN CẬP NHẬT: Dùng caption_vi và caption_en

import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String username;
  final String avatarUrl;
  final String imageUrl;
  final String caption_vi; // <<< THAY ĐỔI
  final String caption_en; // <<< THAY ĐỔI
  final String likeCount;
  final String commentCount; 
  final String repostCount; 
  final String sendCount;    
  bool isLiked;
  bool isBookmarked;
  final Timestamp? timestamp; 

  Post({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption_vi, // <<< THAY ĐỔI
    required this.caption_en, // <<< THAY ĐỔI
    required this.likeCount,
    required this.commentCount, 
    required this.repostCount, 
    required this.sendCount,    
    this.isLiked = false,
    this.isBookmarked = false,
    this.timestamp, 
  });

  factory Post.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Post(
      id: doc.id,
      username: data['username'] ?? 'No Username',
      avatarUrl: data['avatarUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption_vi: data['caption_vi'] ?? '', // <<< THAY ĐỔI
      caption_en: data['caption_en'] ?? '', // <<< THAY ĐỔI
      likeCount: data['likeCount'] ?? '0',
      commentCount: data['commentCount'] ?? '0',
      repostCount: data['repostCount'] ?? '0', 
      sendCount: data['sendCount'] ?? '0',     
      isLiked: data['isLiked'] ?? false,
      isBookmarked: data['isBookmarked'] ?? false,
      timestamp: data['timestamp'], 
    );
  }
}