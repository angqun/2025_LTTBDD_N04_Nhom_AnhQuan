// lib/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Cần cho hàm _logOut

// (Đã xóa 'dart:ui' hoàn toàn)

// <<< MỚI: Import 3 file đã tách
import 'widgets/post_card.dart'; 
import 'widgets/story_bubble.dart'; 
import 'pages/story_view_page.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  int _selectedIndex = 0; 
  late final List<Widget> _pages;

  // (Đã xóa ScrollController)

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildFeedPage(),       // Index 0: Trang Feed
      _buildReelsPage(),      // Index 1: Trang Video/Reels
      _buildMessagesPage(),   // Index 2: Trang Tin nhắn
      _buildSearchPage(),     // Index 3: Trang Tìm kiếm
      _buildProfilePage(),    // Index 4: Trang Profile (chứa nút Logout)
    ];
  }

  // (Đã xóa dispose() vì không còn controller)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // HÀM ĐĂNG XUẤT
  Future<void> _logOut(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _auth.signOut();
      print('Đăng xuất thành công, AuthWrapper sẽ tự động chuyển trang.');
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Lỗi đăng xuất: $e')),
        );
      }
    }
  }

  // --- CÁC TRANG CON CHO TỪNG TAB ---

  // Page 0: Trang Feed (Fix lỗi ANR bằng CustomScrollView)
  Widget _buildFeedPage() {
    return CustomScrollView(
      slivers: [
        // Sliver 1: Thanh Story
        SliverToBoxAdapter(
          child: Container(
            height: 110, 
            // (Đã xóa Listener)
            child: ListView.builder(
              // (Đã xóa controller)
              scrollDirection: Axis.horizontal, 
              itemCount: 10, // 10 STORY
              itemBuilder: (context, index) {
                
                if (index == 0) {
                  // Story của bạn
                  return GestureDetector(
                    onTap: () {
                      print('Bấm vào story của bạn');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoryViewPage(
                            username: 'Tin của bạn',
                            imageUrl: 'https://picsum.photos/id/1005/1080/1920', 
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CircleAvatar(
                                radius: 33,
                                backgroundImage: NetworkImage('https://picsum.photos/id/1005/100/100'),
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.add_circle, color: Colors.blue, size: 24),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 5),
                          Text('Tin của bạn', style: TextStyle(fontSize: 12))
                        ],
                      ),
                    ),
                  );
                }
                
                // Các story khác
                final storyUsername = 'user_${index}';
                final storyImageUrl = 'https://picsum.photos/id/101${index}/1080/1920'; 

                return GestureDetector(
                  onTap: () {
                    print('Bấm vào story của $storyUsername');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoryViewPage( // <<< Đã sửa lại
                          username: storyUsername,
                          imageUrl: storyImageUrl,
                        ),
                      ),
                    );
                  },
                  child: StoryBubble(username: storyUsername), // <<< Gọi file widget con
                );
              },
            ),
          ),
        ),

        // Sliver 2: Cái đường kẻ
        SliverToBoxAdapter(
          child: Divider(height: 1),
        ),

        // Sliver 3: Danh sách bài đăng
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return PostCard(); // <<< Gọi file widget con
            },
            childCount: 10, // 10 BÀI VIẾT
          ),
        ),
      ],
    );
  }

  // Page 1: Trang Video/Reels (Placeholder)
  Widget _buildReelsPage() {
    return Center(child: Text('Trang Video/Reels (sẽ làm sau)'));
  }

  // Page 2: Trang Tin nhắn (Placeholder)
  Widget _buildMessagesPage() {
    return Center(child: Text('Trang Tin nhắn (sẽ làm sau)'));
  }

  // Page 3: Trang Tìm kiếm (Placeholder)
  Widget _buildSearchPage() {
    return Center(child: Text('Trang Tìm kiếm (sẽ làm sau)'));
  }

  // Page 4: Trang Profile (chứa nút Logout)
  Widget _buildProfilePage() {
    final user = _auth.currentUser;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://picsum.photos/id/1005/100/100'), 
          ),
          SizedBox(height: 20),
          Text(
            'Đã đăng nhập với email:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          Text(
            user?.email ?? 'Không tìm thấy email',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => _logOut(context), 
            child: Text('Đăng xuất', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. APPBAR
      appBar: AppBar(
        leading: IconButton( 
          icon: Icon(Icons.add, size: 28, color: Colors.black),
          onPressed: () {},
        ),
        title: Text( 
          'AnhQuan',
          style: GoogleFonts.satisfy(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black, 
          ),
        ),
        centerTitle: true, 
        actions: [
          IconButton( 
            icon: FaIcon(FontAwesomeIcons.heart, size: 24, color: Colors.black),
            onPressed: () {},
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black), 
      ),

      // 2. BODY
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      // 3. BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, 
        showSelectedLabels: false, 
        showUnselectedLabels: false, 
        iconSize: 28,
        selectedItemColor: Colors.black, 
        unselectedItemColor: Colors.black, 
        currentIndex: _selectedIndex, 
        onTap: _onItemTapped, 
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled), 
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.circlePlay, size: 24), 
            label: 'Video',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.paperPlane, size: 24), 
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage('https://picsum.photos/id/1005/100/100'),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}