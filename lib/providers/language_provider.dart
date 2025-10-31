// lib/providers/language_provider.dart
// BẢN SỬA LỖI: NHẬN NGÔN NGỮ TỪ CONSTRUCTOR

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// (Sửa 'btl' nếu tên dự án bạn khác)
import 'package:btl/l10n/app_strings.dart'; 

class LanguageProvider with ChangeNotifier {
  late Locale _locale; // Bỏ gán mặc định
  late Map<String, String> _strings; // Bỏ gán mặc định

  Locale get locale => _locale;
  Map<String, String> get strings => _strings;

  // <<< THAY ĐỔI 1: CONSTRUCTOR MỚI
  // Nó nhận 'initialLanguageCode' (ví dụ: 'vi' hoặc 'en')
  // được tải từ hàm main()
  LanguageProvider(String initialLanguageCode) {
    if (initialLanguageCode == 'en') {
      _locale = Locale('en');
      _strings = AppStrings.en;
    } else {
      _locale = Locale('vi');
      _strings = AppStrings.vi;
    }
  }
  
  // (Hàm get(String key) giữ nguyên)
  String get(String key) {
    return _strings[key] ?? '$key not found';
  }
  
  // (Hàm setLanguage(Locale locale) giữ nguyên)
  // Hàm này vẫn CẬP NHẬT và LƯU
  void setLanguage(Locale locale) async {
    if (locale == _locale) return; 

    if (locale.languageCode == 'en') {
      _locale = Locale('en');
      _strings = AppStrings.en;
    } else {
      _locale = Locale('vi');
      _strings = AppStrings.vi;
    }
    
    await _saveLanguage(locale.languageCode); 
    notifyListeners(); 
  }

  // (Hàm _saveLanguage(String languageCode) giữ nguyên)
  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
  }

  // <<< THAY ĐỔI 2: XÓA HÀM loadLanguage()
  // Hàm main() sẽ làm công việc này, provider không cần làm nữa
}