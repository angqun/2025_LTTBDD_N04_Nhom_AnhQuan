// lib/pages/feed_page.dart
// WIDGET NÀY CHỈ CHỊU TRÁCH NHIỆM CHO TRANG FEED

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/providers/language_provider.dart';
import 'package:btl/pages/post_model.dart';
import 'package:btl/widgets/post_card.dart';

class FeedPage extends StatelessWidget {
  // Trang này cần các "nguyên liệu" từ HomeScreen (cha)
  final Widget storyBar;
  final CollectionReference postsCollection;
  final Function(String, bool) onLikeToggle;
  final Function(String, bool) onBookmarkToggle;
  final Function(String) onCommentPressed;
  final Function(String) onSendPressed;

  const FeedPage({
    super.key,
    required this.storyBar,
    required this.postsCollection,
    required this.onLikeToggle,
    required this.onBookmarkToggle,
    required this.onCommentPressed,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Đây chính là code _buildFeedPage() cũ của bạn
    
    // StreamBuilder cho Posts
    return StreamBuilder<QuerySnapshot>(
      stream: postsCollection.snapshots(), 
      
      builder: (context, postSnapshot) {
        // Lấy 'lang' provider để dịch
        final lang = Provider.of<LanguageProvider>(context);

        if (postSnapshot.hasError) return Center(child: Text(lang.get('loading_posts_error') + postSnapshot.error.toString()));
        if (postSnapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
        if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
          return Center(child: Text(lang.get('no_posts_available')));
        }

        final postDocs = postSnapshot.data!.docs;

                
        // Mọi thứ OK, build CustomScrollView
        return CustomScrollView(
          slivers: [
            // Sliver 1: Thanh Story (được truyền từ HomeScreen)
            SliverToBoxAdapter(
              child: storyBar, 
            ),
            
            // (Đã xóa Divider)
            
            // Sliver 3: Post List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final doc = postDocs[index]; 
                  final post = Post.fromFirestore(doc); 

                  // Dùng các hàm callback được truyền vào
                  return PostCard(
                    post: post, 
                    onLikeToggle: () => onLikeToggle(post.id, post.isLiked), 
                    onBookmarkToggle: () => onBookmarkToggle(post.id, post.isBookmarked),
                    onCommentPressed: () => onCommentPressed(post.id),
                    onSendPressed: () => onSendPressed(post.id),
                  );
                },
                childCount: postDocs.length,
              ),
            ),
          ],
        );
      },
    );
  }
}