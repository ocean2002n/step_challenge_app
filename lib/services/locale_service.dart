import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _locale = const Locale('zh', 'TW'); // 預設繁體中文
  
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
      switch (savedLanguage) {
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
          _locale = const Locale('zh', 'TW');
      }
      notifyListeners();
    }
  }
  
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
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
        _locale = const Locale('zh', 'TW');
    }
    
    notifyListeners();
  }
  
  String get currentLanguageCode => _locale.languageCode;
  
  bool isCurrentLanguage(String languageCode) {
    return _locale.languageCode == languageCode;
  }
}