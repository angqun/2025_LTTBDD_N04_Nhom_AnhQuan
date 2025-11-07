// lib/home_screen.dart

// BẢN HOÀN CHỈNH: ĐÃ KẾT NỐI TAB PROFILE VÀ SỬA LỖI IMPORT/APPBAR

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

// ----- CÁC DÒNG IMPORT TƯƠNG ĐỐI (ĐẢM BẢO CÓ ĐỦ) -----

// (Lỗi gạch đỏ ở đây nếu có là lỗi "ma" của VS Code, hãy bỏ qua)

import 'package:btl/providers/language_provider.dart';

import 'package:btl/pages/feed_page.dart';

import 'package:btl/widgets/story_bar.dart';

import 'package:btl/pages/reels_page.dart';

import 'package:btl/pages/messages_page.dart';

import 'package:btl/pages/search_page.dart';

import 'package:btl/pages/profile_page.dart'; // <<< ĐÂY LÀ DÒNG IMPORT MỚI CHO TRANG CÁ NHÂN

// ---------------------------------------------------

class HomeScreen
    extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  // --- Các biến trạng thái và dịch vụ ("Bộ não") ---

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final CollectionReference
  _postsCollection = FirebaseFirestore
      .instance
      .collection('posts');

  // (Dùng đúng tên collection 'storys' của bạn)

  final CollectionReference
  _storiesCollection = FirebaseFirestore
      .instance
      .collection('storys');

  int _selectedIndex = 0;

  late final Widget _storyBarWidget;

  @override
  void initState() {
    super.initState();

    // Khởi tạo widget story 1 LẦN DUY NHẤT để tránh lỗi nháy (flickering)

    _storyBarWidget = StoryBar(
      storiesCollection:
          _storiesCollection,
    );
  }

  // --- CÁC HÀM XỬ LÝ SỰ KIỆN (LOGIC) ---

  void _onLikeToggle(
    String postId,
    bool currentIsLiked,
  ) {
    _postsCollection
        .doc(postId)
        .update({
          'isLiked': !currentIsLiked,
        })
        .catchError(
          (e) => print(
            'Lỗi cập nhật like: $e',
          ),
        );
  }

  void _onBookmarkToggle(
    String postId,
    bool currentIsBookmarked,
  ) {
    _postsCollection
        .doc(postId)
        .update({
          'isBookmarked':
              !currentIsBookmarked,
        })
        .catchError(
          (e) => print(
            'Lỗi cập nhật bookmark: $e',
          ),
        );
  }

  void _onCommentPressed(
    String postId,
  ) {
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

  Future<void> _logOut(
    BuildContext context,
  ) async {
    final scaffoldMessenger =
        ScaffoldMessenger.of(context);

    try {
      await _auth.signOut();

      print('Đăng xuất thành công.');
    } catch (e) {
      print('Lỗi đăng xuất: $e');

      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi đăng xuất: $e',
            ),
          ),
        );
      }
    }
  }

  // --- CÁC WIDGET CHO TỪNG TRANG CON ---

  // Page 0: Trang Feed (Bài đăng và Story của bạn bè)

  Widget _buildFeedPage() {
    return FeedPage(
      storyBar: _storyBarWidget,

      postsCollection: _postsCollection,

      onLikeToggle: _onLikeToggle,

      onBookmarkToggle:
          _onBookmarkToggle,

      onCommentPressed:
          _onCommentPressed,

      onSendPressed: _onSendPressed,
    );
  }

  // Page 1: Reels (Video ngắn)

  Widget _buildReelsPage() {
    return ReelsPage(
      isTabActive:
          (_selectedIndex ==
          1), // Truyền trạng thái để tối ưu hiệu suất
    );
  }

  // Page 2: Messages (Trò chuyện)

  Widget _buildMessagesPage() {
    return MessagesPage();
  }

  // Page 3: Search (Tìm kiếm và Khám phá)

  Widget _buildSearchPage() {
    return SearchPage();
  }

  // Page 4: Profile (Trang cá nhân của bạn)

  Widget _buildProfilePage() {
    return ProfilePage(); // TRẢ VỀ PROFILEPAGE MỚI TẠO
  }

  // --- HÀM BUILD CHÍNH ---

  @override
  Widget build(BuildContext context) {
    final lang =
        Provider.of<LanguageProvider>(
          context,
        );

    final User? currentUser = _auth
        .currentUser; // Lấy thông tin user hiện tại

    // Danh sách các trang (widgets) tương ứng với từng tab

    final List<Widget> pages = [
      _buildFeedPage(),

      _buildReelsPage(),

      _buildMessagesPage(),

      _buildSearchPage(),

      _buildProfilePage(), // <<< TRANG CÁ NHÂN Ở VỊ TRÍ INDEX 4
    ];

    return Scaffold(
      // 1. APPBAR

      // ẨN APPBAR KHI Ở TAB REELS (1), MESSAGES (2), SEARCH (3), PROFILE (4)
      appBar:
          _selectedIndex ==
              0 // CHỈ HIỂN THỊ APPBAR KHI Ở TAB HOME (0)
          ? AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 28,
                  color: Colors.black,
                ),

                onPressed:
                    () {}, // Vô hiệu hóa hoặc thêm chức năng
              ),

              title: Text(
                'AnhQuan', // Tên thương hiệu

                style:
                    GoogleFonts.satisfy(
                      fontSize: 32,

                      fontWeight:
                          FontWeight
                              .bold,

                      color:
                          Colors.black,
                    ),
              ),

              centerTitle: true,

              actions: [
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons
                        .heart,
                    size: 24,
                    color: Colors.black,
                  ),

                  onPressed: () {},
                ),
              ],

              elevation: 0,

              backgroundColor:
                  Colors.white,

              iconTheme: IconThemeData(
                color: Colors.black,
              ),
            )
          : null, // Ẩn AppBar cho các tab khác

      // 2. BODY: Hiển thị trang tương ứng với tab được chọn
      body: IndexedStack(
        index: _selectedIndex,

        children: pages,
      ),

      // 3. BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // Giữ các icon cố định

        showSelectedLabels:
            false, // Không hiển thị chữ cho icon được chọn

        showUnselectedLabels:
            false, // Không hiển thị chữ cho icon không được chọn

        iconSize: 28, // Kích thước icon

        // Thay đổi màu sắc của BottomNavigationBar khi ở tab Reels (index 1)
        backgroundColor:
            _selectedIndex == 1
            ? Colors.black
            : Colors.white,

        selectedItemColor:
            _selectedIndex == 1
            ? Colors.white
            : Colors.black,

        unselectedItemColor:
            _selectedIndex == 1
            ? Colors.white
            : Colors.black,

        currentIndex:
            _selectedIndex, // Tab hiện tại

        onTap:
            _onItemTapped, // Hàm xử lý khi nhấn vào tab

        items: [
          // Icon Home
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),

            activeIcon: Icon(
              Icons.home_filled,
            ),

            label: lang.get('nav_home'),
          ),

          // Icon Reels
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons
                  .circlePlay,
              size: 24,
            ),

            activeIcon: FaIcon(
              FontAwesomeIcons
                  .solidCirclePlay,
              size: 24,
            ),

            label: lang.get(
              'nav_reels',
            ),
          ),

          // Icon Messages
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons
                  .paperPlane,
              size: 24,
            ),

            label: lang.get(
              'nav_messages',
            ),
          ),

          // Icon Search
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search_outlined,
            ),

            activeIcon: Icon(
              Icons.search,
            ),

            label: lang.get(
              'nav_search',
            ),
          ),

          // Icon Profile (Dùng ảnh đại diện của người dùng)
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius:
                  14, // Kích thước avatar

              // Dùng ảnh của người dùng hiện tại, nếu không có thì dùng ảnh mặc định
              backgroundImage: NetworkImage(
                currentUser?.photoURL ??
                    'https://picsum.photos/id/1005/100/100',
              ),
            ),

            label: lang.get(
              'nav_profile',
            ),
          ),
        ],
      ),
    );
  }
}
