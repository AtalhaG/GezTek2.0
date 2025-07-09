import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_database/firebase_database.dart';
import '../l10n/app_localizations.dart';

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
  final String hakkimda;
  final List<String> uzmanlikAlanlari;
  final List<String> egitimBilgileri;
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
    required this.hakkimda,
    required this.uzmanlikAlanlari,
    required this.egitimBilgileri,
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

  // Yorum ekleme için controller'lar
  final TextEditingController _yorumController = TextEditingController();
  double _secilenPuan = 5.0;

  // In-memory image URL cache
  final Map<String, String> _imageUrlCache = {};

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
      // Sadece seçilen rehberin verisini çek
      final dbRef = FirebaseDatabase.instance.ref();
      final rehberSnapshot =
          await dbRef.child('rehberler').child(widget.rehberId).get();
      if (!rehberSnapshot.exists) {
        throw Exception('Rehber bulunamadı');
      }
      final rehberInfo = Map<String, dynamic>.from(rehberSnapshot.value as Map);

      // Konuştuğu dilleri işle
      List<String> konusulanDiller = [];
      final konusulanDillerData = rehberInfo['konusulanDiller'];
      if (konusulanDillerData is List) {
        konusulanDiller = konusulanDillerData.cast<String>();
      } else if (konusulanDillerData is String) {
        konusulanDiller = [konusulanDillerData];
      }

      // HizmetVerilenŞehirler alanını çek
      List<String> hizmetVerilenSehirler = [];
      final hizmetVerilenSehirlerData = rehberInfo['hizmetVerilenSehirler'];
      if (hizmetVerilenSehirlerData is List) {
        hizmetVerilenSehirler = hizmetVerilenSehirlerData.cast<String>();
      } else if (hizmetVerilenSehirlerData is String) {
        hizmetVerilenSehirler = [hizmetVerilenSehirlerData];
      }

      // Rehberin turlarını çek
      List<TurModel> rehberTurlari = [];
      final turlarim = rehberInfo['turlarim'];
      if (turlarim != null) {
        List<String> turIdleri = [];
        if (turlarim is List) {
          turIdleri = turlarim.cast<String>();
        } else if (turlarim is String) {
          turIdleri = [turlarim];
        }
        for (String turId in turIdleri) {
          final turSnapshot = await dbRef.child('turlar').child(turId).get();
          if (turSnapshot.exists) {
            final tur = Map<String, dynamic>.from(turSnapshot.value as Map);
            rehberTurlari.add(
              TurModel(
                id: turId,
                baslik: tur['turAdi']?.toString() ?? 'Tur',
                resim: tur['resim']?.toString() ?? '',
                sure: tur['sure']?.toString() ?? '2 saat',
                maxKisi:
                    int.tryParse(tur['maxKatilimci']?.toString() ?? '0') ?? 0,
                fiyat: double.tryParse(tur['fiyat']?.toString() ?? '0') ?? 0.0,
              ),
            );
          }
        }
      }

      // Yorumları çek (tüm yorumları çekip filtrele)
      final yorumSnapshot = await dbRef.child('yorumlar').get();
      List<DegerlendirmeModel> yorumlar = [];
      if (yorumSnapshot.exists) {
        final yorumData = Map<String, dynamic>.from(yorumSnapshot.value as Map);
        yorumlar =
            yorumData.entries
                .where((entry) => entry.value['rehberId'] == widget.rehberId)
                .map((entry) {
                  final yorum = entry.value;
                  return DegerlendirmeModel(
                    id: entry.key,
                    kullaniciAdi: 'Kullanıcı ${entry.key.substring(0, 6)}',
                    kullaniciFoto:
                        'https://picsum.photos/100?random=${entry.key.hashCode}',
                    puan: (yorum['puan'] as num).toDouble(),
                    yorum: yorum['yorum'] as String,
                    tarih: 'Şimdi',
                  );
                })
                .toList();
        yorumlar.sort((a, b) => b.tarih.compareTo(a.tarih));
      }

      // Ortalama puanı hesapla
      double ortalamaPuan = 4.5; // Varsayılan
      if (yorumlar.isNotEmpty) {
        ortalamaPuan =
            yorumlar.map((y) => y.puan).reduce((a, b) => a + b) /
            yorumlar.length;
      }

      setState(() {
        _rehber = RehberModel(
          id: widget.rehberId,
          ad: rehberInfo['isim']?.toString() ?? 'İsim',
          soyad: rehberInfo['soyisim']?.toString() ?? 'Soyisim',
          profilFoto: rehberInfo['profilfoto']?.toString() ?? '',
          puan: ortalamaPuan,
          degerlendirmeSayisi: yorumlar.length,
          konum:
              hizmetVerilenSehirler.isNotEmpty
                  ? hizmetVerilenSehirler.join(', ')
                  : 'Türkiye',
          diller: konusulanDiller,
          onayliRehber: true, // Varsayılan
          hakkimda: rehberInfo['hakkinda']?.toString() ?? 'Deneyimli rehber',
          uzmanlikAlanlari: ['Kültür Turları', 'Şehir Gezileri'], // Varsayılan
          egitimBilgileri: ['Turizm Rehberliği Sertifikası'], // Varsayılan
          telefon: rehberInfo['telefon']?.toString() ?? '',
          email: rehberInfo['email']?.toString() ?? '',
          turlar: rehberTurlari,
          degerlendirmeler: yorumlar,
          hizmetVerilenSehirler: hizmetVerilenSehirler,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Rehber bilgileri yüklenirken hata oluştu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Yorum ekleme dialog'unu göster
  void _showYorumEkleDialog() {
    if (_rehber == null) return;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);
    final primaryColor = isDark ? darkGreen : const Color(0xFF4CAF50);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
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
                                color:
                                    index < _secilenPuan
                                        ? Colors.amber
                                        : Colors.grey[300],
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
                            fillColor: Theme.of(context).cardColor,
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
                                      kullaniciAdi:
                                          'Kullanıcı ${_rehber!.degerlendirmeler.length + 1}',
                                      kullaniciFoto:
                                          'https://picsum.photos/100?random=${_rehber!.degerlendirmeler.length + 100}',
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
                                    content: Text(
                                      'Değerlendirmeniz başarıyla eklendi',
                                    ),
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
                                  content: Text(
                                    'Bir hata oluştu: ${e.toString()}',
                                  ),
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
    // Eğer cache'de varsa, direkt döndür
    if (_imageUrlCache.containsKey(path)) {
      return _imageUrlCache[path];
    }

    try {
      print('Download URL alınıyor, yol: $path');

      // Eğer path bir URL ise (picsum.photos gibi), doğrudan döndür
      if (path.startsWith('http')) {
        print('Doğrudan URL kullanılıyor: $path');
        _imageUrlCache[path] = path; // Direkt URL'yi de cache'le
        return path;
      }

      final ref = FirebaseStorage.instance.ref().child(path);
      print('Storage referansı oluşturuldu: [38;5;2m[1m${ref.fullPath}[0m');

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
      _imageUrlCache[path] = url; // Cache'e ekle
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
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
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
                value:
                    loadingProgress.expectedTotalBytes != null
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
        placeholder:
            (context, url) => Container(
              width: 100,
              height: 100,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget: (context, url, error) {
          print('Error loading image: $error for URL: $url');
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          );
        },
      );
    }
  }

  Widget _buildProfileHeader(Color primaryColor, Color textColor) {
    if (_rehber == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);

    final imagePath = _getValidImageUrl(_rehber!.profilFoto);
    print('Image path from URL: $imagePath');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.black26
                    : Colors.grey.withOpacity(0.1),
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
            backgroundColor: isDark ? darkGreen : Colors.transparent,
            child:
                imagePath.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.grey)
                    : FutureBuilder<String?>(
                      future: _getDownloadUrl(imagePath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError || !snapshot.hasData) {
                          print(
                            'Error getting download URL: ${snapshot.error}',
                          );
                          return const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          );
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
            style: TextStyle(
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '(${_rehber!.degerlendirmeSayisi} ${AppLocalizations.of(context)!.reviewsCount})',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildInfoChip(Icons.location_on, _rehber!.konum, primaryColor),
              _buildInfoChip(
                Icons.language,
                _rehber!.diller.join(', '),
                primaryColor,
              ),
              if (_rehber!.onayliRehber)
                _buildInfoChip(Icons.verified, 'Onaylı Rehber', primaryColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color primaryColor) {
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

  Widget _buildTabBar(Color primaryColor, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.black26
                    : Colors.grey.withOpacity(0.1),
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
        tabs: [
          Tab(text: l10n.about),
          Tab(text: l10n.tours),
          Tab(text: l10n.reviews),
          Tab(text: l10n.aiAssistantTab),
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

  Widget _buildAboutTab(Color primaryColor, Color textColor) {
    if (_rehber == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Rehber Hakkında', textColor),
          const SizedBox(height: 10),
          Text(
            _rehber!.hakkimda,
            style: TextStyle(fontSize: 14, color: textColor, height: 1.5),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Hizmet Verilen Şehirler', textColor),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _rehber!.hizmetVerilenSehirler
                    .map((sehir) => _buildExpertiseChip(sehir, primaryColor))
                    .toList(),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Uzmanlık Alanları', textColor),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _rehber!.uzmanlikAlanlari
                    .map((alan) => _buildExpertiseChip(alan, primaryColor))
                    .toList(),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Eğitim Bilgileri', textColor),
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
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );
  }

  Widget _buildExpertiseChip(String label, Color primaryColor) {
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

  // Helper function to localize duration (e.g., '2 gün' -> '2 days')
  String localizeDuration(String duration, AppLocalizations l10n) {
    // Simple patterns: '2 gün', '1 gün', '3 saat', '45 dakika', etc.
    final dayRegExp = RegExp(r'^(\d+)\s*gün$');
    final hourRegExp = RegExp(r'^(\d+)\s*saat$');
    final minuteRegExp = RegExp(r'^(\d+)\s*dakika$');
    final matchDay = dayRegExp.firstMatch(duration);
    final matchHour = hourRegExp.firstMatch(duration);
    final matchMinute = minuteRegExp.firstMatch(duration);

    if (matchDay != null) {
      final count = int.parse(matchDay.group(1)!);
      if (l10n.localeName == 'en') {
        return '$count ' + (count == 1 ? 'day' : 'days');
      } else {
        return '$count gün';
      }
    } else if (matchHour != null) {
      final count = int.parse(matchHour.group(1)!);
      if (l10n.localeName == 'en') {
        return '$count ' + (count == 1 ? 'hour' : 'hours');
      } else {
        return '$count saat';
      }
    } else if (matchMinute != null) {
      final count = int.parse(matchMinute.group(1)!);
      if (l10n.localeName == 'en') {
        return '$count ' + (count == 1 ? 'minute' : 'minutes');
      } else {
        return '$count dakika';
      }
    }
    // fallback: return as is
    return duration;
  }

  Widget _buildToursTab(Color primaryColor, Color textColor) {
    if (_rehber == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _rehber!.turlar.length,
      itemBuilder: (context, index) {
        final tur = _rehber!.turlar[index];
        final imagePath = _getValidImageUrl(tur.resim);
        print('Tur resmi yolu: $imagePath');

        return Card(
          color: Theme.of(context).cardColor,
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
                child:
                    imagePath.isEmpty
                        ? Container(
                          height: 150,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        )
                        : FutureBuilder<String?>(
                          future: _getDownloadUrl(imagePath),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                height: 150,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (snapshot.hasError || !snapshot.hasData) {
                              print(
                                'Error getting download URL: ${snapshot.error}',
                              );
                              return Container(
                                height: 150,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[700]
                                        : Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            }

                            return Image.network(
                              snapshot.data!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                print(
                                  'Error loading image: $error for URL: ${snapshot.data}',
                                );
                                return Container(
                                  height: 150,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[700]
                                          : Colors.grey[300],
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 150,
                                  color:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          localizeDuration(tur.sure, l10n),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          l10n.maxParticipants.replaceAll(
                            '{count}',
                            tur.maxKisi.toString(),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₺${tur.fiyat}/${l10n.perPerson}',
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
                          child: Text(l10n.viewDetails),
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

  Widget _buildReviewsTab(Color primaryColor, Color textColor) {
    final l10n = AppLocalizations.of(context)!;
    if (_rehber == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Yorum Ekle butonu
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.black26
                        : Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.rate_review, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                l10n.reviews,
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
                label: Text(l10n.addReview),
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
          child:
              _rehber!.degerlendirmeler.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(l10n.noReviews),
                        Text(l10n.beFirstToReview),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _rehber!.degerlendirmeler.length,
                    itemBuilder: (context, index) {
                      final degerlendirme = _rehber!.degerlendirmeler[index];
                      return Card(
                        color: Theme.of(context).cardColor,
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
                                    backgroundImage: NetworkImage(
                                      degerlendirme.kullaniciFoto,
                                    ),
                                    onBackgroundImageError: (_, __) {},
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            color:
                                                index <
                                                        degerlendirme.puan
                                                            .floor()
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
                                      color:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                degerlendirme.yorum,
                                style: TextStyle(
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

  Widget _buildAITab(Color primaryColor, Color textColor) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_toy, size: 64, color: primaryColor.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            l10n.aiAssistantSoon,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aiAssistantDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);
    final primaryColor = isDark ? darkGreen : const Color(0xFF4CAF50);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.loadingGuide),
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
              ? Center(child: Text(l10n.guideNotFound))
              : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildProfileHeader(
                          primaryColor,
                          textColor,
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        _buildTabBar(primaryColor, l10n),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAboutTab(primaryColor, textColor),
                    _buildToursTab(primaryColor, textColor),
                    _buildReviewsTab(primaryColor, textColor),
                    _buildAITab(primaryColor, textColor),
                  ],
                ),
              ),
      floatingActionButton:
          _rehber != null
              ? FloatingActionButton.extended(
                onPressed: () {
                  // İletişim sayfasına yönlendirme
                },
                backgroundColor: primaryColor,
                icon: const Icon(Icons.message),
                label: Text(l10n.contact),
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
    return Container(color: Theme.of(context).cardColor, child: child);
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
