// lib/widgets/story_bar.dart
// WIDGET NÀY CHỈ CHỊU TRÁCH NHIỆM CHO THANH STORY

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/providers/language_provider.dart';
import 'package:btl/pages/story_model.dart';
import 'package:btl/pages/story_view_page.dart';
import 'package:btl/widgets/story_bubble.dart';


class StoryBar extends StatelessWidget {
  // Nhận collection 'storys' từ HomeScreen
  final CollectionReference storiesCollection;

  const StoryBar({
    super.key,
    required this.storiesCollection,
  });

  @override
  Widget build(BuildContext context) {
    // Đây chính là code _buildStoryBar() cũ của bạn
    
    return Container(
      height: 110,
      child: StreamBuilder<QuerySnapshot>( 
        stream: storiesCollection.snapshots(), // Dùng collection được truyền vào
        builder: (context, storySnapshot) {
          
          // Lấy 'lang' provider để dịch
          final lang = Provider.of<LanguageProvider>(context);

          if (storySnapshot.hasError) return Center(child: Text(lang.get('loading_story_error')));
          
          // (Không cần vòng xoay loading, vì widget này được build 1 lần)
          
          final storyDocs = storySnapshot.data?.docs ?? []; 
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: storyDocs.length + 1, // +1 cho "Tin của bạn"
            itemBuilder: (context, index) {
              
              // Mục 0: "Tin của bạn" (Vô hiệu hóa)
              if (index == 0) {
                return GestureDetector(
                  onTap: () {}, // Vô hiệu hóa
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 33,
                              backgroundImage: NetworkImage('https://picsum.photos/id/1005/100/100'),
                            ),
                            Positioned(
                              bottom: -2, right: -2,
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: Icon(Icons.add_circle, color: Colors.blue, size: 24),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(lang.get('your_story'), style: TextStyle(fontSize: 12)) // Đã dịch
                      ],
                    ),
                  ),
                );
              }
              
              // Các mục khác: Story từ Firebase
              final doc = storyDocs[index - 1]; 
              final story = Story.fromFirestore(doc);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryViewPage(
                        username: story.username,
                        imageUrl: story.storyImageUrl,
                        storyId: story.id, 
                        initialIsLiked: story.isLiked, 
                        musicUrl: story.musicUrl, // Truyền link nhạc
                      ),
                    ),
                  );
                },
                child: StoryBubble(
                  username: story.username,
                  avatarUrl: story.avatarUrl,
                ),
              );
            },
          );
        },
      ),
    );
  }
}