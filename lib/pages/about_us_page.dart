// lib/pages/about_us_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:btl/providers/language_provider.dart'; // (Sửa 'btl' nếu tên dự án bạn khác)

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    // Dùng TextStyle cho tiêu đề và nội dung
    final titleStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black);
    final subtitleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87);
    final bodyStyle = TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        // Lấy tiêu đề từ app_strings
        title: Text(
          lang.get('menu_about_us'), 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // 1. Tên Dự án (Thay thế bằng tên của bạn)
          Text(
            'Dự án: Ứng dụng Mạng xã hội AnhQuan', // <<< THAY TÊN DỰ ÁN
            style: titleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // 2. Mô tả (Thay thế bằng mô tả của bạn)
          Text(
            'Đây là bài tập lớn môn Phân tích và Thiết kế Phần mềm, thực hiện việc phân tích và xây dựng một ứng dụng mạng xã hội đa nền tảng (iOS, Android, Web) bằng Flutter và Firebase.', // <<< THAY MÔ TẢ
            style: bodyStyle,
            textAlign: TextAlign.justify,
          ),
          const Divider(height: 48, thickness: 1),

          // 3. Giảng viên (Thay thế)
          Text(
            lang.get('about_instructor'), // 'Giảng viên hướng dẫn'
            style: subtitleStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'ThS. (Nguyễn Xuân Quế)', // <<< THAY TÊN GV
            style: bodyStyle,
          ),
          const SizedBox(height: 32),

          // 4. Thành viên nhóm (Thay thế)
          Text(
            lang.get('about_team_members'), // 'Thành viên nhóm'
            style: subtitleStyle,
          ),
          const SizedBox(height: 16),
          
          // Thêm mỗi thành viên vào đây
          _buildMemberTile(
            name: '(Nguyễn Anh Quân)', // <<< THAY TÊN
            mssv: '(23010215)', // <<< THAY MSSV
            role: 'Trưởng nhóm, Lập trình viên chính (Full-stack)',
          ),
          
          // (Thêm các thành viên khác nếu có)
        ],
      ),
    );
  }

  // Widget phụ để hiển thị thông tin thành viên cho đẹp
  Widget _buildMemberTile({required String name, required String mssv, required String role}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
          ),
          const SizedBox(height: 4),
          Text(
            'MSSV: $mssv',
            style: TextStyle(fontSize: 16, color: Colors.black87, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Text(
            'Vai trò: $role',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}