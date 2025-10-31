// lib/widgets/story_bubble.dart
// BẢN CẬP NHẬT: Nhận avatarUrl

import 'package:flutter/material.dart';

class StoryBubble extends StatelessWidget {
  final String username;
  final String avatarUrl; // <<< THÊM CÁI NÀY

  const StoryBubble({
    super.key,
    required this.username,
    // Dùng ảnh mặc định nếu không có avatarUrl
    this.avatarUrl = 'https://picsum.photos/id/237/100/100', 
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.yellow, Colors.orange, Colors.red],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0), // Độ dày của viền
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0), // Khoảng cách giữa viền và ảnh
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(avatarUrl), // <<< DÙNG avatarUrl
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(username, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}