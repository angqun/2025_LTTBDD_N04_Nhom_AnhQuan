// lib/pages/messages_page.dart
// BẢN SỬA LỖI: GỘP 2 APPBAR VÀ THÊM PADDING (ĐỆM)

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 

// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/providers/language_provider.dart';
import 'package:btl/models/message_model.dart'; 

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    // Lấy user hiện tại để hiển thị tên và avatar
    final User? currentUser = FirebaseAuth.instance.currentUser; 

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('messages').snapshots(),
      builder: (context, snapshot) {
        
        List<MessageThread> threads = [];
        if (snapshot.hasData) {
          threads = snapshot.data!.docs
              .map((doc) => MessageThread.fromFirestore(doc))
              .toList();
        }
        
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // <<< THAY ĐỔI 1: GỘP 2 APPBAR LÀM MỘT
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                pinned: false, // Để tất cả cùng trôi lên
                floating: true, // Cho phép trôi
                
                // Phần "angquan1406"
                leading: IconButton(
                  icon: const Icon(
                    Icons.edit_outlined, 
                    color: Colors.black, 
                    size: 28,
                  ),
                  onPressed: () {}, 
                ),
                centerTitle: true, 
                title: const Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Text(
                      'angquan1406', // Tên của bạn
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down, 
                      color: Colors.black, 
                      size: 24,
                    ),
                  ],
                ),
                actions: [
                  Container(width: 56.0), // Cân bằng
                ],
                
                // Phần "bottom" (Tìm kiếm, Ghi chú, Bản đồ)
                bottom: PreferredSize(
                  // Tổng chiều cao = 8 (đệm) + ~50 (search) + 110 (bubbles) = ~168
                  preferredSize: const Size.fromHeight(168.0), 
                  child: Column(
                    children: [
                      // <<< THAY ĐỔI 2: THÊM PADDING (ĐỆM) Ở ĐÂY
                      // Đây là khoảng cách "1 chút" mà bạn muốn
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0), 
                        child: _buildSearchBar(lang),
                      ),
                      _buildNoteBubbles(lang, currentUser?.photoURL), 
                    ],
                  ),
                ),
              )
            ];
          },
          body: Column(
            children: [
              // Divider (Đường kẻ)
              const Divider(height: 1, color: Colors.grey, thickness: 0.2), 
              
              _buildInboxHeader(lang), 
              if (snapshot.connectionState == ConnectionState.waiting && threads.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: _buildMessageList(lang, threads),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(LanguageProvider lang) {
    return Container(
      // <<< THAY ĐỔI 3: XÓA PADDING 'TOP' Ở ĐÂY
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        readOnly: true, 
        decoration: InputDecoration(
          hintText: lang.get('meta_search_hint'), 
          prefixIcon: Container(
            padding: const EdgeInsets.all(12.0), 
            child: Container(
              width: 18, 
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.purple.shade400], 
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(2.5), 
                decoration: BoxDecoration(
                  color: Colors.grey[200], 
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 10), 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0), 
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildNoteBubbles(LanguageProvider lang, String? userAvatarUrl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Vòng "Ghi chú của bạn"
          Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200], 
                backgroundImage: userAvatarUrl != null && userAvatarUrl.isNotEmpty
                    ? NetworkImage(userAvatarUrl)
                    : const NetworkImage('https://picsum.photos/id/1005/100/100') as ImageProvider,
              ),
              const SizedBox(height: 8),
              Text(lang.get('your_note'), style: TextStyle(fontSize: 12)),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.red, size: 12),
                  SizedBox(width: 4),
                  Text(
                    lang.get('location_sharing_off'),
                    style: TextStyle(color: Colors.red, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Vòng "Bản đồ"
          Column(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white, 
                backgroundImage: NetworkImage('https://i.imgur.com/gK0SgG1.png'), // Ảnh trái đất
              ),
              const SizedBox(height: 8),
              Text(lang.get('map'), style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInboxHeader(LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            lang.get('nav_messages'), 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            lang.get('pending_messages'), 
            style: TextStyle(color: Colors.blue[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(LanguageProvider lang, List<MessageThread> threads) {
    if (threads.isEmpty) {
      return Center(child: Text(lang.get('no_messages')));
    }
    
    return ListView.builder(
      itemCount: threads.length,
      padding: EdgeInsets.zero, 
      itemBuilder: (context, index) {
        final thread = threads[index];

        // LOGIC DỊCH BẢN PHỤ ĐỀ
        String subtitleText;
        if (thread.newMessageCount > 0) {
          subtitleText = '${thread.newMessageCount} ${lang.get('new_messages')}';
        } 
        else if (thread.lastMessageKey.isNotEmpty) {
          subtitleText = lang.get(thread.lastMessageKey); 
        } 
        else {
          subtitleText = '';
        }

        // Tính toán thời gian
        String timeText = _formatTimestamp(context, thread.timestamp);

        // Ghép 2 chuỗi lại
        if (subtitleText.isNotEmpty && timeText.isNotEmpty) {
          subtitleText = '$subtitleText · $timeText';
        } else if (subtitleText.isEmpty) {
          subtitleText = timeText;
        }

        return ListTile(
          onTap: () {}, 
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(thread.avatarUrl),
          ),
          title: Text(
            thread.username,
            style: TextStyle(
              fontWeight: !thread.isRead ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            subtitleText, 
            style: TextStyle(
              color: !thread.isRead ? Colors.black : Colors.grey[600],
              fontWeight: !thread.isRead ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: _buildTrailingWidget(thread),
        );
      },
    );
  }

  Widget _buildTrailingWidget(MessageThread thread) {
    if (!thread.isRead) {
      return Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      );
    }
    if (thread.seenStatus == 'camera') {
      return Icon(Icons.camera_alt_outlined, color: Colors.grey[600]);
    }
    
    return const SizedBox.shrink();
  }

  // HÀM TÍNH TOÁN VÀ DỊCH THỜI GIAN
  String _formatTimestamp(BuildContext context, Timestamp? timestamp) {
    if (timestamp == null) return ''; 

    final lang = Provider.of<LanguageProvider>(context, listen: false);
    final diff = DateTime.now().difference(timestamp.toDate());

    if (diff.inDays > 0) {
      return '${diff.inDays} ${lang.get('days_ago')}'; // "2 ngày" hoặc "2 day"
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ${lang.get('hours_ago')}'; // "2 giờ" hoặc "2 hour"
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${lang.get('minutes_ago')}'; // "2 phút" hoặc "2 minute"
    } else {
      return lang.get('just_now'); // 'Vừa xong'
    }
  }
}