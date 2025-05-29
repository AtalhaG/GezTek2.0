import 'dart:convert';
import 'dart:io';

class EmailHelper {
  static Future<void> sendRegistrationEmail({
    required String recipientEmail,
    required String recipientName,
    required String userType,
  }) async {
    try {
      // Python'un yüklü olup olmadığını kontrol et
      final pythonCheck = await Process.run('python', ['--version']);
      if (pythonCheck.exitCode != 0) {
        throw Exception('Python yüklü değil. Lütfen Python\'u yükleyin.');
      }

      // Python script'ini çalıştır
      final result = await Process.run('python', [
        'send_email.py',
        json.encode({
          'recipientName': recipientName,
          'userType': userType,
          'userEmail': recipientEmail,
        }),
      ]);

      if (result.exitCode == 0) {
        print('Admin\'e e-posta başarıyla gönderildi');
      } else {
        final errorMessage = result.stderr.toString().trim();
        print('E-posta gönderilirken hata oluştu: $errorMessage');
        
        // Hata mesajına göre özel mesajlar
        if (errorMessage.contains('Gmail kimlik doğrulama hatası')) {
          throw Exception('Gmail kimlik doğrulama hatası. Lütfen uygulama şifresini kontrol edin.');
        } else if (errorMessage.contains('Geçersiz JSON formatı')) {
          throw Exception('Veri formatı hatası oluştu.');
        } else {
          throw Exception('E-posta gönderilirken bir hata oluştu: $errorMessage');
        }
      }
    } on ProcessException catch (e) {
      print('Python script çalıştırılırken hata oluştu: $e');
      throw Exception('E-posta gönderme sistemi şu anda kullanılamıyor.');
    } catch (e) {
      print('E-posta gönderilirken hata oluştu: $e');
      throw Exception('E-posta gönderilirken bir hata oluştu: $e');
    }
  }
} 