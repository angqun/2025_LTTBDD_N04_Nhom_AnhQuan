// lib/pages/search_page.dart
// BẢN SỬA LỖI: BỎ LISTENER + TẮT HÀNH ĐỘNG BẤM VÀO LỊCH SỬ

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'dart:convert'; 

// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/providers/language_provider.dart';
// import 'package:btl/pages/post_model.dart'; // (Nên xóa dòng này nếu có)
import 'package:btl/models/user_model.dart'; 

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isSearching = false; 
  Stream<QuerySnapshot>? _searchResultsStream;

  List<UserModel> _recentSearches = [];
  bool _isLoadingHistory = true; 

  @override
  void initState() {
    super.initState();
    // Xóa bỏ listener (đã fix ở bản trước)
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- LOGIC LƯU/TẢI LỊCH SỬ (Giữ nguyên) ---

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = prefs.getStringList('recent_searches') ?? [];
    
    setState(() {
      _recentSearches = historyJson
          .map((jsonString) => UserModel.fromJson(jsonDecode(jsonString)))
          .toList();
      _isLoadingHistory = false; 
    });
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson = _recentSearches
        .map((user) => jsonEncode(user.toJson()))
        .toList();
        
    await prefs.setStringList('recent_searches', historyJson);
  }

  // --- LOGIC XỬ LÝ SỰ KIỆN ---

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() { _searchResultsStream = null; });
      return;
    }
    final stream = FirebaseFirestore.instance
        .collection('usertimkiem') 
        .where('username', isEqualTo: query.trim().toLowerCase())
        .limit(10) 
        .snapshots();
    setState(() { _searchResultsStream = stream; });
  }

  void _addToRecentSearches(UserModel user) {
    setState(() {
      // Xóa nếu đã có, sau đó thêm lên đầu
      _recentSearches.removeWhere((item) => item.id == user.id);
      _recentSearches.insert(0, user);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
    _saveRecentSearches(); // Lưu lại
  }

  void _removeFromRecent(String userId) {
    setState(() {
      _recentSearches.removeWhere((item) => item.id == userId);
    });
    _saveRecentSearches(); 
  }

  void _clearAllRecent() {
    setState(() {
      _recentSearches.clear();
    });
    _saveRecentSearches(); 
  }


  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(lang),
            Expanded(
              child: _isSearching
                  ? _buildSearchResults(lang) 
                  : _buildExploreGrid(lang),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS CON ---

  Widget _buildSearchBar(LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: lang.get('search'),
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              
              // Tự kích hoạt state khi bấm vào
              onTap: () {
                if (!_isSearching) {
                  setState(() {
                    _isSearching = true;
                  });
                }
              },

              onChanged: (value) {
                // Tự kích hoạt nếu người dùng gõ
                if (!_isSearching) {
                  setState(() {
                    _isSearching = true;
                  });
                }
                _performSearch(value);
              },
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: TextButton(
                onPressed: () {
                  _searchController.clear();
                  _focusNode.unfocus(); 
                  _performSearch('');
                  
                  // Tự tắt state khi bấm hủy
                  setState(() {
                    _isSearching = false;
                  });
                },
                child: Text(lang.get('cancel')),
              ),
            ),
        ],
      ),
    );
  }

  // (Hàm _buildExploreGrid giữ nguyên - dùng ảnh giả)
  Widget _buildExploreGrid(LanguageProvider lang) {
    return MasonryGridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      itemCount: 51,
      itemBuilder: (context, index) {
        if (index % 5 == 0) {
          return StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: Image.network(
              'https://picsum.photos/id/${index + 20}/400/400', 
              fit: BoxFit.cover,
            ),
          );
        }
        return StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: Image.network(
            'https://picsum.photos/id/${index + 20}/200/200', 
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(LanguageProvider lang) {
    // Trạng thái 2: Đang focus, nhưng chưa gõ gì -> Hiển thị Lịch sử
    if (_searchController.text.isEmpty) {
      return _buildRecentSearches(lang); // (Gọi hàm Lịch sử)
    }
    
    // Trạng thái 3: Đang gõ, hiển thị kết quả
    return StreamBuilder<QuerySnapshot>(
      stream: _searchResultsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text(lang.get('no_results_found')));
        }
        
        final userDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: userDocs.length,
          itemBuilder: (context, index) {
            final user = UserModel.fromFirestore(userDocs[index]); 
            
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              title: Text(user.username, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(user.displayName),
              onTap: () {
                // Chỉ gọi hàm lưu lại (đã fix ở bản trước)
                _addToRecentSearches(user); 
                print('Đã lưu ${user.username} vào lịch sử');
                
                // (Tùy chọn: bạn có thể tự fill text và giữ state)
                _searchController.text = user.username;
                _performSearch(user.username);
                _focusNode.unfocus(); // Ẩn bàn phím
              },
            );
          },
        );
      },
    );
  }
  
  Widget _buildRecentSearches(LanguageProvider lang) {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentSearches.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(lang.get('recent'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      );
    }
    
    return ListView.builder(
      itemCount: _recentSearches.length + 1, // +1 cho Header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lang.get('recent'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: _clearAllRecent,
                  child: Text(lang.get('clear_all'), style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          );
        }
        
        final user = _recentSearches[index - 1]; 
        
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          title: Text(user.username, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(user.displayName),
          trailing: IconButton(
            icon: Icon(Icons.close, color: Colors.grey),
            onPressed: () {
              _removeFromRecent(user.id);
            },
          ),
          onTap: () {
            // <<< SỬA LỖI THEO YÊU CẦU: KHÔNG LÀM GÌ CẢ
            
          },
        );
      },
    );
  }
}