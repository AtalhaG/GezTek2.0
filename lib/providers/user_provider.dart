import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool get isLoggedIn => _currentUser != null;
  bool get isGuide => _currentUser?.isGuide ?? false;
  bool get isTourist => _currentUser?.isTourist ?? false;

  // Kullanıcı giriş yaptığında çağrılacak
  Future<void> setUserFromFirebaseAuth(User firebaseUser) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      // Firebase'den kullanıcı verilerini çek
      final userData = await _fetchUserData(firebaseUser.email!);
      
      if (userData != null) {
        _currentUser = AppUser.fromFirebaseAuth(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          userData: userData['data'],
          isRehber: userData['isRehber'],
        );
        
        print('UserProvider: Kullanıcı ayarlandı - ${_currentUser!.fullName} (${_currentUser!.role})');
      } else {
        throw Exception('Kullanıcı verisi bulunamadı');
      }
    } catch (e) {
      _errorMessage = 'Kullanıcı bilgileri yüklenirken hata: $e';
      print('UserProvider Error: $_errorMessage');
    }
    
    _setLoading(false);
  }

  // Firebase'den kullanıcı verilerini çek
  Future<Map<String, dynamic>?> _fetchUserData(String email) async {
    try {
      print('🔍 UserProvider: Email araniyor - $email');
      
      // Önce rehberlerde ara
      final rehberResponse = await http.get(Uri.parse(
        'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/rehberler.json',
      ));

      print('📡 Rehber API Response Status: ${rehberResponse.statusCode}');

      if (rehberResponse.statusCode == 200) {
        final rehberData = json.decode(rehberResponse.body) as Map<String, dynamic>?;
        print('📊 Rehber Data: $rehberData');
        
        if (rehberData != null) {
          for (var entry in rehberData.entries) {
            final data = entry.value as Map<String, dynamic>;
            final dbEmail = data['email']?.toString().toLowerCase().trim() ?? '';
            final searchEmail = email.toLowerCase().trim();
            
            print('🔍 Karşılaştırma - DB Email: "$dbEmail" vs Search Email: "$searchEmail"');
            
            if (dbEmail == searchEmail) {
              print('✅ REHBER BULUNDU! Key: ${entry.key}, Data: $data');
              print('📋 User Data Details:');
              print('   ID: ${data['id']}');
              print('   Email: ${data['email']}');
              print('   İsim: ${data['isim']}');
              print('   Soyisim: ${data['soyisim']}');
              print('   Turlarim: ${data['turlarim']}');
              
              return {
                'data': data,
                'isRehber': true,
                'firebaseKey': entry.key,
              };
            }
          }
        }
      }

      print('❌ Rehberlerde bulunamadı, turistlerde araniyor...');

      // Rehberlerde bulunamadıysa turistlerde ara
      final turistResponse = await http.get(Uri.parse(
        'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turistler.json',
      ));

      print('📡 Turist API Response Status: ${turistResponse.statusCode}');

      if (turistResponse.statusCode == 200) {
        final turistData = json.decode(turistResponse.body) as Map<String, dynamic>?;
        print('📊 Turist Data: $turistData');
        
        if (turistData != null) {
          for (var entry in turistData.entries) {
            final data = entry.value as Map<String, dynamic>;
            final dbEmail = data['email']?.toString().toLowerCase().trim() ?? '';
            final searchEmail = email.toLowerCase().trim();
            
            print('🔍 Karşılaştırma - DB Email: "$dbEmail" vs Search Email: "$searchEmail"');
            
            if (dbEmail == searchEmail) {
              print('✅ TURIST BULUNDU! Key: ${entry.key}, Data: $data');
              print('📋 User Data Details:');
              print('   ID: ${data['id']}');
              print('   Email: ${data['email']}');
              print('   İsim: ${data['isim']}');
              print('   Soyisim: ${data['soyisim']}');
              
              return {
                'data': data,
                'isRehber': false,
                'firebaseKey': entry.key,
              };
            }
          }
        }
      }

      print('❌ Hiçbir yerde bulunamadı!');
      return null;
    } catch (e) {
      print('💥 _fetchUserData Error: $e');
      return null;
    }
  }

  // Kullanıcı çıkış yaptığında çağrılacak
  void clearUser() {
    _currentUser = null;
    _errorMessage = null;
    print('UserProvider: Kullanıcı çıkış yaptı');
    notifyListeners();
  }

  // Loading state yönetimi
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error'ı temizle
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Kullanıcı bilgilerini güncelle
  void updateUser(Map<String, dynamic> updatedData) {
    if (_currentUser != null) {
      _currentUser = AppUser.fromFirebaseAuth(
        uid: _currentUser!.id,
        email: _currentUser!.email,
        userData: {..._currentUser!.userData, ...updatedData},
        isRehber: _currentUser!.isGuide,
      );
      notifyListeners();
    }
  }
} 