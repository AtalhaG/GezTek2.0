import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/group_model.dart';

class GroupService {
  static const String baseUrl = 'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app';
  
  // Kullanıcı için geçici ID (normalde auth sisteminden gelecek)
  static String getCurrentUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  static String getCurrentUserName() {
    return 'Kullanıcı'; // Normalde auth sisteminden gelecek
  }

  // Tur için grup oluştur
  static Future<String?> createGroupForTour({
    required String turId,
    required String turAdi,
    required String rehberId,
    required String rehberAdi,
  }) async {
    try {
      final grup = GrupModel(
        id: '',
        turId: turId,
        turAdi: turAdi,
        rehberId: rehberId,
        rehberAdi: rehberAdi,
        katilimcilar: [rehberId], // Başlangıçta sadece rehber
        olusturmaTarihi: DateTime.now().toIso8601String(),
        sonMesajTarihi: DateTime.now().toIso8601String(),
        sonMesaj: 'Grup oluşturuldu',
      );

      final response = await http.post(
        Uri.parse('$baseUrl/gruplar.json'),
        body: json.encode(grup.toMap()),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['name'];
      }
    } catch (e) {
      print('Grup oluşturma hatası: $e');
    }
    return null;
  }

  // Kullanıcıyı gruba ekle
  static Future<bool> addUserToGroup({
    required String grupId,
    required String userId,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/gruplar/$grupId/katilimcilar.json'),
        body: json.encode({userId: true}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Gruba katılma hatası: $e');
      return false;
    }
  }

  // Tur için grup var mı kontrol et
  static Future<String?> getGroupByTourId(String turId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/gruplar.json?orderBy="turId"&equalTo="$turId"'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null && responseData is Map && responseData.isNotEmpty) {
          return responseData.keys.first;
        }
      }
    } catch (e) {
      print('Grup arama hatası: $e');
    }
    return null;
  }

  // Kullanıcının gruplarını getir
  static Future<List<GrupModel>> getUserGroups(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/gruplar.json'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<GrupModel> gruplar = [];

        if (responseData != null && responseData is Map) {
          responseData.forEach((key, value) {
            final grup = GrupModel.fromFirebase(key, value);
            if (grup.katilimcilar.contains(userId)) {
              gruplar.add(grup);
            }
          });
        }

        // Son mesaj tarihine göre sırala
        gruplar.sort((a, b) => b.sonMesajTarihi.compareTo(a.sonMesajTarihi));
        return gruplar;
      }
    } catch (e) {
      print('Grupları getirme hatası: $e');
    }
    return [];
  }

  // Grup mesajlarını getir
  static Future<List<GrupMesajModel>> getGroupMessages(String grupId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grup_mesajlari.json?orderBy="grupId"&equalTo="$grupId"'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<GrupMesajModel> mesajlar = [];

        if (responseData != null && responseData is Map) {
          responseData.forEach((key, value) {
            mesajlar.add(GrupMesajModel.fromFirebase(key, value));
          });
        }

        // Tarihe göre sırala
        mesajlar.sort((a, b) => a.tarih.compareTo(b.tarih));
        return mesajlar;
      }
    } catch (e) {
      print('Mesajları getirme hatası: $e');
    }
    return [];
  }

  // Mesaj gönder
  static Future<bool> sendMessage({
    required String grupId,
    required String mesaj,
    required String gonderenId,
    required String gonderenAdi,
  }) async {
    try {
      final mesajModel = GrupMesajModel(
        id: '',
        grupId: grupId,
        gonderenId: gonderenId,
        gonderenAdi: gonderenAdi,
        mesaj: mesaj,
        tarih: DateTime.now().toIso8601String(),
      );

      // Mesajı kaydet
      final response = await http.post(
        Uri.parse('$baseUrl/grup_mesajlari.json'),
        body: json.encode(mesajModel.toMap()),
      );

      if (response.statusCode == 200) {
        // Grubun son mesaj bilgisini güncelle
        await http.patch(
          Uri.parse('$baseUrl/gruplar/$grupId.json'),
          body: json.encode({
            'sonMesaj': mesaj,
            'sonMesajTarihi': mesajModel.tarih,
          }),
        );
        return true;
      }
    } catch (e) {
      print('Mesaj gönderme hatası: $e');
    }
    return false;
  }

  // Tura katılım işlemi - grup oluştur veya katıl
  static Future<bool> joinTourAndGroup({
    required String turId,
    required String turAdi,
    required String userId,
    required String userName,
  }) async {
    try {
      // Önce bu tur için grup var mı kontrol et
      String? grupId = await getGroupByTourId(turId);
      
      if (grupId == null) {
        // Grup yoksa oluştur (rehber tarafından)
        grupId = await createGroupForTour(
          turId: turId,
          turAdi: turAdi,
          rehberId: 'rehber_temp', // Normalde tur sahibi rehber ID'si
          rehberAdi: 'Rehber',
        );
      }

      if (grupId != null) {
        // Kullanıcıyı gruba ekle
        bool success = await addUserToGroup(
          grupId: grupId,
          userId: userId,
        );

        if (success) {
          // Gruba katılım mesajı gönder
          await sendMessage(
            grupId: grupId,
            mesaj: '$userName tura katıldı! 🎉',
            gonderenId: 'system',
            gonderenAdi: 'Sistem',
          );
        }

        return success;
      }
    } catch (e) {
      print('Tura katılım hatası: $e');
    }
    return false;
  }
} 