// lib/widgets/story_bubble.dart

import 'package:flutter/material.dart';

class StoryBubble extends StatelessWidget {
  final String username;
  
  const StoryBubble({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          // Vòng tròn màu cam/tím
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.red, Colors.purple],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            // Ảnh đại diện bên trong
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage('https://picsum.photos/id/1012/100/100'),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            username,
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}