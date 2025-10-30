// lib/widgets/post_card.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Đây là widget cho MỘT bài đăng
    return Container(
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. PHẦN HEADER CỦA BÀI ĐĂNG
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage('https://picsum.photos/id/1011/100/100'),
                ),
                SizedBox(width: 10),
                Text(
                  'cristiano',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Icon(Icons.more_horiz),
              ],
            ),
          ),

          // 2. HÌNH ẢNH CHÍNH CỦA BÀI ĐĂNG (Ảnh Ronaldo)
          Image.network(
            'https://i.imgur.com/Q3GkE3G.jpeg', 
            width: double.infinity,
            height: 400,
            fit: BoxFit.cover,
          ),

          // 3. CÁC NÚT TƯƠNG TÁC
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.heart, size: 24),
                SizedBox(width: 15),
                FaIcon(FontAwesomeIcons.comment, size: 24),
                SizedBox(width: 15),
                FaIcon(FontAwesomeIcons.paperPlane, size: 24),
                Spacer(),
                FaIcon(FontAwesomeIcons.bookmark, size: 24),
              ],
            ),
          ),

          // 4. LƯỢT THÍCH VÀ BÌNH LUẬN
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1,234,567 lượt thích',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: 'cristiano ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'This is an amazing day!',
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