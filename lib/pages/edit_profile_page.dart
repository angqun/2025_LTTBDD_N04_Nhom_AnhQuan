// lib/pages/edit_profile_page.dart
// BẢN CẬP NHẬT: LÀM ĐẦY ĐỦ GIAO DIỆN GIỐNG ẢNH

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart'; // Cần cho Switch

import 'package:btl/providers/language_provider.dart';
import 'package:btl/models/user_profile_data.dart';
import 'package:btl/pages/edit_field_page.dart'; // Trang sửa Tên/Tên người dùng

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _threadsToggle = true; // Giá trị cho nút gạt Threads

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Dùng StreamBuilder để lấy dữ liệu MỚI NHẤT
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance.collection('users').doc(currentUserId).snapshots(),
      builder: (context, snapshot) {
        // Tạo dữ liệu mặc định
        UserProfileData userData = UserProfileData(
          uid: currentUserId,
          username: 'loading...',
          displayName: 'loading...',
          avatarUrl: '',
          bio: '',
          postCount: '0',
          followerCount: '0',
          followingCount: '0',
        );

        if (snapshot.hasData && snapshot.data!.exists) {
          userData = UserProfileData.fromFirestore(snapshot.data!);
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0, // Chống đổi màu khi cuộn
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              lang.get('edit_profile_title'), // "Chỉnh sửa trang cá nhân"
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              // 1. Phần Chỉnh sửa ảnh
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.grey[200],
                      // Dùng ảnh user hoặc ảnh placeholder
                      backgroundImage: (userData.avatarUrl.isNotEmpty
                              ? NetworkImage(userData.avatarUrl)
                              : AssetImage('https://picsum.photos/id/1005/100/100')) // Cần có ảnh placeholder
                          as ImageProvider,
                    ),
                    SizedBox(height: 12),
                    Text(
                      lang.get('edit_profile_picture'), // "Chỉnh sửa ảnh hoặc avatar"
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              
              // 2. Tên (CHỨC NĂNG CHÍNH)
              _buildEditTile(
                lang: lang,
                titleKey: 'profile_name', // 'Tên'
                value: userData.displayName,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFieldPage(
                        appBarTitle: lang.get('profile_name'),
                        initialValue: userData.displayName,
                        targetField: 'displayName', // Field trên Firebase
                        noteKey: 'name_rules', // Ghi chú
                      ),
                    ),
                  );
                }
              ),

              // 3. Tên người dùng (CHỨC NĂNG CHÍNH)
              _buildEditTile(
                lang: lang,
                titleKey: 'profile_username', // 'Tên người dùng'
                value: userData.username,
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditFieldPage(
                        appBarTitle: lang.get('profile_username'),
                        initialValue: userData.username,
                        targetField: 'username', // Field trên Firebase
                        noteKey: 'username_rules', // Ghi chú
                      ),
                    ),
                  );
                }
              ),

              // 4. Các mục "Để cho đẹp" (Giống ảnh)
              _buildEditTile(
                lang: lang,
                titleKey: 'profile_pronouns', // 'Danh xưng'
                value: lang.get('profile_pronouns_placeholder'), // 'Danh xưng'
                onTap: () {}, // Không làm gì
              ),
              _buildEditTile(
                lang: lang,
                titleKey: 'profile_bio', // 'Tiểu sử'
                value: lang.get('profile_bio_placeholder'), // 'Tiểu sử'
                onTap: () {}, // Không làm gì
              ),
              _buildNavigationTile(
                lang: lang,
                titleKey: 'profile_links', // 'Liên kết'
                value: lang.get('profile_links_add'), // 'Thêm liên kết'
                onTap: () {}, // Không làm gì
              ),
              _buildNavigationTile(
                lang: lang,
                titleKey: 'profile_badge', // 'Biểu ngữ'
                value: '1', // Giá trị cứng
                onTap: () {}, // Không làm gì
              ),
               _buildNavigationTile(
                lang: lang,
                titleKey: 'profile_music', // 'Nhạc'
                value: lang.get('profile_music_add'), // 'Thêm nhạc...'
                onTap: () {}, // Không làm gì
              ),

              // 5. Nút gạt Threads
              _buildSwitchTile(
                lang: lang,
                titleKey: 'threads_toggle_title', // 'Hiển thị biểu ngữ Threads'
                subtitleKey: 'threads_toggle_subtitle', // 'Khi bạn bật...'
                value: _threadsToggle,
                onChanged: (newValue) {
                  setState(() {
                    _threadsToggle = newValue;
                  });
                }
              ),

              // 6. Giới tính
              _buildNavigationTile(
                lang: lang,
                titleKey: 'profile_gender', // 'Giới tính'
                value: lang.get('profile_gender_male'), // 'Nam'
                onTap: () {}, // Không làm gì
              ),

              // 7. Các nút xanh
              Divider(height: 32, color: Colors.grey[300]),
              _buildBlueLinkTile(
                lang: lang,
                titleKey: 'switch_to_pro_account', // 'Chuyển sang tài khoản công việc'
                onTap: () {}
              ),
              SizedBox(height: 16),
              _buildBlueLinkTile(
                lang: lang,
                titleKey: 'personal_info_settings', // 'Cài đặt thông tin cá nhân'
                onTap: () {}
              ),
              SizedBox(height: 32), // Thêm khoảng đệm cuối
            ],
          ),
        );
      },
    );
  }

  // Widget cho mục có thể sửa (Tên, Tên người dùng, Danh xưng, Tiểu sử)
  Widget _buildEditTile({
    required LanguageProvider lang,
    required String titleKey,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(lang.get(titleKey), style: TextStyle(fontSize: 17)),
      subtitle: Text(value, style: TextStyle(fontSize: 17, color: Colors.black)),
      onTap: onTap,
    );
  }

  // Widget cho mục có điều hướng (có dấu >)
  Widget _buildNavigationTile({
    required LanguageProvider lang,
    required String titleKey,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(lang.get(titleKey), style: TextStyle(fontSize: 17)),
      subtitle: Text(value, style: TextStyle(fontSize: 17, color: Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
      onTap: onTap,
    );
  }

  // Widget cho nút gạt (Switch)
  Widget _buildSwitchTile({
    required LanguageProvider lang,
    required String titleKey,
    required String subtitleKey,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(lang.get(titleKey), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      subtitle: Text(lang.get(subtitleKey), style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      trailing: CupertinoSwitch( // Dùng Switch kiểu iOS cho đẹp
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
      onTap: () => onChanged(!value), // Cho phép bấm cả hàng
    );
  }

  // Widget cho các nút link màu xanh
  Widget _buildBlueLinkTile({
    required LanguageProvider lang,
    required String titleKey,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Tăng vùng bấm
        child: Text(
          lang.get(titleKey),
          style: TextStyle(color: Colors.blue, fontSize: 17),
        ),
      ),
    );
  }
}