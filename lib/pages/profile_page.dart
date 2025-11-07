// lib/pages/profile_page.dart
// BẢN HOÀN CHỈNH: SỬA LỖI OVERFLOW + DÙNG LẠI STRING (THEO YÊU CẦU)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
// (Xóa 'intl.dart')

// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/providers/language_provider.dart';
import 'package:btl/models/profile_story_model.dart'; 
import 'package:btl/models/profile_post_model.dart'; 
import 'package:btl/models/user_profile_data.dart'; // <<< DÙNG MODEL STRING
import 'package:btl/l10n/app_strings.dart'; // (Cần cho menu ngôn ngữ)

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  late final Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); 
    
    if (currentUser != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid) 
          .snapshots();
    } else {
      _userStream = Stream.empty();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- HÀM LOGIC ---

  // Hàm dịch STRING (tr -> M, nghìn -> K)
  String _translateStat(String statValue, LanguageProvider lang) {
    if (statValue.length < 2 && int.tryParse(statValue) != null) return statValue;
    if (lang.locale.languageCode == 'en') {
      return statValue
          .replaceAll('tr', 'M')
          .replaceAll('tỷ', 'B')
          .replaceAll('nghìn', 'K'); 
    } else {
      return statValue
          .replaceAll('M', 'tr')
          .replaceAll('B', 'tỷ')
          .replaceAll('K', 'nghìn'); 
    }
  }

  // Hàm mở Bảng chọn Ngôn ngữ
  void _showLanguagePicker(BuildContext context, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 16),
              Text(
                lang.get('menu_change_language'), 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(height: 24),
              ListTile(
                title: Text(AppStrings.vi['language_name']!), 
                trailing: lang.locale.languageCode == 'vi' ? Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  lang.setLanguage(Locale('vi'));
                  Navigator.pop(ctx); 
                },
              ),
              ListTile(
                title: Text(AppStrings.en['language_name']!),
                trailing: lang.locale.languageCode == 'en' ? Icon(Icons.check, color: Colors.blue) : null,
                onTap: () {
                  lang.setLanguage(Locale('en'));
                  Navigator.pop(ctx); 
                },
              ),
            ],
          ),
        );
      }
    );
  }

  // Hàm mở Menu Cài đặt
  void _showSettingsMenu(BuildContext context, LanguageProvider lang) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) { 
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 16),
              Text(
                lang.get('menu_settings'),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(lang.get('menu_change_language')),
                onTap: () {
                  Navigator.pop(ctx); 
                  _showLanguagePicker(context, lang); 
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  lang.get('menu_log_out'),
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(ctx); 
                  FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    
    return StreamBuilder<DocumentSnapshot>(
      stream: _userStream,
      builder: (context, userSnapshot) {
        
        UserProfileData userData = UserProfileData(
          uid: currentUser?.uid ?? '',
          username: currentUser?.email?.split('@').first ?? 'angquan1406',
          displayName: 'anhwwuan',
          avatarUrl: currentUser?.photoURL ?? 'https://picsum.photos/id/1005/100/100',
          bio: '@angquan1406',
          postCount: '0', // Dạng String
          followerCount: '0', // Dạng String
          followingCount: '0', // Dạng String
        );
        
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          userData = UserProfileData.fromFirestore(userSnapshot.data!);
        }
        
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 1. Thanh AppBar
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                pinned: true,
                floating: true,
                leading: IconButton(
                  icon: Icon(Icons.add, color: Colors.black, size: 30),
                  onPressed: () {},
                ),
                centerTitle: true,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.lock, size: 16),
                    SizedBox(width: 8),
                    Text(
                      userData.username, 
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
                    ),
                    Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.black, size: 30),
                    onPressed: () {
                       _showSettingsMenu(context, lang); // Kích hoạt Menu
                    },
                  ),
                ],
              ),

              // 2. Phần thông tin
              SliverToBoxAdapter(
                child: _buildProfileHeader(lang, userData), 
              ),

              // 3. Phần Story Highlights
              SliverToBoxAdapter(
                child: _buildStoryHighlights(lang), 
              ),

              // 4. Thanh Tab
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
              _buildPostsGrid(lang),
              Center(child: Text('Trang Reels cá nhân (sẽ làm sau)')),
              Center(child: Text('Trang được gắn thẻ (sẽ làm sau)')),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGETS CON ---

  // (Avatar, Stats, Buttons)
  Widget _buildProfileHeader(LanguageProvider lang, UserProfileData userData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: NetworkImage(userData.avatarUrl),
                  ),
                  Positioned(
                    right: 0, 
                    bottom: 0, 
                    child: CircleAvatar(
                      radius: 15, 
                      backgroundColor: Colors.blue, 
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 18), 
                    ),
                  ),
                ],
              ),
              
              // Stats
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    // Tên 'anhwwuan' (Ở TRÊN)
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0), 
                      child: Text(
                        userData.displayName, // "anhwwuan"
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // <<< SỬA LỖI 1: SỬA HÀNG STATS (BỌC BẰNG EXPANDED)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Bọc mỗi cột bằng Expanded (thay vì Flexible)
                        Expanded( // <<< THAY ĐỔI
                          child: _buildStatColumn(
                            userData.postCount, 
                            lang.get('profile_posts')
                          )
                        ),
                        Expanded( // <<< THAY ĐỔI
                          child: _buildStatColumn(
                            _translateStat(userData.followerCount, lang), 
                            lang.get('profile_followers')
                          )
                        ),
                        Expanded( // <<< THAY ĐỔI
                          child: _buildStatColumn(
                            _translateStat(userData.followingCount, lang), 
                            lang.get('profile_following')
                          )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Bio
          Text(userData.bio), 
          
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
              _buildProfileButton(Icons.person_add_outlined, () {}, isIconButton: true, size: 40),
            ],
          ),
        ],
      ),
    );
  }
  
  // (Hàm phụ cho Stats - đã sửa)
  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min, 
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
          label, 
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.center, // Căn giữa
        ),
      ],
    );
  }

  // (Hàm phụ cho Nút - Không đổi)
  Widget _buildProfileButton(dynamic textOrIcon, VoidCallback onPressed, {bool isIconButton = false, double? size}) {
    return Container(
      height: 34, 
      width: isIconButton ? size : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black,
          elevation: 0,
          padding: EdgeInsets.zero, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isIconButton
            ? Icon(textOrIcon as IconData, size: 20)
            : Text(textOrIcon as String, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // (Story Highlights - Đã sửa viền và xóa nút "Mới")
  Widget _buildStoryHighlights(LanguageProvider lang) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('storycanhan').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox.shrink(); 
          
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
                      radius: 34, 
                      backgroundColor: Colors.grey[400], 
                      child: CircleAvatar(
                        radius: 30, 
                        backgroundImage: NetworkImage(story.imageUrl),
                      ),
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

  // (Lưới bài đăng cá nhân - Không đổi)
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
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, 
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

// (Class _SliverTabBarDelegate - Không đổi)
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
      color: Theme.of(context).scaffoldBackgroundColor, 
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}