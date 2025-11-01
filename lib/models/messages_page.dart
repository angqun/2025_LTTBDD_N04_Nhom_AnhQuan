// lib/pages/messages_page.dart
// BẢN HOÀN CHỈNH: ĐÃ TÍCH HỢP ĐA NGÔN NGỮ

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
    // <<< LẤY 'lang' (Provider) 1 LẦN Ở ĐẦU
    final lang = Provider.of<LanguageProvider>(context);
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
              // (Giữ nguyên cấu trúc 1 SliverAppBar)
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                pinned: false, 
                floating: true, 
                
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
                  preferredSize: const Size.fromHeight(168.0), 
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0), 
                        // <<< TRUYỀN 'lang' VÀO
                        child: _buildSearchBar(lang),
                      ),
                      // <<< TRUYỀN 'lang' VÀO
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
              
              _buildInboxHeader(lang), // <<< TRUYỀN 'lang' VÀO
              if (snapshot.connectionState == ConnectionState.waiting && threads.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  // <<< TRUYỀN 'lang' VÀO
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
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
      child: TextField(
        readOnly: true, 
        decoration: InputDecoration(
          // <<< ĐÃ DỊCH
          hintText: lang.get('meta_search_hint'), 
          
          prefixIcon: Container(
            padding: const EdgeInsets.all(12.0), 
            child: Container(
              width: 18, 
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF833AB4), 
                    Color(0xFF405DE6), 
                    Color(0xFF5851DB),
                  ],
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
              // <<< ĐÃ DỊCH
              Text(lang.get('your_note'), style: TextStyle(fontSize: 12)),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: Colors.red, size: 12),
                  SizedBox(width: 4),
                  Text(
                    // <<< ĐÃ DỊCH
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
                backgroundImage: NetworkImage('https://genk.mediacdn.vn/2017/photo-1-1484629874893.jpg'), // (Ảnh trái đất)
              ),
              const SizedBox(height: 8),
              // <<< ĐÃ DỊCH
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
            // <<< ĐÃ DỊCH
            lang.get('nav_messages'), 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            // <<< ĐÃ DỊCH
            lang.get('pending_messages'), 
            style: TextStyle(color: Colors.blue[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(LanguageProvider lang, List<MessageThread> threads) {
    if (threads.isEmpty) {
      // <<< ĐÃ DỊCH
      return Center(child: Text(lang.get('no_messages')));
    }
    
    return ListView.builder(
      itemCount: threads.length,
      padding: EdgeInsets.zero, 
      itemBuilder: (context, index) {
        final thread = threads[index];

        String subtitleText = thread.lastMessage;
        if (thread.lastMessage.isNotEmpty && thread.timestamp.isNotEmpty) {
          subtitleText = '${thread.lastMessage} · ${thread.timestamp}';
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
}