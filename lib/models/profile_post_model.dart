// lib/models/profile_post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePost {
  final String id;
  final String imageUrl;
  final bool isReel;

  ProfilePost({
    required this.id,
    required this.imageUrl,
    this.isReel = false,
  });

  factory ProfilePost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProfilePost(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      isReel: data['isReel'] ?? false,
    );
  }
}