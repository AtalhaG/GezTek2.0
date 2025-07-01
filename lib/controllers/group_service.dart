import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/group_model.dart';

class GroupService {
  static const String baseUrl = 'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app';
  
  // Tur oluşturulduğunda mesajlar ve soru-cevap kısmını başlat
  static Future<bool> initializeTourCommunication({
    required String turId,
    required String turAdi,
    required String rehberId,
    required String rehberAdi,
  }) async {
    try {
      print('🏗️ Initializing communication for tour: $turAdi');
      
      final tourCommunicationData = {
        'mesajlar': {},
        'soruCevaplar': {
          'kullaniciSorulari': {},
          'rehberCevaplari': {}
        },
        'grupBilgisi': {
          'turAdi': turAdi,
          'rehberId': rehberId,
          'rehberAdi': rehberAdi,
          'katilimcilar': {rehberId: true},
          'olusturmaTarihi': DateTime.now().toIso8601String(),
          'sonMesajTarihi': DateTime.now().toIso8601String(),
          'sonMesaj': 'Tur grubu oluşturuldu! 🎉',
        }
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/turlar/$turId.json'),
        body: json.encode(tourCommunicationData),
      );

      if (response.statusCode == 200) {
        // Hoş geldin mesajı gönder
        await sendMessageToTour(
          turId: turId,
          mesaj: '🎉 $turAdi tur grubu oluşturuldu! Hoş geldiniz.',
          gonderenId: 'system',
          gonderenAdi: 'Sistem',
        );
        
        print('✅ Tour communication initialized successfully');
        return true;
      }
    } catch (e) {
      print('💥 Tour communication initialization error: $e');
    }
    return false;
  }

  // Kullanıcıyı tur grubuna ekle
  static Future<bool> addUserToTour({
    required String turId,
    required String userId,
    required String userName,
  }) async {
    try {
      // Kullanıcıyı katılımcılar listesine ekle
      final response = await http.patch(
        Uri.parse('$baseUrl/turlar/$turId/grupBilgisi/katilimcilar.json'),
        body: json.encode({userId: true}),
      );

      if (response.statusCode == 200) {
        // Katılım mesajı gönder
        await sendMessageToTour(
          turId: turId,
          mesaj: '$userName tura katıldı! 🎉',
          gonderenId: 'system',
          gonderenAdi: 'Sistem',
        );
        return true;
      }
    } catch (e) {
      print('Tura katılma hatası: $e');
    }
    return false;
  }

