// lib/models/profile_story_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileStory {
  final String id;
  final String title;
  final String imageUrl;

  ProfileStory({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  factory ProfileStory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProfileStory(
      id: doc.id,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}