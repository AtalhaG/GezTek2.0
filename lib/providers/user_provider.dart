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
      final dbRef = FirebaseDatabase.instance.ref();
      // Önce rehberlerde ara
      final rehberSnapshot = await dbRef.child('rehberler').child(firebaseUser.uid).get();
      if (rehberSnapshot.exists) {
        final data = Map<String, dynamic>.from(rehberSnapshot.value as Map);
        _currentUser = AppUser.fromFirebaseAuth(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          userData: data,
          isRehber: true,
        );
      } else {
        // Turistlerde ara
        final turistSnapshot = await dbRef.child('turistler').child(firebaseUser.uid).get();
        if (turistSnapshot.exists) {
          final data = Map<String, dynamic>.from(turistSnapshot.value as Map);
          _currentUser = AppUser.fromFirebaseAuth(
            uid: firebaseUser.uid,
            email: firebaseUser.email!,
            userData: data,
            isRehber: false,
          );
        } else {
          throw Exception('Kullanıcı verisi bulunamadı');
        }
      }
      print('🆔 Kullanıcı ID: ${_currentUser!.id}, Email: ${_currentUser!.email}, Rol: ${_currentUser!.isGuide ? "Rehber" : "Turist"}');
    } catch (e) {
      _errorMessage = 'Kullanıcı bilgileri yüklenirken hata: $e';
      print('UserProvider Error: $_errorMessage');
    }
    
    _setLoading(false);
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

  // Tüm rehberleri çek
  Future<List<AppUser>> fetchAllGuides() async {
    final dbRef = FirebaseDatabase.instance.ref();
    final rehberSnapshot = await dbRef.child('rehberler').get();
    List<AppUser> rehberler = [];
    if (rehberSnapshot.exists) {
      final rehberData = Map<String, dynamic>.from(rehberSnapshot.value as Map);
      for (var entry in rehberData.entries) {
        final data = Map<String, dynamic>.from(entry.value);
        rehberler.add(AppUser.fromFirebaseAuth(
          uid: data['id'],
          email: data['email'],
          userData: data,
          isRehber: true,
        ));
      }
    }
    return rehberler;
  }
} 