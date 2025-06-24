import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
      final dbRef = FirebaseDatabase.instance.ref();
      // Önce rehberlerde ara
      final rehberSnapshot = await dbRef.child('rehberler').get();
      print('📡 Rehber SDK Snapshot: ${rehberSnapshot.exists}');
      if (rehberSnapshot.exists) {
        final rehberData = Map<String, dynamic>.from(rehberSnapshot.value as Map);
        print('📊 Rehber Data: $rehberData');
        for (var entry in rehberData.entries) {
          final data = Map<String, dynamic>.from(entry.value);
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
      print('❌ Rehberlerde bulunamadı, turistlerde araniyor...');
      // Rehberlerde bulunamadıysa turistlerde ara
      final turistSnapshot = await dbRef.child('turistler').get();
      print('📡 Turist SDK Snapshot: ${turistSnapshot.exists}');
      if (turistSnapshot.exists) {
        final turistData = Map<String, dynamic>.from(turistSnapshot.value as Map);
        print('📊 Turist Data: $turistData');
        for (var entry in turistData.entries) {
          final data = Map<String, dynamic>.from(entry.value);
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

  Future<Map<String, dynamic>?> _findUserByEmail(String node, String email) async {
    final query = FirebaseDatabase.instance.ref().child(node).orderByChild('email').equalTo(email.toLowerCase().trim());
    final snapshot = await query.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final entry = data.entries.first;
      return {
        'data': Map<String, dynamic>.from(entry.value),
        'firebaseKey': entry.key,
      };
    }
    return null;
  }
} 