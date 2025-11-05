// lib/pages/profile_page.dart
// BẢN HOÀN CHỈNH (FULL CODE)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 

// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/providers/language_provider.dart';
import 'package:btl/models/profile_story_model.dart'; 
import 'package:btl/models/profile_post_model.dart'; 

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 tabs (Grid, Reels, Tagged)
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    // Dùng NestedScrollView để cuộn tất cả
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // 1. Thanh AppBar (angquan1406, +, lock, menu)
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            pinned: true,
            floating: true,
            centerTitle: false,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.lock, size: 16),
                SizedBox(width: 8),
                Text(
                  currentUser?.email?.split('@').first ?? 'angquan1406',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Icon(Icons.keyboard_arrow_down, color: Colors.black),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add_box_outlined, color: Colors.black, size: 28),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.menu, color: Colors.black, size: 30),
                onPressed: () {},
              ),
            ],
          ),

          // 2. Phần thông tin (Avatar, Stats, Buttons)
          SliverToBoxAdapter(
            child: _buildProfileHeader(lang),
          ),

          // 3. Phần Story Highlights
          SliverToBoxAdapter(
            child: _buildStoryHighlights(),
          ),

          // 4. Thanh Tab (Grid, Reels, Tagged)
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.black,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on, color: Colors.black)),
                  Tab(icon: Icon(Icons.video_collection_outlined, color: Colors.black)),
                  Tab(icon: Icon(Icons.person_pin_outlined, color: Colors.black)),
                ],
              ),
            ),
          ),
        ];
      },
      // 5. Nội dung của Tab
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Lưới Bài đăng (Grid)
          _buildPostsGrid(lang),
          
          // Tab 2: Lưới Reels (Placeholder)
          Center(child: Text('Trang Reels cá nhân (sẽ làm sau)')),
          
          // Tab 3: Lưới Tagged (Placeholder)
          Center(child: Text('Trang được gắn thẻ (sẽ làm sau)')),
        ],
      ),
    );
  }

  // --- WIDGETS CON ---

  // (Avatar, Stats, Buttons)
  Widget _buildProfileHeader(LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar
              CircleAvatar(
                radius: 44,
                backgroundImage: NetworkImage(
                  currentUser?.photoURL ?? 'https://picsum.photos/id/1005/100/100'
                ),
              ),
              // Stats
              _buildStatColumn('0', lang.get('profile_posts')),
              _buildStatColumn('24', lang.get('profile_followers')),
              _buildStatColumn('9', lang.get('profile_following')),
            ],
          ),
          SizedBox(height: 12),
          // Tên
          Text(
            currentUser?.email?.split('@').first ?? 'Anh Quân',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text('@' + (currentUser?.email?.split('@').first ?? 'angquan1406')),
          SizedBox(height: 16),
          // Các nút
          Row(
            children: [
              Expanded(
                child: _buildProfileButton(lang.get('profile_edit'), () {}),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildProfileButton(lang.get('profile_share'), () {}),
              ),
              SizedBox(width: 8),
              _buildProfileButton(Icons.person_add_outlined, () {}, isIconButton: true),
            ],
          ),
        ],
      ),
    );
  }
  
  // (Hàm phụ cho Stats)
  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  // (Hàm phụ cho Nút)
  Widget _buildProfileButton(dynamic textOrIcon, VoidCallback onPressed, {bool isIconButton = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isIconButton
          ? Icon(textOrIcon as IconData, size: 20)
          : Text(textOrIcon as String, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // (Story Highlights)
  Widget _buildStoryHighlights() {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('storycanhan').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink(); // Ẩn nếu không có
          
          final highlightDocs = snapshot.data!.docs;
          
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: highlightDocs.length,
            itemBuilder: (context, index) {
              final story = ProfileStory.fromFirestore(highlightDocs[index]);
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(story.imageUrl),
                    ),
                    SizedBox(height: 5),
                    Text(story.title, style: TextStyle(fontSize: 12)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // (Lưới bài đăng cá nhân)
  Widget _buildPostsGrid(LanguageProvider lang) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('postcanhan').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(lang.get('no_posts_available')));
        }
        
        final postDocs = snapshot.data!.docs;

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 cột
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: postDocs.length,
          itemBuilder: (context, index) {
            final post = ProfilePost.fromFirestore(postDocs[index]);
            return Stack(
              alignment: Alignment.topRight,
              children: [
                Image.network(post.imageUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                // Hiển thị icon nếu là Reel
                if (post.isReel)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.video_collection_rounded, color: Colors.white),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

// Class phụ trợ để "pin" TabBar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Màu nền
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}