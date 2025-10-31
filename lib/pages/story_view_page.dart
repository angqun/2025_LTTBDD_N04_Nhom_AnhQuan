// lib/pages/story_view_page.dart
// BẢN NÂNG CẤP: PHÁT NHẠC

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:audioplayers/audioplayers.dart'; // <<< THÊM IMPORT AUDIOPLAYERS

class StoryViewPage extends StatefulWidget {
  final String username;
  final String imageUrl;
  final String storyId; 
  final bool initialIsLiked;
  final String? musicUrl; // <<< THÊM 1: Nhận musicUrl

  const StoryViewPage({
    super.key,
    required this.username,
    required this.imageUrl,
    required this.storyId, 
    required this.initialIsLiked,
    this.musicUrl, // <<< THÊM 2: Thêm vào constructor
  });

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late bool _isLiked;
  
  // <<< THÊM 3: Tạo một trình phát âm thanh
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialIsLiked; 

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    _progressController.addListener(() { setState(() {}); });
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) Navigator.pop(context);
      }
    });
    
    // <<< THÊM 4: Bật nhạc khi story bắt đầu
    _playMusic();
    
    _progressController.forward();
  }

  // <<< THÊM 5: Hàm bật nhạc
  void _playMusic() {
    // Chỉ bật nếu link nhạc tồn tại
    if (widget.musicUrl != null && widget.musicUrl!.isNotEmpty) {
      try {
        _audioPlayer.setReleaseMode(ReleaseMode.stop); // Dừng hẳn khi stop
        _audioPlayer.play(UrlSource(widget.musicUrl!));
      } catch (e) {
        print('Lỗi phát nhạc: $e');
      }
    }
  }


  @override
  void dispose() {
    _progressController.dispose();
    
    // <<< THÊM 6: Tắt nhạc và giải phóng tài nguyên khi đóng story
    _audioPlayer.stop();
    _audioPlayer.dispose();
    
    super.dispose();
  }
  
  // Hàm xử lý tim (cập nhật lên Firebase)
  void _onLikePressed() {
    // 1. Cập nhật UI ngay lập tức
    setState(() {
      _isLiked = !_isLiked;
    });
    
    // 2. Cập nhật lên Firebase
    // (Dùng tên collection 'storys' của bạn)
    FirebaseFirestore.instance
      .collection('storys') 
      .doc(widget.storyId) // Dùng ID của story
      .update({
        'isLiked': _isLiked // Gửi trạng thái mới lên
      }).catchError((e) {
        print('Lỗi cập nhật tim story: $e');
        // Nếu lỗi, đảo ngược lại trạng thái
        if (mounted) {
          setState(() {
            _isLiked = !_isLiked;
          });
        }
      });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.error, color: Colors.red, size: 50));
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6), Colors.transparent,
                  Colors.transparent, Colors.black.withOpacity(0.6)
                ],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  _buildProgressBar(),
                  _buildHeader(context),
                  const Spacer(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // (Các hàm build UI con)
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2.0),
        child: LinearProgressIndicator(
          value: _progressController.value,
          backgroundColor: Colors.white.withOpacity(0.4),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 3.0,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const CircleAvatar(radius: 16, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 20, color: Colors.white)),
          const SizedBox(width: 10),
          Text(widget.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Text("1h", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15)),
          const Spacer(), 
          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.white), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () { Navigator.pop(context); },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
          .copyWith(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22.0),
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Gửi tin nhắn...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.white,
              size: 30,
            ),
            onPressed: _onLikePressed, // <<< Gọi hàm xử lý tim
          ),
          IconButton(
            icon: Transform.rotate(
              angle: -0.7, 
              child: const Icon(Icons.send, color: Colors.white, size: 30),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}