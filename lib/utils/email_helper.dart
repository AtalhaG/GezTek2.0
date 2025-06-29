import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class EmailHelper {
  static Future<void> sendRegistrationEmail({
    required String recipientEmail,
    required String recipientName,
    required String userType,
  }) async {
    try {
      if (kIsWeb) {
        // Web platformunda e-posta gönderme işlemi geçici olarak devre dışı
        print('Web platformunda e-posta gönderme işlemi geçici olarak devre dışı bırakıldı.');
        return;
      }

      // Mobil platformlar için e-posta gönderme işlemi
      // TODO: Firebase Cloud Functions veya e-posta servisi API'si entegrasyonu eklenecek
      print('E-posta gönderme işlemi henüz uygulanmadı.');
    } catch (e) {
      print('E-posta gönderilirken hata oluştu: $e');
      // Hata durumunda sessizce devam et
    }
  }
} 