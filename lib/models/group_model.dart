// Grup mesajlaşma modelleri
class GrupModel {
  final String id;
  final String turId;
  final String turAdi;
  final String rehberId;
  final String rehberAdi;
  final List<String> katilimcilar;
  final String olusturmaTarihi;
  final String sonMesajTarihi;
  final String? sonMesaj;

  GrupModel({
    required this.id,
    required this.turId,
    required this.turAdi,
    required this.rehberId,
    required this.rehberAdi,
    required this.katilimcilar,
    required this.olusturmaTarihi,
    required this.sonMesajTarihi,
    this.sonMesaj,
  });

  factory GrupModel.fromFirebase(String id, Map<String, dynamic> data) {
    List<String> katilimcilarList = [];
    if (data['katilimcilar'] != null) {
      if (data['katilimcilar'] is Map) {
        final katilimcilarMap = data['katilimcilar'] as Map<String, dynamic>;
        katilimcilarList = katilimcilarMap.keys.toList().cast<String>();
      } else if (data['katilimcilar'] is List) {
        katilimcilarList = List<String>.from(data['katilimcilar']);
      }
    }

    return GrupModel(
      id: id,
      turId: data['turId']?.toString() ?? '',
      turAdi: data['turAdi']?.toString() ?? '',
      rehberId: data['rehberId']?.toString() ?? '',
      rehberAdi: data['rehberAdi']?.toString() ?? '',
      katilimcilar: katilimcilarList,
      olusturmaTarihi: data['olusturmaTarihi']?.toString() ?? '',
      sonMesajTarihi: data['sonMesajTarihi']?.toString() ?? '',
      sonMesaj: data['sonMesaj']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, bool> katilimcilarMap = {};
    for (String katilimci in katilimcilar) {
      katilimcilarMap[katilimci] = true;
    }

    return {
      'turId': turId,
      'turAdi': turAdi,
      'rehberId': rehberId,
      'rehberAdi': rehberAdi,
      'katilimcilar': katilimcilarMap,
      'olusturmaTarihi': olusturmaTarihi,
      'sonMesajTarihi': sonMesajTarihi,
      'sonMesaj': sonMesaj,
    };
  }
}

class GrupMesajModel {
  final String id;
  final String grupId;
  final String gonderenId;
  final String gonderenAdi;
  final String mesaj;
  final String tarih;
  final String tip; // 'text', 'image', 'file'

  GrupMesajModel({
    required this.id,
    required this.grupId,
    required this.gonderenId,
    required this.gonderenAdi,
    required this.mesaj,
    required this.tarih,
    this.tip = 'text',
  });

  factory GrupMesajModel.fromFirebase(String id, Map<String, dynamic> data) {
    return GrupMesajModel(
      id: id,
      grupId: data['grupId']?.toString() ?? '',
      gonderenId: data['gonderenId']?.toString() ?? '',
      gonderenAdi: data['gonderenAdi']?.toString() ?? '',
      mesaj: data['mesaj']?.toString() ?? '',
      tarih: data['tarih']?.toString() ?? '',
      tip: data['tip']?.toString() ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'grupId': grupId,
      'gonderenId': gonderenId,
      'gonderenAdi': gonderenAdi,
      'mesaj': mesaj,
      'tarih': tarih,
      'tip': tip,
    };
  }
} 