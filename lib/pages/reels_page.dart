// lib/pages/reels_page.dart
// BẢN SỬA LỖI: THÊM KEY ĐỂ NGĂN TÁI SỬ DỤNG STATE

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:btl/models/reel_model.dart'; // (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/widgets/reel_player.dart';

class ReelsPage extends StatefulWidget {
  final bool isTabActive;
  const ReelsPage({super.key, required this.isTabActive});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  int _activeIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTabActive) {
      return Container(color: Colors.black);
    }
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reels')
          .snapshots(),
          
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải Reels: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Không có Reels nào.'));
        }

        final reelDocs = snapshot.data!.docs;

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: reelDocs.length, 
          
          onPageChanged: (index) {
            setState(() {
              _activeIndex = index;
            });
          },
          
          itemBuilder: (context, index) {
            final doc = reelDocs[index];
            final reel = Reel.fromFirestore(doc);
            
            return ReelPlayer(
              // <<< SỬA LỖI 3: THÊM KEY DUY NHẤT (SỬA LỖI KHÔNG LƯỚT LÊN ĐƯỢC)
              // Báo cho Flutter biết đây là widget MỚI, cấm dùng lại State cũ.
              key: ValueKey(reel.id), 
              
              reel: reel, 
              isActive: (index == _activeIndex), 
            );
          },
        );
      },
    );
  }
}