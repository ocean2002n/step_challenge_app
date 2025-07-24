import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class LocaleService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _locale = const Locale('en', 'US'); // 預設英文，稍後會根據系統語言更新
  
  Locale get locale => _locale;
  
  List<Locale> get supportedLocales => const [
    Locale('en', 'US'),
    Locale('zh', 'TW'),
    Locale('km', 'KH'),
  ];
  
  Map<String, String> get languageNames => {
    'en': 'English',
    'zh': '繁體中文',
    'km': 'ខ្មែរ',
  };
  
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
  
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);
    
    if (savedLanguage != null) {
      // 使用者已經選擇過語言
      _setLocaleFromLanguageCode(savedLanguage);
    } else {
      // 首次啟動，使用系統語言
      _setLocaleFromSystem();
    }
    notifyListeners();
  }
  
  void _setLocaleFromSystem() {
    final systemLocale = ui.PlatformDispatcher.instance.locale;
    final systemLanguage = systemLocale.languageCode;
    
    // 檢查系統語言是否在支援列表中
    switch (systemLanguage) {
      case 'zh':
        // 根據地區碼決定使用簡體或繁體
        if (systemLocale.countryCode == 'CN' || systemLocale.countryCode == 'SG') {
          _locale = const Locale('zh', 'CN'); // 簡體中文（如果有的話）
        } else {
          _locale = const Locale('zh', 'TW'); // 繁體中文
        }
        break;
      case 'km':
        _locale = const Locale('km', 'KH'); // 高棉語
        break;
      default:
        _locale = const Locale('en', 'US'); // 預設英文
        break;
    }
  }
  
  void _setLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        _locale = const Locale('en', 'US');
        break;
      case 'zh':
        _locale = const Locale('zh', 'TW');
        break;
      case 'km':
        _locale = const Locale('km', 'KH');
        break;
      default:
        _locale = const Locale('en', 'US'); // 預設英文
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    _setLocaleFromLanguageCode(languageCode);
    notifyListeners();
  }
  
  String get currentLanguageCode => _locale.languageCode;
  
  bool isCurrentLanguage(String languageCode) {
    return _locale.languageCode == languageCode;
  }
  
  /// 設定語言區域
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    
    _locale = locale;
    notifyListeners();
  }
}