  // Kullanıcının katıldığı turları/grupları getir
  static Future<List<GrupModel>> getUserGroups(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/turlar.json'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<GrupModel> gruplar = [];

        if (responseData != null && responseData is Map) {
          responseData.forEach((turId, turData) {
            // Grup bilgisi var mı ve kullanıcı katılımcı mı kontrol et
            if (turData['grupBilgisi'] != null && 
                turData['grupBilgisi']['katilimcilar'] != null &&
                turData['grupBilgisi']['katilimcilar'][userId] == true) {
              
              // GrupModel'e çevir
              final grupBilgisi = turData['grupBilgisi'];
              List<String> katilimcilar = [];
              if (grupBilgisi['katilimcilar'] is Map) {
                katilimcilar = (grupBilgisi['katilimcilar'] as Map).keys.toList().cast<String>();
              }

              final grup = GrupModel(
                id: turId,
                turId: turId,
                turAdi: grupBilgisi['turAdi']?.toString() ?? '',
                rehberId: grupBilgisi['rehberId']?.toString() ?? '',
                rehberAdi: grupBilgisi['rehberAdi']?.toString() ?? '',
                katilimcilar: katilimcilar,
                olusturmaTarihi: grupBilgisi['olusturmaTarihi']?.toString() ?? '',
                sonMesajTarihi: grupBilgisi['sonMesajTarihi']?.toString() ?? '',
                sonMesaj: grupBilgisi['sonMesaj']?.toString(),
              );
              
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

  // Tur mesajlarını getir
  static Future<List<GrupMesajModel>> getGroupMessages(String turId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/turlar/$turId/mesajlar.json'),
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

  // Tura mesaj gönder
  static Future<bool> sendMessageToTour({
    required String turId,
    required String mesaj,
    required String gonderenId,
    required String gonderenAdi,
  }) async {
    try {
      final mesajModel = GrupMesajModel(
        id: '',
        grupId: turId,
        gonderenId: gonderenId,
        gonderenAdi: gonderenAdi,
        mesaj: mesaj,
        tarih: DateTime.now().toIso8601String(),
      );

      // Mesajı tur altına kaydet
      final response = await http.post(
        Uri.parse('$baseUrl/turlar/$turId/mesajlar.json'),
        body: json.encode(mesajModel.toMap()),
      );

      if (response.statusCode == 200) {
        // Grup bilgisinin son mesaj bilgisini güncelle
        await http.patch(
          Uri.parse('$baseUrl/turlar/$turId/grupBilgisi.json'),
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

  // Soru gönder (kullanıcı)
  static Future<bool> sendQuestion({
    required String turId,
    required String soru,
    required String kullaniciId,
    required String kullaniciAdi,
  }) async {
    try {
      final soruData = {
        'soru': soru,
        'kullaniciId': kullaniciId,
        'kullaniciAdi': kullaniciAdi,
        'tarih': DateTime.now().toIso8601String(),
        'cevaplandi': false,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/turlar/$turId/soruCevaplar/kullaniciSorulari.json'),
        body: json.encode(soruData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Soru gönderme hatası: $e');
      return false;
    }
  }

  // Soruya cevap ver (rehber)
  static Future<bool> answerQuestion({
    required String turId,
    required String soruId,
    required String cevap,
    required String rehberId,
  }) async {
    try {
      final cevapData = {
        'cevap': cevap,
        'cevapTarihi': DateTime.now().toIso8601String(),
        'cevaplandi': true,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/turlar/$turId/soruCevaplar/kullaniciSorulari/$soruId.json'),
        body: json.encode(cevapData),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Cevap gönderme hatası: $e');
      return false;
    }
  }

  // Tur sorularını getir
  static Future<List<Map<String, dynamic>>> getTourQuestions(String turId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/turlar/$turId/soruCevaplar/kullaniciSorulari.json'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<Map<String, dynamic>> sorular = [];

        if (responseData != null && responseData is Map) {
          responseData.forEach((key, value) {
            final soru = Map<String, dynamic>.from(value);
            soru['id'] = key;
            sorular.add(soru);
          });
        }

        // Tarihe göre sırala (en yeni önce)
        sorular.sort((a, b) => (b['tarih'] ?? '').compareTo(a['tarih'] ?? ''));
        return sorular;
      }
    } catch (e) {
      print('Soruları getirme hatası: $e');
    }
    return [];
  }

  // Rehberin turlarındaki cevaplanmamış soruları getir  
  static Future<List<Map<String, dynamic>>> getUnansweredQuestionsByGuide(String rehberId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/turlar.json'));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<Map<String, dynamic>> cevaplanmamisSorular = [];

        if (responseData != null && responseData is Map) {
          responseData.forEach((turId, turData) {
            // Bu rehberin turu mu kontrol et
            if (turData['grupBilgisi'] != null && 
                turData['grupBilgisi']['rehberId'] == rehberId &&
                turData['soruCevaplar'] != null &&
                turData['soruCevaplar']['kullaniciSorulari'] != null) {
              
              final sorular = turData['soruCevaplar']['kullaniciSorulari'] as Map;
              sorular.forEach((soruId, soruData) {
                if (soruData['cevaplandi'] != true) {
                  final soru = Map<String, dynamic>.from(soruData);
                  soru['id'] = soruId;
                  soru['turId'] = turId;
                  soru['turAdi'] = turData['grupBilgisi']['turAdi'] ?? 'Bilinmeyen Tur';
                  cevaplanmamisSorular.add(soru);
                }
              });
            }
          });
        }

        // Tarihe göre sırala (en yeni önce)
        cevaplanmamisSorular.sort((a, b) => (b['tarih'] ?? '').compareTo(a['tarih'] ?? ''));
        return cevaplanmamisSorular;
      }
    } catch (e) {
      print('Cevaplanmamış soruları getirme hatası: $e');
    }
    return [];
  }
} 