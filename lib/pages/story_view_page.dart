// lib/pages/story_view_page.dart
// BẢN CẬP NHẬT (ICON MÁY BAY NGHIÊNG)

import 'package:flutter/material.dart';

class StoryViewPage extends StatefulWidget {
  final String username;
  final String imageUrl;

  const StoryViewPage({
    super.key,
    required this.username,
    required this.imageUrl,
  });

  @override
  State<StoryViewPage> createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _progressController.addListener(() {
      setState(() {});
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
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
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                  child: Icon(Icons.error, color: Colors.red, size: 50));
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.6)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            widget.username,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
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
            icon: const Icon(Icons.favorite_border, color: Colors.white, size: 30),
            onPressed: () {},
          ),
          // THAY ĐỔI: Xoay icon Gửi bằng Transform.rotate
          IconButton(
            icon: Transform.rotate(
              angle: -0.7, // Góc xoay theo radian (khoảng -40 độ)
              child: const Icon(Icons.send, color: Colors.white, size: 30),
            ),
            onPressed: () {
              // Xử lý logic gửi tin nhắn ở đây
            },
          ),
        ],
      ),
    );
  }
}