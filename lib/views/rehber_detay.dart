import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Dummy data model - Backend ekibi bu modeli kendi ihtiyaçlarına göre düzenleyebilir
class RehberModel {
  final String id;
  final String ad;
  final String soyad;
  final String profilFoto;
  final double puan;
  final int degerlendirmeSayisi;
  final String konum;
  final List<String> diller;
  final bool onayliRehber;
  final String deneyim;
  final String hakkimda;
  final List<String> uzmanlikAlanlari;
  final List<String> egitimBilgileri;
  final Map<String, String> calismaSaatleri;
  final String telefon;
  final String email;
  final List<TurModel> turlar;
  final List<DegerlendirmeModel> degerlendirmeler;
  final List<String> hizmetVerilenSehirler;

  RehberModel({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.profilFoto,
    required this.puan,
    required this.degerlendirmeSayisi,
    required this.konum,
    required this.diller,
    required this.onayliRehber,
    required this.deneyim,
    required this.hakkimda,
    required this.uzmanlikAlanlari,
    required this.egitimBilgileri,
    required this.calismaSaatleri,
    required this.telefon,
    required this.email,
    required this.turlar,
    required this.degerlendirmeler,
    required this.hizmetVerilenSehirler,
  });
}

class TurModel {
  final String id;
  final String baslik;
  final String resim;
  final String sure;
  final int maxKisi;
  final double fiyat;

  TurModel({
    required this.id,
    required this.baslik,
    required this.resim,
    required this.sure,
    required this.maxKisi,
    required this.fiyat,
  });
}

class DegerlendirmeModel {
  final String id;
  final String kullaniciAdi;
  final String kullaniciFoto;
  final double puan;
  final String yorum;
  final String tarih;

  DegerlendirmeModel({
    required this.id,
    required this.kullaniciAdi,
    required this.kullaniciFoto,
    required this.puan,
    required this.yorum,
    required this.tarih,
  });
}

// Dummy data
final dummyRehber = RehberModel(
  id: '1',
  ad: 'Ahmet',
  soyad: 'Yılmaz',
  profilFoto: 'https://picsum.photos/200', // Network resmi kullanıyoruz
  puan: 4.8,
  degerlendirmeSayisi: 128,
  konum: 'İstanbul',
  diller: ['Türkçe', 'İngilizce'],
  onayliRehber: true,
  deneyim: '10 Yıl',
  hakkimda:
      '10 yıllık deneyimli rehberimiz Ahmet Yılmaz, İstanbul\'un tarihi ve kültürel zenginliklerini keşfetmeniz için sizlere rehberlik ediyor.',
  uzmanlikAlanlari: [
    'Tarihi Turlar',
    'Kültür Turları',
    'Müze Turları',
    'Gastronomi Turları',
  ],
  egitimBilgileri: [
    'İstanbul Üniversitesi - Turizm Rehberliği Bölümü',
    'TÜRSAB Profesyonel Turist Rehberi Sertifikası',
    'UNESCO Kültürel Miras Eğitimi',
  ],
  calismaSaatleri: {
    'Pazartesi': '09:00 - 18:00',
    'Salı': '09:00 - 18:00',
    'Çarşamba': '09:00 - 18:00',
    'Perşembe': '09:00 - 18:00',
    'Cuma': '09:00 - 18:00',
    'Cumartesi': '10:00 - 16:00',
    'Pazar': 'Kapalı',
  },
  telefon: '+90 555 123 4567',
  email: 'ahmet.yilmaz@example.com',
  turlar: List.generate(
    5,
    (index) => TurModel(
      id: 'tur_$index',
      baslik: 'İstanbul Tarihi Yarımada Turu ${index + 1}',
      resim: 'https://picsum.photos/500/200?random=$index',
      sure: '3 saat',
      maxKisi: 15,
      fiyat: 250.0,
    ),
  ),
  degerlendirmeler: List.generate(
    5,
    (index) => DegerlendirmeModel(
      id: 'degerlendirme_$index',
      kullaniciAdi: 'Kullanıcı ${index + 1}',
      kullaniciFoto:
          'https://picsum.photos/100?random=${index + 100}', // Network resmi kullanıyoruz
      puan: 4.5,
      yorum: 'Harika bir tur deneyimiydi! Rehberimiz çok bilgili ve ilgiliydi.',
      tarih: '${index + 1} gün önce',
    ),
  ),
  hizmetVerilenSehirler: ['İstanbul'],
);

