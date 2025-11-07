// lib/pages/reels_page.dart
// BẢN SỬA LỖI CUỐI CÙNG: BỎ STREAMBUILDER, TẢI 1 LẦN (LOAD ONCE)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:btl/models/reel_model.dart'; 
import 'package:btl/widgets/reel_player.dart';

class ReelsPage extends StatefulWidget {
  final bool isTabActive; 
  const ReelsPage({super.key, required this.isTabActive});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

// VẪN GIỮ 'AutomaticKeepAliveClientMixin' để giữ sống KHI CHUYỂN TAB
class _ReelsPageState extends State<ReelsPage> with AutomaticKeepAliveClientMixin {
  int _activeIndex = 0;
  late PageController _pageController;

  // <<< SỬA LỖI 1: Bỏ StreamBuilder, dùng State
  List<Reel> _reels = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true; // Giữ sống khi chuyển tab

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeIndex);
    
    // <<< SỬA LỖI 2: Gọi hàm tải video 1 LẦN
    _loadReels();
  }

  // <<< SỬA LỖI 3: Hàm tải video 1 lần duy nhất
  Future<void> _loadReels() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reels')
          .orderBy('timestamp', descending: true)
          .get(); // Dùng .get() (tải 1 lần) thay vì .snapshots() (lắng nghe)
      
      final reels = snapshot.docs.map((doc) => Reel.fromFirestore(doc)).toList();
      
      if (mounted) {
        setState(() {
          _reels = reels;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi tải Reels: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Bắt buộc cho KeepAlive

    // <<< SỬA LỖI 4: Bỏ StreamBuilder, dùng State để build
    
    if (_isLoading) {
      return Container(color: Colors.black, child: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    if (_hasError) {
      return Container(color: Colors.black, child: Center(child: Text('Lỗi tải Reels.', style: TextStyle(color: Colors.red))));
    }

    if (_reels.isEmpty) {
      return Container(color: Colors.black, child: Center(child: Text('Không có Reels nào.', style: TextStyle(color: Colors.white))));
    }

    // Trả về PageView ổn định (sẽ không bao giờ bị build lại)
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: _reels.length, // Dùng list state
      
      onPageChanged: (index) {
        setState(() {
          _activeIndex = index;
        });
      },
      
      itemBuilder: (context, index) {
        final reel = _reels[index]; // Dùng list state
        
        return ReelPlayer(
          key: ValueKey(reel.id), 
          reel: reel, 
          isActive: (index == _activeIndex), 
          isTabActive: widget.isTabActive,
        );
      },
    );
  }
}