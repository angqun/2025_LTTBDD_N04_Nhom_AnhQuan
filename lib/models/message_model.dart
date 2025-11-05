// lib/models/message_model.dart
// BẢN CẬP NHẬT: Thêm 'newMessageCount' (Number)

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageThread {
  final String id;
  final String username;
  final String avatarUrl;
  final String lastMessageKey; // (Dùng cho "Đã gửi", "Đã xem")
  final int newMessageCount;  // <<< THAY ĐỔI 1: Thêm (kiểu int)
  final Timestamp? timestamp; 
  final bool isRead;
  final String seenStatus;

  MessageThread({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.lastMessageKey, 
    required this.newMessageCount, // <<< THAY ĐỔI 2
    required this.timestamp, 
    required this.isRead,
    required this.seenStatus,
  });

  factory MessageThread.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageThread(
      id: doc.id,
      username: data['username'] ?? 'No Username',
      avatarUrl: data['avatarUrl'] ?? '',
      lastMessageKey: data['lastMessageKey'] ?? '', 
      newMessageCount: data['newMessageCount'] ?? 0, // <<< THAY ĐỔI 3
      timestamp: data['timestamp'], 
      isRead: data['isRead'] ?? true,
      seenStatus: data['seenStatus'] ?? 'none',
    );
  }
}