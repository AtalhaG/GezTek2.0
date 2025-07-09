import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('tr', 'TR');
  
  Locale get currentLocale => _currentLocale;
  
  // Desteklenen diller
  static const List<Locale> supportedLocales = [
    Locale('tr', 'TR'), // Türkçe
    Locale('en', 'US'), // İngilizce
  ];
  
  // Dil seçenekleri
  static const Map<String, String> languageOptions = {
    'tr': 'Türkçe',
    'en': 'English',
  };
  
  LanguageProvider() {
    _loadSavedLanguage();
  }
  
  // Kaydedilmiş dili yükle
  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage);
        notifyListeners();
      }
    } catch (e) {
      print('Dil yüklenirken hata: $e');
    }
  }
  
  // Dili değiştir
  Future<void> changeLanguage(String languageCode) async {
    try {
      _currentLocale = Locale(languageCode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      notifyListeners();
    } catch (e) {
      print('Dil değiştirilirken hata: $e');
    }
  }
  
  // Mevcut dil kodunu al
  String get currentLanguageCode => _currentLocale.languageCode;
  
  // Mevcut dil adını al
  String get currentLanguageName => languageOptions[_currentLocale.languageCode] ?? 'Türkçe';
} 