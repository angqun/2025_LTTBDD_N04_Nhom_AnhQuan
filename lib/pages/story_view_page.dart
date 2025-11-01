// lib/pages/story_view_page.dart
// BẢN CẬP NHẬT: DÙNG CHỮ ĐẦY ĐỦ (ngày, giờ, hour, day)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'package:provider/provider.dart'; 

// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/providers/language_provider.dart'; 

class StoryViewPage extends StatefulWidget {
  final String username;
  final String imageUrl;
  final String storyId; 
  final bool initialIsLiked;
  final String? musicUrl; 
  final Timestamp? timestamp; 

  const StoryViewPage({
    super.key,
    required this.username,
    required this.imageUrl,
    required this.storyId, 
    required this.initialIsLiked,
    this.musicUrl,
    this.timestamp, 
  });

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late bool _isLiked;
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
    
    _playMusic();
    _progressController.forward();
  }

  void _playMusic() {
    if (widget.musicUrl != null && widget.musicUrl!.isNotEmpty) {
      try {
        _audioPlayer.setReleaseMode(ReleaseMode.stop);
        _audioPlayer.play(UrlSource(widget.musicUrl!));
      } catch (e) {
        print('Lỗi phát nhạc: $e');
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  void _onLikePressed() {
    setState(() { _isLiked = !_isLiked; });
    
    FirebaseFirestore.instance
      .collection('storys') // (Dùng tên collection 'storys' của bạn)
      .doc(widget.storyId) 
      .update({'isLiked': _isLiked})
      .catchError((e) {
        print('Lỗi cập nhật tim story: $e');
        if (mounted) {
          setState(() {
            _isLiked = !_isLiked;
          });
        }
      });
  }

  // <<< ĐÂY LÀ HÀM ĐÚNG (DÙNG CHỮ ĐẦY ĐỦ)
  String _formatTimestamp(BuildContext context, Timestamp? timestamp) {
    if (timestamp == null) return ''; 

    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final diff = DateTime.now().difference(timestamp.toDate());

    if (diff.inDays > 0) {
      return '${diff.inDays} ${lang.get('days_ago')}'; // "2 day" hoặc "2 ngày"
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ${lang.get('hours_ago')}'; // "2 hour" hoặc "2 giờ"
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${lang.get('minutes_ago')}'; // "2 minute" hoặc "2 phút"
    } else {
      return lang.get('just_now'); // 'Vừa xong'
    }
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

  // --- CÁC HÀM BUILD UI CON (ĐẦY ĐỦ) ---

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
          
          // Dùng hàm _formatTimestamp
          Text(
            _formatTimestamp(context, widget.timestamp), 
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 15)
          ),

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
            onPressed: _onLikePressed,
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