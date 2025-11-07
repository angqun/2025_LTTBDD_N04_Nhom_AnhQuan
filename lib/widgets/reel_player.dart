// lib/widgets/reel_player.dart
// BẢN NÀY ĐÃ CHUẨN - KHÔNG CẦN SỬA GÌ THÊM
// (DÙNG KÈM VỚI BẢN 'REEL_PAGE TẢI 1 LẦN')

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:btl/models/reel_model.dart'; 
import 'package:btl/providers/language_provider.dart';

class ReelPlayer extends StatefulWidget {
  final Reel reel;
  final bool isActive;      
  final bool isTabActive; 

  const ReelPlayer({
    super.key,
    required this.reel,
    required this.isActive,
    required this.isTabActive, 
  });

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

// Thêm 'with AutomaticKeepAliveClientMixin' VÀO ĐÂY
class _ReelPlayerState extends State<ReelPlayer> with AutomaticKeepAliveClientMixin {
      
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isInitializing = false; 
  bool _hasError = false; 
  late bool _isLiked;

  // Báo cho PageView.builder biết "CẤM HỦY TÔI KHI LƯỚT QUA"
  @override
  bool get wantKeepAlive => true; // <<< CỰC KỲ QUAN TRỌNG

  bool get _isTrulyActive => widget.isActive && widget.isTabActive;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.reel.isLiked;
    if (_isTrulyActive) {
      _initializeAndPlay();
    }
  }

  void _initializeAndPlay() async {
    if (_isInitializing || _isInitialized) return; 
    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      final newController = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl));
      
      newController.addListener(() {
        if (newController.value.hasError) {
          if (mounted) {
            setState(() { _hasError = true; _isInitializing = false; });
          }
        }
      });

      await newController.initialize(); 

      if (!mounted) {
        await newController.dispose();
        return;
      }

      _controller = newController;
      _isInitialized = true;
      _isInitializing = false;
      
      _controller!.setLooping(true); 
      _controller!.setVolume(1.0);
      
      if (_isTrulyActive) {
         _controller!.play();
      }
     
      setState(() {}); 
    } catch (e) {
      print('--- CRASH KHI KHỞI TẠO VIDEO: $e ---');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true; 
        });
      }
    }
  }

  @override
  void dispose() {
    if (_isInitialized && _controller != null) {
      _controller!.pause();
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(ReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool wasTrulyActive = oldWidget.isActive && oldWidget.isTabActive;
    final bool isTrulyActive = widget.isActive && widget.isTabActive;

    if (isTrulyActive != wasTrulyActive) {
      if (isTrulyActive) {
        if (!_isInitialized) {
          _initializeAndPlay();
        } else {
          _controller?.setVolume(1.0);
          _controller?.play(); 
        }
      } else {
        if (_isInitialized && _controller != null) {
          _controller!.pause(); 
        }
      }
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized || _controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.setVolume(1.0);
        _controller!.play();
      }
    });
  }
  
  void _onLikeToggle() {
    // Hàm này VẪN HOẠT ĐỘNG
    // Nó sẽ update Firebase, nhưng sẽ KHÔNG LÀM CRASH app nữa
    setState(() { _isLiked = !_isLiked; });
    FirebaseFirestore.instance
      .collection('reels') 
      .doc(widget.reel.id) 
      .update({'isLiked': _isLiked})
      .catchError((e) {
        if (mounted) {
          setState(() { _isLiked = !_isLiked; });
        }
      });
  }


  @override
  Widget build(BuildContext context) {
    super.build(context); // Bắt buộc cho KeepAlive

    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Icon(Icons.error_outline, color: Colors.red[400], size: 50),
        ),
      );
    }
    
    if (!_isInitialized) {
      if (_isInitializing) {
        return Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }
      return Container(color: Colors.black);
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _togglePlayPause,
            child: Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
          ),
          GestureDetector(
            onTap: _togglePlayPause,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: !_controller!.value.isPlaying
                  ? Center( 
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white.withOpacity(0.7),
                        size: 80.0,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          _buildUiOverlay(context),
        ],
      ),
    );
  }
  
  // (Các hàm _buildUiOverlay, _buildRightPane, _buildLikeButton, 
  // _buildIconButton, _buildStaticAlbumArt, _buildLeftPane giữ nguyên)
  // ... (Copy và dán toàn bộ các hàm build UI của bạn vào đây) ...

  Widget _buildUiOverlay(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(12.0).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 12.0,
        top: MediaQuery.of(context).padding.top + 12.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lang.get('reels_tab_reels'), 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Text(
                lang.get('reels_tab_friends'),
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 4,
                child: _buildLeftPane(lang), 
              ),
              Expanded(
                flex: 1,
                child: _buildRightPane(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildRightPane() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildLikeButton(), 
        _buildIconButton(FontAwesomeIcons.solidCommentDots, widget.reel.commentCount, () {}),
        _buildIconButton(FontAwesomeIcons.retweet, widget.reel.repostCount, () {}), 
        _buildIconButton(FontAwesomeIcons.paperPlane, widget.reel.sendCount, () {}),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 10), 
        _buildStaticAlbumArt(), 
      ],
    );
  }
  Widget _buildLikeButton() {
    return Column(
      children: [
        IconButton(
          onPressed: _onLikeToggle, 
          icon: Icon(
            _isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart, 
            color: _isLiked ? Colors.red : Colors.white, 
            size: 30,
          ),
        ),
        Text(
          widget.reel.likeCount, 
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
  Widget _buildIconButton(IconData icon, String count, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed, 
          icon: Icon(icon, color: Colors.white, size: 30),
        ),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
  Widget _buildStaticAlbumArt() {
    return Container(
      width: 45,
      height: 45,
      padding: const EdgeInsets.all(10), 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10), 
        image: const DecorationImage(
          image: NetworkImage('https://static.thenounproject.com/png/9496-200.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.network(
          widget.reel.albumArtUrl, 
          fit: BoxFit.cover,
        ), 
      ),
    );
  }
  Widget _buildLeftPane(LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.reel.avatarUrl),
            ),
            const SizedBox(width: 8),
            Text(
              widget.reel.username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: Size.zero,
                side: const BorderSide(color: Colors.white, width: 1),
              ),
              child: Text(
                lang.get('follow'),
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          widget.reel.caption,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(FontAwesomeIcons.music, color: Colors.white, size: 12),
            const SizedBox(width: 5),
            Text(
              widget.reel.musicName,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}