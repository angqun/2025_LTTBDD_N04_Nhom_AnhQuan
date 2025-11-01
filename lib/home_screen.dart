// lib/home_screen.dart
// BẢN HOÀN CHỈNH: ĐÃ SỬA LỖI ANR (TẢI NỀN)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:provider/provider.dart'; 

// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/providers/language_provider.dart'; 
import 'package:btl/pages/feed_page.dart';    
import 'package:btl/widgets/story_bar.dart'; 
import 'package:btl/pages/reels_page.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Các biến trạng thái và dịch vụ ("Bộ não") ---
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');
  final CollectionReference _storiesCollection =
      FirebaseFirestore.instance.collection('storys'); 

  int _selectedIndex = 0;
  
  late final Widget _storyBarWidget;

  
  @override
  void initState() {
    super.initState();
    _storyBarWidget = StoryBar(storiesCollection: _storiesCollection);
  }
  
  // --- CÁC HÀM XỬ LÝ SỰ KIỆN (LOGIC) ---
  
  void _onLikeToggle(String postId, bool currentIsLiked) {
    _postsCollection.doc(postId).update({
      'isLiked': !currentIsLiked,
    }).catchError((e) => print('Lỗi cập nhật like: $e'));
  }

  void _onBookmarkToggle(String postId, bool currentIsBookmarked) {
     _postsCollection.doc(postId).update({
      'isBookmarked': !currentIsBookmarked,
    }).catchError((e) => print('Lỗi cập nhật bookmark: $e'));
  }

  void _onCommentPressed(String postId) { 
    print('Nhấn comment ở bài $postId'); 
  }

  void _onSendPressed(String postId) { 
    print('Nhấn gửi bài $postId'); 
  }
  
  void _onItemTapped(int index) {
    setState(() { 
      _selectedIndex = index; 
    });
  }

  Future<void> _logOut(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _auth.signOut();
      print('Đăng xuất thành công.');
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Lỗi đăng xuất: $e')),
        );
      }
    }
  }

  
  // --- CÁC WIDGET CHO TỪNG TRANG CON ---
  
  // Page 0: Trang Feed
  Widget _buildFeedPage() {
    return FeedPage(
      storyBar: _storyBarWidget,
      postsCollection: _postsCollection,
      onLikeToggle: _onLikeToggle,
      onBookmarkToggle: _onBookmarkToggle,
      onCommentPressed: _onCommentPressed,
      onSendPressed: _onSendPressed,
    );
  }

  // <<< SỬA LỖI ANR Ở ĐÂY
  // Page 1: Reels
  Widget _buildReelsPage() {
    // Truyền 'isTabActive' xuống cho con
    // Nó chỉ 'true' KHI _selectedIndex == 1
    return ReelsPage(
      isTabActive: (_selectedIndex == 1),
    );
  }
  
  // Page 2: Messages
  Widget _buildMessagesPage() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return Center(child: Text(lang.get('messages_page_title')));
  }
  
  // Page 3: Search
  Widget _buildSearchPage() {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    return Center(child: Text(lang.get('search_page_title')));
  }
  
  // Page 4: Profile
  Widget _buildProfilePage() {
    final lang = Provider.of<LanguageProvider>(context);
    final user = _auth.currentUser;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                NetworkImage('https://picsum.photos/id/1005/100/100'),
          ),
          SizedBox(height: 20),
          Text(
            lang.get('logged_in_as'), 
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 8),
          Text(
            user?.email ?? lang.get('email_not_found'), 
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
            child: Text(lang.get('log_out'), style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // --- HÀM BUILD CHÍNH ---
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    // Khởi tạo 'pages' ở đây
    final List<Widget> pages = [
      _buildFeedPage(),    
      _buildReelsPage(),   
      _buildMessagesPage(),
      _buildSearchPage(),  
      _buildProfilePage(), 
    ];

    return Scaffold(
      // 1. APPBAR
      appBar: _selectedIndex == 1 
          ? null 
          : AppBar(
              leading: IconButton(
                icon: Icon(Icons.add, size: 28, color: Colors.black),
                onPressed: () {}, // Vô hiệu hóa
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
        children: pages,
      ),
      
      // 3. BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false, 
        showUnselectedLabels: false, 
        iconSize: 28,
        
        backgroundColor: _selectedIndex == 1 ? Colors.black : Colors.white,
        selectedItemColor: _selectedIndex == 1 ? Colors.white : Colors.black,
        unselectedItemColor: _selectedIndex == 1 ? Colors.white : Colors.black,

        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: lang.get('nav_home'), 
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.circlePlay, size: 24),
            activeIcon: FaIcon(FontAwesomeIcons.solidCirclePlay, size: 24),
            label: lang.get('nav_reels'), 
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.paperPlane, size: 24),
            label: lang.get('nav_messages'), 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: lang.get('nav_search'), 
          ),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage:
                  NetworkImage('https://picsum.photos/id/1005/100/100'),
            ),
            label: lang.get('nav_profile'), 
          ),
        ],
      ),
    );
  }
}