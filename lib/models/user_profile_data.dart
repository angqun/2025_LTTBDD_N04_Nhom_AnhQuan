// lib/models/user_profile_data.dart
// BẢN CẬP NHẬT: Đọc Stats (Số liệu) dưới dạng STRING (Văn bản)

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileData {
  final String uid;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final String postCount;       // <<< ĐÃ ĐỔI LẠI THÀNH String
  final String followerCount;   // <<< ĐÃ ĐỔI LẠI THÀNH String
  final String followingCount;  // <<< ĐÃ ĐỔI LẠI THÀNH String

  UserProfileData({
    required this.uid,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
  });

  factory UserProfileData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfileData(
      uid: data['uid'] ?? '',
      username: data['username'] ?? 'username',
      displayName: data['displayName'] ?? 'Display Name',
      avatarUrl: data['avatarUrl'] ?? 'https://picsum.photos/id/1005/100/100',
      bio: data['bio'] ?? '',
      
      // <<< Đọc dữ liệu (kể cả là Number) và chuyển nó thành String
      postCount: (data['postCount'] ?? 0).toString(),
      followerCount: (data['followerCount'] ?? '0').toString(),
      followingCount: (data['followingCount'] ?? '0').toString(),
    );
  }
}