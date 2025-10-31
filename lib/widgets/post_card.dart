// lib/widgets/post_card.dart
// BẢN SỬA LỖI: Chuyển lại thành STATELESS và nhận dữ liệu từ cha

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:btl/pages/post_model.dart'; // <-- Import model của bạn

class PostCard extends StatelessWidget {
  // THAY ĐỔI 1: Nhận dữ liệu từ cha
  final Post post;
  // THAY ĐỔI 2: Nhận một hàm callback (hàm gọi ngược) từ cha
  final VoidCallback onLikeToggle;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onCommentPressed;
  final VoidCallback onSendPressed;

  const PostCard({
    super.key,
    required this.post,
    required this.onLikeToggle,
    required this.onBookmarkToggle,
    required this.onCommentPressed,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).iconTheme.color ?? Colors.black;

    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(post.avatarUrl), // <-- Dùng data
                ),
                SizedBox(width: 10),
                Text(
                  post.username, // <-- Dùng data
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // 2. IMAGE
          Image.network(
            post.imageUrl, // <-- Dùng data
            width: double.infinity,
            height: 400,
            fit: BoxFit.cover,
          ),

          // 3. CÁC NÚT TƯƠNG TÁC
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
            child: Row(
              children: [
                // THAY ĐỔI 3: Dùng trạng thái và hàm từ cha
                IconButton(
                  icon: FaIcon(
                    post.isLiked // <-- Dùng data
                        ? FontAwesomeIcons.solidHeart
                        : FontAwesomeIcons.heart,
                    color: post.isLiked ? Colors.red : iconColor, // <-- Dùng data
                    size: 24,
                  ),
                  onPressed: onLikeToggle, // <-- Gọi hàm của cha
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.comment, size: 24),
                  onPressed: onCommentPressed, // <-- Gọi hàm của cha
                ),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.paperPlane, size: 24),
                  onPressed: onSendPressed, // <-- Gọi hàm của cha
                ),
                Spacer(),
                IconButton(
                  icon: FaIcon(
                    post.isBookmarked // <-- Dùng data
                        ? FontAwesomeIcons.solidBookmark
                        : FontAwesomeIcons.bookmark,
                    size: 24,
                  ),
                  onPressed: onBookmarkToggle, // <-- Gọi hàm của cha
                ),
              ],
            ),
          ),

          // 4. LƯỢT THÍCH VÀ BÌNH LUẬN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.likeCount, // <-- Dùng data
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${post.username} ', // <-- Dùng data
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: post.caption, // <-- Dùng data
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}