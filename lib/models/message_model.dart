// lib/models/message_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageThread {
  final String id;
  final String username;
  final String avatarUrl;
  final String lastMessage;
  final String timestamp;
  final bool isRead;
  final String seenStatus; // 'none' hoặc 'camera'

  MessageThread({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.lastMessage,
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
      lastMessage: data['lastMessage'] ?? '',
      timestamp: data['timestamp'] ?? '',
      isRead: data['isRead'] ?? true,
      seenStatus: data['seenStatus'] ?? 'none',
    );
  }
}