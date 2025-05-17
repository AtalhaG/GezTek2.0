import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:math';
import 'dart:typed_data';

class EncryptionHelper {
  // Kullanıcıya özel anahtar ve IV oluşturma
  static Map<String, dynamic> generateUserKeys() {
    final random = Random.secure();

    // 32 byte (256 bit) anahtar oluştur
    final keyBytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = encrypt.Key(Uint8List.fromList(keyBytes));

    // 16 byte (128 bit) IV oluştur
    final ivBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final iv = encrypt.IV(Uint8List.fromList(ivBytes));

    return {'key': key.base64, 'iv': iv.base64};
  }

  // Kullanıcıya özel şifreleme
  static String encryptUserData(
    String data,
    String keyBase64,
    String ivBase64,
  ) {
    final key = encrypt.Key.fromBase64(keyBase64);
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  // Kullanıcıya özel şifre çözme
  static String decryptUserData(
    String encryptedData,
    String keyBase64,
    String ivBase64,
  ) {
    final key = encrypt.Key.fromBase64(keyBase64);
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
    return encrypter.decrypt(encrypted, iv: iv);
  }

  // Dosya şifreleme
  static String encryptUserFile(
    List<int> fileBytes,
    String keyBase64,
    String ivBase64,
  ) {
    final key = encrypt.Key.fromBase64(keyBase64);
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);
    return encrypted.base64;
  }

  // Dosya şifre çözme
  static List<int> decryptUserFile(
    String encryptedData,
    String keyBase64,
    String ivBase64,
  ) {
    final key = encrypt.Key.fromBase64(keyBase64);
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypt.Encrypted.fromBase64(encryptedData);
    return encrypter.decryptBytes(encrypted, iv: iv);
  }
}