class RehberDetay extends StatefulWidget {
  final String rehberId; // Backend ekibi bu ID'yi kullanarak veriyi çekecek

  const RehberDetay({super.key, required this.rehberId});

  @override
  State<RehberDetay> createState() => _RehberDetayState();
}

class _RehberDetayState extends State<RehberDetay>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RehberModel? _rehber; // Nullable yapıldı
  bool _isLoading = true; // Loading state eklendi
  String? _errorMessage; // Error state eklendi

  // Tema renkleri
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF5F6F9);
  static const Color textColor = Color(0xFF2B2B2B);

  // Yorum ekleme için controller'lar
  final TextEditingController _yorumController = TextEditingController();
  double _secilenPuan = 5.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRehberData();
  }

  // Backend ekibi bu metodu kendi ihtiyaçlarına göre düzenleyebilir
  Future<void> _loadRehberData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Firebase'den rehber verilerini çek
      final rehberResponse = await http.get(
        Uri.parse('https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/rehberler.json'),
      );

      if (rehberResponse.statusCode != 200) {
        throw Exception('Rehber verisi çekilemedi');
      }

      final rehberData = json.decode(rehberResponse.body) as Map<String, dynamic>?;
      if (rehberData == null) {
        throw Exception('Rehber verisi bulunamadı');
      }

      // Belirtilen ID'ye sahip rehberi bul
      Map<String, dynamic>? rehberInfo;
      rehberData.forEach((key, value) {
        if (key == widget.rehberId) {
          rehberInfo = value as Map<String, dynamic>;
        }
      });

      if (rehberInfo == null) {
        throw Exception('Rehber bulunamadı');
      }

      // Konuştuğu dilleri işle
      List<String> konusulanDiller = [];
      final konusulanDillerData = rehberInfo!['konusulanDiller'];
      if (konusulanDillerData is List) {
        konusulanDiller = konusulanDillerData.cast<String>();
      } else if (konusulanDillerData is String) {
        konusulanDiller = [konusulanDillerData];
      }

      // HizmetVerilenŞehirler alanını çek
      List<String> hizmetVerilenSehirler = [];
      final hizmetVerilenSehirlerData = rehberInfo!['HizmetVerilenŞehirler'];
      if (hizmetVerilenSehirlerData is List) {
        hizmetVerilenSehirler = hizmetVerilenSehirlerData.cast<String>();
      } else if (hizmetVerilenSehirlerData is String) {
        hizmetVerilenSehirler = [hizmetVerilenSehirlerData];
      }

      // Rehberin turlarını çek
      List<TurModel> rehberTurlari = [];
      final turlarim = rehberInfo!['turlarim'];
      if (turlarim != null) {
        final turResponse = await http.get(
          Uri.parse('https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar.json'),
        );
        
        if (turResponse.statusCode == 200) {
          final turData = json.decode(turResponse.body) as Map<String, dynamic>?;
          if (turData != null) {
            List<String> turIdleri = [];
            if (turlarim is List) {
              turIdleri = turlarim.cast<String>();
            } else if (turlarim is String) {
              turIdleri = [turlarim];
            }

            for (String turId in turIdleri) {
              if (turData.containsKey(turId)) {
                final tur = turData[turId] as Map<String, dynamic>;
                // Tur ID'si zaten listede yoksa ekle
                if (!rehberTurlari.any((turModel) => turModel.id == turId)) {
                  rehberTurlari.add(TurModel(
                    id: turId,
                    baslik: tur['turAdi']?.toString() ?? 'Tur',
                    resim: tur['resim']?.toString() ?? '',
                    sure: tur['sure']?.toString() ?? '2 saat',
                    maxKisi: int.tryParse(tur['maxKatilimci']?.toString() ?? '0') ?? 0,
                    fiyat: double.tryParse(tur['fiyat']?.toString() ?? '0') ?? 0.0,
                  ));
                }
              }
            }
          }
        }
      }

      // Firebase'den yorumları çek
      final yorumResponse = await http.get(
        Uri.parse('https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/yorumlar.json'),
      );

      List<DegerlendirmeModel> yorumlar = [];
      if (yorumResponse.statusCode == 200) {
        final yorumData = json.decode(yorumResponse.body) as Map<String, dynamic>?;
        if (yorumData != null) {
          // Sadece bu rehbere ait yorumları filtrele
          yorumlar = yorumData.entries
              .where((entry) => entry.value['rehberId'] == widget.rehberId)
              .map((entry) {
            final yorum = entry.value;
            return DegerlendirmeModel(
              id: entry.key,
              kullaniciAdi: 'Kullanıcı ${entry.key.substring(0, 6)}',
              kullaniciFoto: 'https://picsum.photos/100?random=${entry.key.hashCode}',
              puan: (yorum['puan'] as num).toDouble(),
              yorum: yorum['yorum'] as String,
              tarih: 'Şimdi',
            );
          }).toList();

          // Yorumları tarihe göre sırala (en yeniden en eskiye)
          yorumlar.sort((a, b) => b.tarih.compareTo(a.tarih));
        }
      }

      // Ortalama puanı hesapla
      double ortalamaPuan = 4.5; // Varsayılan
      if (yorumlar.isNotEmpty) {
        ortalamaPuan = yorumlar.map((y) => y.puan).reduce((a, b) => a + b) / yorumlar.length;
      }

      // State'i güncelle
      setState(() {
        _rehber = RehberModel(
          id: widget.rehberId,
          ad: rehberInfo!['isim']?.toString() ?? 'İsim',
          soyad: rehberInfo!['soyisim']?.toString() ?? 'Soyisim',
          profilFoto: rehberInfo!['profilfoto']?.toString() ?? '',
          puan: ortalamaPuan,
          degerlendirmeSayisi: yorumlar.length,
          konum: hizmetVerilenSehirler.isNotEmpty ? hizmetVerilenSehirler.join(', ') : 'Türkiye',
          diller: konusulanDiller,
          onayliRehber: true, // Varsayılan
          deneyim: '5+ yıl deneyim', // Varsayılan
          hakkimda: rehberInfo!['hakkinda']?.toString() ?? 'Deneyimli rehber',
          uzmanlikAlanlari: ['Kültür Turları', 'Şehir Gezileri'], // Varsayılan
          egitimBilgileri: ['Turizm Rehberliği Sertifikası'], // Varsayılan
          calismaSaatleri: {
            'Pazartesi': '09:00 - 18:00',
            'Salı': '09:00 - 18:00',
            'Çarşamba': '09:00 - 18:00',
            'Perşembe': '09:00 - 18:00',
            'Cuma': '09:00 - 18:00',
            'Cumartesi': '10:00 - 16:00',
            'Pazar': 'Kapalı',
          },
          telefon: rehberInfo!['telefon']?.toString() ?? '',
          email: rehberInfo!['email']?.toString() ?? '',
          turlar: rehberTurlari,
          degerlendirmeler: yorumlar,
          hizmetVerilenSehirler: hizmetVerilenSehirler,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Rehber bilgileri yüklenirken hata oluştu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Yorum ekleme dialog'unu göster
  void _showYorumEkleDialog() {
    if (_rehber == null) return;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Değerlendirme Yap'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Puanınız',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: () {
                        setState(() {
                          _secilenPuan = index + 1.0;
                        });
                      },
                      icon: Icon(
                        Icons.star,
                        size: 32,
                        color: index < _secilenPuan ? Colors.amber : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Yorumunuz',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _yorumController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Deneyiminizi paylaşın...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _yorumController.clear();
                _secilenPuan = 5.0;
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_yorumController.text.trim().isNotEmpty) {
                  try {
                    // Create review data
                    final reviewData = {
                      'puan': _secilenPuan,
                      'yorum': _yorumController.text.trim(),
                      'tarih': DateTime.now().toIso8601String(),
                      'rehberId': widget.rehberId,
                    };

                    // Save to Firebase under 'yorumlar' node
                    final response = await http.post(
                      Uri.parse(
                        'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/yorumlar.json',
                      ),
                      body: json.encode(reviewData),
                    );

                    if (response.statusCode == 200) {
                      // Get the review ID from Firebase response
                      final responseData = json.decode(response.body);
                      final reviewId = responseData['name'];

                      // Update local state with the new review
                      if (mounted) {
                        setState(() {
                          _rehber!.degerlendirmeler.insert(
                            0,
                            DegerlendirmeModel(
                              id: reviewId,
                              kullaniciAdi: 'Kullanıcı ${_rehber!.degerlendirmeler.length + 1}',
                              kullaniciFoto: 'https://picsum.photos/100?random=${_rehber!.degerlendirmeler.length + 100}',
                              puan: _secilenPuan,
                              yorum: _yorumController.text.trim(),
                              tarih: 'Şimdi',
                            ),
                          );
                        });
                      }

                      Navigator.pop(context);
                      _yorumController.clear();
                      _secilenPuan = 5.0;

                      // Show success message
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Değerlendirmeniz başarıyla eklendi'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      throw Exception('Failed to save review');
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Bir hata oluştu: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen bir yorum yazın'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _yorumController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _getValidImageUrl(String url) {
    if (url.isEmpty) {
      print('URL boş');
      return '';
    }
    
    try {
      print('Orijinal URL: $url');
      // URL'yi parse et
      final uri = Uri.parse(url);
      print('Parse edilmiş URI: $uri');
      
      // Firebase Storage URL'sini kontrol et
      if (uri.host.contains('firebasestorage.googleapis.com')) {
        // Dosya yolunu al
        final path = uri.path.split('/o/').last;
        if (path.isEmpty) {
          print('URL\'de geçersiz yol: $url');
          return '';
        }

        // URL decode yap
        final decodedPath = Uri.decodeComponent(path);
        print('Decode edilmiş yol: $decodedPath');
        return decodedPath;
      } else if (uri.host.contains('picsum.photos')) {
        // Picsum URL'leri için doğrudan URL'yi döndür
        print('Picsum URL kullanılıyor: $url');
        return url;
      } else {
        print('Desteklenmeyen URL formatı: $url');
        return '';
      }
    } catch (e) {
      print('URL parse hatası: $e');
      return '';
    }
  }

  Future<String?> _getDownloadUrl(String path) async {
    try {
      print('Download URL alınıyor, yol: $path');
      
      // Eğer path bir URL ise (picsum.photos gibi), doğrudan döndür
      if (path.startsWith('http')) {
        print('Doğrudan URL kullanılıyor: $path');
        return path;
      }
      
      final ref = FirebaseStorage.instance.ref().child(path);
      print('Storage referansı oluşturuldu: ${ref.fullPath}');
      
      // Metadata'yı kontrol et
      try {
        final metadata = await ref.getMetadata();
        print('Dosya metadata: ${metadata.contentType}');
        print('Dosya boyutu: ${metadata.size} bytes');
        print('Dosya oluşturulma tarihi: ${metadata.timeCreated}');
      } catch (e) {
        print('Metadata alma hatası: $e');
      }
      
      final url = await ref.getDownloadURL();
      print('Download URL alındı: $url');
      return url;
    } catch (e) {
      print('Download URL alma hatası: $e');
      return null;
    }
  }

  Widget _buildImageWidget(String url) {
    if (kIsWeb) {
      return Image.network(
        url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error for URL: $url');
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.grey,
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        memCacheWidth: 200,
        memCacheHeight: 200,
        maxWidthDiskCache: 200,
        maxHeightDiskCache: 200,
        placeholder: (context, url) => Container(
          width: 100,
          height: 100,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) {
          print('Error loading image: $error for URL: $url');
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.grey,
            ),
          );
        },
      );
    }
  }

  Widget _buildProfileHeader() {
    if (_rehber == null) return const SizedBox.shrink();
    
    final imagePath = _getValidImageUrl(_rehber!.profilFoto);
    print('Image path from URL: $imagePath');
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            child: imagePath.isEmpty
                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                : FutureBuilder<String?>(
                    future: _getDownloadUrl(imagePath),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        print('Error getting download URL: ${snapshot.error}');
                        return const Icon(Icons.person, size: 40, color: Colors.grey);
                      }

                      return ClipOval(
                        child: _buildImageWidget(snapshot.data!),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 15),
          Text(
            '${_rehber!.ad} ${_rehber!.soyad}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 5),
              Text(
                _rehber!.puan.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '(${_rehber!.degerlendirmeSayisi} değerlendirme)',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildInfoChip(Icons.location_on, _rehber!.konum),
              _buildInfoChip(Icons.language, _rehber!.diller.join(', ')),
              if (_rehber!.onayliRehber)
                _buildInfoChip(Icons.verified, 'Onaylı Rehber'),
              _buildInfoChip(Icons.work_history, _rehber!.deneyim),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryColor,
        tabs: const [
          Tab(text: 'Hakkında'),
          Tab(text: 'Turlar'),
          Tab(text: 'Değerlendirmeler'),
          Tab(text: 'AI Asistan'),
        ],
      ),
    );
  }

  // Bugünün gününü Türkçe olarak döndüren yardımcı metod
  String _getTodayInTurkish() {
    final now = DateTime.now();
    final days = {
      1: 'Pazartesi',
      2: 'Salı',
      3: 'Çarşamba',
      4: 'Perşembe',
      5: 'Cuma',
      6: 'Cumartesi',
      7: 'Pazar',
    };
    return days[now.weekday] ?? '';
  }

  Widget _buildAboutTab() {
    if (_rehber == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Rehber Hakkında'),
          const SizedBox(height: 10),
          Text(
            _rehber!.hakkimda,
            style: const TextStyle(fontSize: 14, color: textColor, height: 1.5),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Hizmet Verilen Şehirler'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _rehber!.hizmetVerilenSehirler
                .map((sehir) => _buildExpertiseChip(sehir))
                .toList(),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Uzmanlık Alanları'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _rehber!.uzmanlikAlanlari
                .map((alan) => _buildExpertiseChip(alan))
                .toList(),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Eğitim Bilgileri'),
          const SizedBox(height: 10),
          ..._rehber!.egitimBilgileri.map(
            (egitim) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.school, size: 20, color: primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      egitim,
                      style: const TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Çalışma Saatleri'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: _rehber!.calismaSaatleri.entries.map((entry) {
                final isToday = entry.key == _getTodayInTurkish();
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    color: isToday ? primaryColor.withOpacity(0.1) : null,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? primaryColor : textColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: entry.value == 'Kapalı' ? Colors.red : textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildExpertiseChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildToursTab() {
    if (_rehber == null) return const SizedBox.shrink();
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _rehber!.turlar.length,
      itemBuilder: (context, index) {
        final tur = _rehber!.turlar[index];
        final imagePath = _getValidImageUrl(tur.resim);
        print('Tur resmi yolu: $imagePath');
        
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: imagePath.isEmpty
                    ? Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50, color: Colors.grey),
                      )
                    : FutureBuilder<String?>(
                        future: _getDownloadUrl(imagePath),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (snapshot.hasError || !snapshot.hasData) {
                            print('Error getting download URL: ${snapshot.error}');
                            return Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50, color: Colors.grey),
                            );
                          }

                          return Image.network(
                            snapshot.data!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error for URL: ${snapshot.data}');
                              return Container(
                                height: 150,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 50, color: Colors.grey),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 150,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tur.baslik,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          tur.sure,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          'Max ${tur.maxKisi} kişi',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₺${tur.fiyat}/kişi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/tur_detay',
                              arguments: {'turId': tur.id},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Detaylar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    if (_rehber == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        // Yorum Ekle butonu
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.rate_review, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Değerlendirmeler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showYorumEkleDialog,
                icon: const Icon(Icons.add),
                label: const Text('Yorum Ekle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Değerlendirmeler listesi
        Expanded(
          child: _rehber!.degerlendirmeler.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rate_review, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Henüz değerlendirme yok'),
                      Text('İlk değerlendirmeyi siz yapın!'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _rehber!.degerlendirmeler.length,
                  itemBuilder: (context, index) {
                    final degerlendirme = _rehber!.degerlendirmeler[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(degerlendirme.kullaniciFoto),
                                  onBackgroundImageError: (_, __) {},
                                  child: const Icon(Icons.person, color: Colors.grey),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      degerlendirme.kullaniciAdi,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          Icons.star,
                                          size: 16,
                                          color: index < degerlendirme.puan.floor()
                                              ? Colors.amber
                                              : Colors.grey[300],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  degerlendirme.tarih,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              degerlendirme.yorum,
                              style: const TextStyle(
                                fontSize: 14,
                                color: textColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAITab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_toy, size: 64, color: primaryColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'AI Asistan Yakında',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rehberinizle ilgili sorularınızı AI asistanımıza sorabileceksiniz.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Rehber bilgileri yükleniyor...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRehberData,
                        child: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : _rehber == null
                  ? const Center(child: Text('Rehber bulunamadı'))
                  : NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            expandedHeight: 300,
                            pinned: true,
                            flexibleSpace: FlexibleSpaceBar(
                              background: _buildProfileHeader(),
                            ),
                          ),
                          SliverPersistentHeader(
                            delegate: _SliverAppBarDelegate(_buildTabBar()),
                            pinned: true,
                          ),
                        ];
                      },
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildAboutTab(),
                          _buildToursTab(),
                          _buildReviewsTab(),
                          _buildAITab(),
                        ],
                      ),
                    ),
      floatingActionButton: _rehber != null
          ? FloatingActionButton.extended(
              onPressed: () {
                // İletişim sayfasına yönlendirme
              },
              backgroundColor: primaryColor,
              icon: const Icon(Icons.message),
              label: const Text('İletişime Geç'),
            )
          : null,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: child);
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
