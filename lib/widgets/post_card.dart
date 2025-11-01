// lib/widgets/post_card.dart
// BẢN NÂNG CẤP: ẢNH DÙNG ASPECTRATIO (RESPONSIVE)

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/pages/post_model.dart'; 
import 'package:btl/providers/language_provider.dart'; 

class PostCard extends StatelessWidget {
  final Post post;
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

  // (Hàm _formatTimestamp giữ nguyên)
  String _formatTimestamp(BuildContext context, Timestamp? timestamp) {
    if (timestamp == null) return ''; 
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inDays > 0) return '${diff.inDays} ${lang.get('days_ago')}';
    if (diff.inHours > 0) return '${diff.inHours} ${lang.get('hours_ago')}';
    if (diff.inMinutes > 0) return '${diff.inMinutes} ${lang.get('minutes_ago')}';
    return lang.get('just_now');
  }

  // (Hàm _buildIconWithCount giữ nguyên)
  Widget _buildIconWithCount(
    IconData icon, 
    String count, 
    VoidCallback onPressed, 
    Color iconColor,
    {double iconSize = 24}
  ) {
    return Row(
      children: [
        IconButton(
          icon: FaIcon(icon, color: iconColor, size: iconSize),
          onPressed: onPressed,
        ),
        if (count != '0' && count.isNotEmpty)
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        SizedBox(width: 8), 
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final Color iconColor = Theme.of(context).iconTheme.color ?? Colors.black;
    final lang = Provider.of<LanguageProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      // <<< THAY ĐỔI: Giới hạn chiều rộng của Card
      // (Nó sẽ tự động khớp với 600px của cha)
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER (Giữ nguyên)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(post.avatarUrl),
                ),
                SizedBox(width: 10),
                Text(post.username, style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(icon: Icon(Icons.more_horiz), onPressed: () {}),
              ],
            ),
          ),

          // <<< THAY ĐỔI 2: XÓA 'height: 400' VÀ DÙNG 'ASPECTRATIO'
          // Ảnh bài đăng sẽ luôn là hình vuông (1:1)
          AspectRatio(
            aspectRatio: 1.0, // Tỷ lệ 1:1 (Vuông)
            child: Image.network(
              post.imageUrl, 
              fit: BoxFit.cover, // Luôn lấp đầy khung hình vuông
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator(strokeWidth: 2));
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Center(child: Icon(Icons.error_outline, color: Colors.grey[400]))
                );
              },
            ),
          ),

          // 3. HÀNG NÚT BẤM (Giữ nguyên)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
            child: Row(
              children: [
                _buildIconWithCount(
                  post.isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  post.likeCount,
                  onLikeToggle,
                  post.isLiked ? Colors.red : iconColor,
                ),
                _buildIconWithCount(
                  FontAwesomeIcons.comment,
                  post.commentCount,
                  onCommentPressed,
                  iconColor,
                ),
                _buildIconWithCount(
                  FontAwesomeIcons.retweet, 
                  post.repostCount, 
                  () { print('Nút Repost được nhấn!'); }, 
                  iconColor,
                ),
                _buildIconWithCount(
                  FontAwesomeIcons.paperPlane,
                  post.sendCount,
                  onSendPressed,
                  iconColor,
                  iconSize: 22,
                ),
                Spacer(),
                IconButton(
                  icon: FaIcon(
                    post.isBookmarked
                        ? FontAwesomeIcons.solidBookmark
                        : FontAwesomeIcons.bookmark,
                    size: 24,
                    color: iconColor,
                  ),
                  onPressed: onBookmarkToggle,
                ),
              ],
            ),
          ),

          // 4. CAPTION VÀ METADATA (Giữ nguyên)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, 
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${post.username} ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: (lang.locale.languageCode == 'vi')
                            ? post.caption_vi
                            : post.caption_en,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  _formatTimestamp(context, post.timestamp), 
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}