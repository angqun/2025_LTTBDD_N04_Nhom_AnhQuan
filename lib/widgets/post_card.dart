// lib/widgets/post_card.dart
// BẢN HOÀN CHỈNH: TỰ ĐỘNG DỊCH CAPTION VÀ HIỂN THỊ SỐ LIỆU

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Cần cho Timestamp

// (Sửa 'btl' nếu tên dự án của bạn khác)
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

  // --- HÀM HỖ TRỢ ---

  // Hàm đổi Timestamp thành "1 ngày trước", "2 giờ trước"...
  String _formatTimestamp(BuildContext context, Timestamp? timestamp) {
    if (timestamp == null) return ''; // Trả về rỗng nếu không có data

    // Lấy provider ngôn ngữ (không cần 'listen')
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final diff = DateTime.now().difference(timestamp.toDate());

    if (diff.inDays > 0) {
      return '${diff.inDays} ${lang.get('days_ago')}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ${lang.get('hours_ago')}';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${lang.get('minutes_ago')}';
    } else {
      return lang.get('just_now');
    }
  }

  // Hàm tái sử dụng để vẽ "Icon + Số đếm"
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
        // Chỉ hiển thị số nếu nó khác '0'
        if (count != '0' && count.isNotEmpty)
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        SizedBox(width: 8), // Khoảng cách giữa các cụm
      ],
    );
  }


  // --- HÀM BUILD CHÍNH ---
  @override
  Widget build(BuildContext context) {
    // Lấy màu icon mặc định (tự động đổi Sáng/Tối)
    final Color iconColor = Theme.of(context).iconTheme.color ?? Colors.black;
    // Lấy provider ngôn ngữ (để 'listen' và tự động đổi caption)
    final lang = Provider.of<LanguageProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER (Avatar, Tên, Nút ...)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(post.avatarUrl),
                ),
                SizedBox(width: 10),
                Text(
                  post.username,
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

          // 2. IMAGE (Ảnh bài đăng)
          Image.network(
            post.imageUrl, 
            width: double.infinity,
            height: 400,
            fit: BoxFit.cover,
            // (Thêm loading/error builder nếu muốn)
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 400,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2))
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 400,
                color: Colors.grey[200],
                child: Center(child: Icon(Icons.error_outline, color: Colors.grey[400]))
              );
            },
          ),

          // 3. HÀNG NÚT BẤM (ĐÃ CẬP NHẬT)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
            child: Row(
              children: [
                // Tim + Lượt thích
                _buildIconWithCount(
                  post.isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                  post.likeCount,
                  onLikeToggle,
                  post.isLiked ? Colors.red : iconColor,
                ),
                
                // Comment + Số comment
                _buildIconWithCount(
                  FontAwesomeIcons.comment,
                  post.commentCount,
                  onCommentPressed,
                  iconColor,
                ),
                
                // Repost + Số repost
                _buildIconWithCount(
                  FontAwesomeIcons.retweet, // Icon đăng lại
                  post.repostCount, // Lấy từ data
                  () { print('Nút Repost được nhấn!'); }, // (Hàm xử lý)
                  iconColor,
                ),
                
                // Send + Số send
                _buildIconWithCount(
                  FontAwesomeIcons.paperPlane,
                  post.sendCount,
                  onSendPressed,
                  iconColor,
                  iconSize: 22,
                ),
                
                Spacer(),
                
                // Nút Bookmark
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

          // 4. CAPTION VÀ METADATA (ĐÃ CẬP NHẬT)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CAPTION TỰ ĐỘNG DỊCH
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
                        // Lô-gic: Nếu ngôn ngữ là 'vi', dùng caption_vi
                        // ngược lại, dùng caption_en
                        text: (lang.locale.languageCode == 'vi')
                            ? post.caption_vi
                            : post.caption_en,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),

                // METADATA (ĐÃ XÓA NÚT "XEM BẢN DỊCH")
                Text(
                  _formatTimestamp(context, post.timestamp), // "1 ngày trước"
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