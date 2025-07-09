import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'custom_bars.dart';
import '../l10n/app_localizations.dart';

// Rehber modeli
class RehberModel {
  final String id;
  final String isim;
  final String soyisim;
  final double puan;
  final List<String> diller;
  final List<String> calistigiSehirler;
  final List<String> aktifTarihler;
  final String email;
  final String profilFotoUrl;
  final List<String> turTipleri; // Rehberin yaptığı tur kategorileri

  RehberModel({
    required this.id,
    required this.isim,
    required this.soyisim,
    required this.puan,
    required this.diller,
    required this.calistigiSehirler,
    required this.aktifTarihler,
    required this.email,
    required this.profilFotoUrl,
    required this.turTipleri,
  });

  String get tamIsim => '$isim $soyisim';
  String get dillerText => diller.join(', ');
  String get sehirlerText => calistigiSehirler.join(', ');
  String get turTipleriText => turTipleri.join(', ');
}

class RehberSiralamaCard extends StatelessWidget {
  final RehberModel rehber;
  final VoidCallback? onTap;

  const RehberSiralamaCard({super.key, required this.rehber, this.onTap});

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
      if (!uri.host.contains('firebasestorage.googleapis.com')) {
        print('Geçersiz Firebase Storage URL: $url');
        return '';
      }

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
    } catch (e) {
      print('URL parse hatası: $e');
      return '';
    }
  }

  Future<String?> _getDownloadUrl(String path) async {
    try {
      print('Download URL alınıyor, yol: $path');
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
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading image: $error for URL: $url');
          return Container(
            width: 72,
            height: 72,
            color: Colors.grey[200],
            child: const Icon(Icons.person, size: 36, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 72,
            height: 72,
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
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        memCacheWidth: 100,
        memCacheHeight: 100,
        maxWidthDiskCache: 100,
        maxHeightDiskCache: 100,
        placeholder:
            (context, url) => Container(
              width: 72,
              height: 72,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget: (context, url, error) {
          print('Error loading image: $error for URL: $url');
          return Container(
            width: 72,
            height: 72,
            color: Colors.grey[200],
            child: const Icon(Icons.person, size: 36, color: Colors.grey),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkBg =
        isDark ? theme.scaffoldBackgroundColor : const Color(0xFFE8F6F3);
    final imagePath = _getValidImageUrl(rehber.profilFotoUrl);
    print('Image path from URL: $imagePath');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sol kısım: Bilgiler
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rehber.tamIsim,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF222222),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${AppLocalizations.of(context)!.languages}: ${rehber.dillerText}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            rehber.puan.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              rehber.calistigiSehirler.contains(
                                    AppLocalizations.of(
                                      context,
                                    )!.cityInfoNotAvailable,
                                  )
                                  ? Colors.red[50]
                                  : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                rehber.calistigiSehirler.contains(
                                      AppLocalizations.of(
                                        context,
                                      )!.cityInfoNotAvailable,
                                    )
                                    ? Colors.red[200]!
                                    : Colors.green[200]!,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color:
                                  rehber.calistigiSehirler.contains(
                                        AppLocalizations.of(
                                          context,
                                        )!.cityInfoNotAvailable,
                                      )
                                      ? Colors.red[600]
                                      : Colors.green[700],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                rehber.calistigiSehirler.contains(
                                      AppLocalizations.of(
                                        context,
                                      )!.cityInfoNotAvailable,
                                    )
                                    ? AppLocalizations.of(
                                      context,
                                    )!.cityInfoNotAvailable
                                    : '📍 ${rehber.sehirlerText}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      rehber.calistigiSehirler.contains(
                                            AppLocalizations.of(
                                              context,
                                            )!.cityInfoNotAvailable,
                                          )
                                          ? Colors.red[600]
                                          : Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Sağ kısım: Profil fotoğrafı
                const SizedBox(width: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(70),
                  ),
                  elevation: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(70),
                    child:
                        imagePath.isEmpty
                            ? Container(
                              width: 72,
                              height: 72,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.person,
                                size: 36,
                                color: Colors.grey,
                              ),
                            )
                            : FutureBuilder<String?>(
                              future: _getDownloadUrl(imagePath),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    width: 72,
                                    height: 72,
                                    color: Colors.grey[200],
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
                                    width: 72,
                                    height: 72,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.person,
                                      size: 36,
                                      color: Colors.grey,
                                    ),
                                  );
                                }

                                return _buildImageWidget(snapshot.data!);
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RehberSiralamaSayfasi extends StatefulWidget {
  const RehberSiralamaSayfasi({super.key});

  @override
  State<RehberSiralamaSayfasi> createState() => _RehberSiralamaSayfasiState();
}

class _RehberSiralamaSayfasiState extends State<RehberSiralamaSayfasi> {
  // Filtre değişkenleri
  String? seciliSehir;
  String? seciliTurTipi;
  String? seciliDil;
  double? seciliPuan;
  DateTime? seciliTarih;

  // Veri listeleri
  List<RehberModel> tumRehberler = [];
  List<RehberModel> filtrelenmisRehberler = [];
  List<String> tumSehirler = [];
  List<String> tumTurTipleri = [];
  List<String> tumDiller = [];
  final List<double> puanlar = [5.0, 4.5, 4.0, 3.5, 3.0, 2.5, 2.0, 1.5, 1.0];

  // Loading state
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _loadRehberlerVeTurlar();
      _applyFilters();
    } catch (e) {
      setState(() {
        errorMessage = 'Veriler yüklenirken hata oluştu: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadRehberlerVeTurlar() async {
    try {
      // UserProvider'dan rehberleri çek
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final rehberler = await userProvider.fetchAllGuides();

      print(
        '✅ ${AppLocalizations.of(context)!.guidesLoadedSuccess}: ${rehberler.length} ${AppLocalizations.of(context)!.guides}',
      );

      // Rehberleri RehberModel'e dönüştür
      List<RehberModel> rehberModelList = [];
      Set<String> sehirlerSet = {};
      Set<String> turTipleriSet = {};
      Set<String> dillerSet = {};

      for (var rehber in rehberler) {
        // Eğer rehberin turlarim düğümü yoksa veya boşsa, bu rehberi atla
        final turlarim = rehber.userData['turlarim'];
        if (turlarim == null ||
            (turlarim is List && turlarim.isEmpty) ||
            (turlarim is Map && turlarim.isEmpty)) {
          continue;
        }

        // Rehberin şehir bilgilerini al
        List<String> hizmetVerilenSehirler = [];
        final sehirlerData =
            rehber.userData['HizmetVerilenŞehirler'] ??
            rehber.userData['hizmetVerilenSehirler'] ??
            rehber.userData['sehirler'] ??
            rehber.userData['calistigiSehirler'];

        if (sehirlerData != null) {
          if (sehirlerData is List) {
            hizmetVerilenSehirler = sehirlerData.cast<String>();
          } else if (sehirlerData is String) {
            hizmetVerilenSehirler = [sehirlerData];
          }
        }

        if (hizmetVerilenSehirler.isEmpty) {
          hizmetVerilenSehirler = [
            AppLocalizations.of(context)!.cityInfoNotAvailable,
          ];
        }

        // Konuştuğu dilleri al
        List<String> konusulanDiller = [];
        final dillerData = rehber.userData['konusulanDiller'];
        if (dillerData is List) {
          konusulanDiller = dillerData.cast<String>();
        } else if (dillerData is String) {
          konusulanDiller = [dillerData];
        }

        // Tur kategorilerini al (şimdilik boş, sonra turlardan çekilecek)
        List<String> turTipleri = [];
        final turKategorileri =
            rehber.userData['turKategorileri'] ?? rehber.userData['turTipleri'];
        if (turKategorileri is List) {
          turTipleri = turKategorileri.cast<String>();
        } else if (turKategorileri is String) {
          turTipleri = [turKategorileri];
        }

        // Aktif tarihler (şimdilik boş)
        List<String> aktifTarihler = [];

        // Puan hesapla
        final puan = 3.0 + (rehber.id.hashCode % 21) / 10.0; // 3.0-5.0 arası

        // Dilleri ve şehirleri global listeye ekle
        dillerSet.addAll(konusulanDiller);
        sehirlerSet.addAll(hizmetVerilenSehirler);
        turTipleriSet.addAll(turTipleri);

        rehberModelList.add(
          RehberModel(
            id: rehber.id,
            isim:
                rehber.userData['isim']?.toString() ??
                AppLocalizations.of(context)!.firstName,
            soyisim:
                rehber.userData['soyisim']?.toString() ??
                AppLocalizations.of(context)!.lastName,
            puan: puan,
            diller: konusulanDiller,
            calistigiSehirler: hizmetVerilenSehirler,
            aktifTarihler: aktifTarihler,
            email: rehber.email,
            profilFotoUrl: rehber.userData['profilfoto']?.toString() ?? '',
            turTipleri: turTipleri,
          ),
        );
      }

      setState(() {
        tumRehberler = rehberModelList;
        tumSehirler = sehirlerSet.toList()..sort();
        tumTurTipleri = turTipleriSet.toList()..sort();
        tumDiller = dillerSet.toList()..sort();
      });

      print(
        '✅ Filtre listeleri güncellendi: ${tumSehirler.length} şehir, ${tumTurTipleri.length} tur tipi, ${tumDiller.length} dil',
      );
    } catch (e) {
      print('❌ ${AppLocalizations.of(context)!.guideLoadingError}: $e');
      throw Exception(
        '${AppLocalizations.of(context)!.guidesLoadingError}: $e',
      );
    }
  }

  void _applyFilters() {
    List<RehberModel> filtered = List.from(tumRehberler);

    // Şehir filtresi (HizmetVerilenŞehirler'e göre)
    if (seciliSehir != null) {
      filtered =
          filtered
              .where((rehber) => rehber.calistigiSehirler.contains(seciliSehir))
              .toList();
    }

    // Tur tipi filtresi (turlardan çekilen kategorilere göre)
    if (seciliTurTipi != null) {
      filtered =
          filtered
              .where((rehber) => rehber.turTipleri.contains(seciliTurTipi))
              .toList();
    }

    // Dil filtresi (konuşulanDiller'e göre)
    if (seciliDil != null) {
      filtered =
          filtered
              .where((rehber) => rehber.diller.contains(seciliDil))
              .toList();
    }

    // Puan filtresi (rehberden minimum puan seviyesine göre)
    if (seciliPuan != null) {
      filtered =
          filtered.where((rehber) => rehber.puan >= seciliPuan!).toList();
    }

    // Tarih filtresi (rehberin aktif olduğu tarihlere göre - turlardan çekilen bilgilere göre)
    if (seciliTarih != null) {
      filtered =
          filtered.where((rehber) {
            return rehber.aktifTarihler.any((tarihStr) {
              try {
                final parts = tarihStr.split('/');
                if (parts.length == 3) {
                  final turTarihi = DateTime(
                    int.parse(parts[2]), // yıl
                    int.parse(parts[1]), // ay
                    int.parse(parts[0]), // gün
                  );
                  // Seçilen tarih ile tur tarihi aynı mı kontrol et
                  return turTarihi.year == seciliTarih!.year &&
                      turTarihi.month == seciliTarih!.month &&
                      turTarihi.day == seciliTarih!.day;
                }
              } catch (e) {
                // Tarih parse hatası
              }
              return false;
            });
          }).toList();
    }

    // Puana göre sırala (yüksekten düşüğe)
    filtered.sort((a, b) => b.puan.compareTo(a.puan));

    setState(() {
      filtrelenmisRehberler = filtered;
    });
  }

  void _sehirFiltreAc() async {
    final sonuc = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _FiltreListModal<String>(
          title: AppLocalizations.of(context)!.cityInfoSelect,
          items: tumSehirler,
          selected: seciliSehir,
          onSelected: (val) => Navigator.of(context).pop(val),
        );
      },
    );
    if (sonuc != null) {
      setState(() {
        seciliSehir = sonuc;
      });
      _applyFilters();
    }
  }

  void _turTipiFiltreAc() async {
    final sonuc = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _FiltreListModal<String>(
          title: AppLocalizations.of(context)!.turTipiSelect,
          items: tumTurTipleri,
          selected: seciliTurTipi,
          onSelected: (val) => Navigator.of(context).pop(val),
        );
      },
    );
    if (sonuc != null) {
      setState(() {
        seciliTurTipi = sonuc;
      });
      _applyFilters();
    }
  }

  void _dilFiltreAc() async {
    final sonuc = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _FiltreListModal<String>(
          title: AppLocalizations.of(context)!.languageSelect,
          items: tumDiller,
          selected: seciliDil,
          onSelected: (val) => Navigator.of(context).pop(val),
        );
      },
    );
    if (sonuc != null) {
      setState(() {
        seciliDil = sonuc;
      });
      _applyFilters();
    }
  }

  void _puanFiltreAc() async {
    final sonuc = await showModalBottomSheet<double>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _FiltreListModal<double>(
          title: AppLocalizations.of(context)!.minimumPuanSelect,
          items: puanlar,
          selected: seciliPuan,
          itemBuilder:
              (puan) => Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text('$puan ve üzeri'),
                ],
              ),
          onSelected: (val) => Navigator.of(context).pop(val),
        );
      },
    );
    if (sonuc != null) {
      setState(() {
        seciliPuan = sonuc;
      });
      _applyFilters();
    }
  }

  void _tarihFiltreAc() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: seciliTarih ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: AppLocalizations.of(context)!.turTarihiSelect,
      confirmText: AppLocalizations.of(context)!.select,
      cancelText: AppLocalizations.of(context)!.cancel,
    );

    if (picked != null) {
      setState(() {
        seciliTarih = picked;
      });
      _applyFilters();
    }
  }

  void _filtreleriTemizle() {
    setState(() {
      seciliSehir = null;
      seciliTurTipi = null;
      seciliDil = null;
      seciliPuan = null;
      seciliTarih = null;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkBg =
        isDark ? theme.scaffoldBackgroundColor : const Color(0xFFE8F6F3);
    return Scaffold(
      backgroundColor: darkBg,
      body: Column(
        children: [
          const CustomTopBar(),
          Expanded(
            child: Column(
              children: [
                // Filtre butonları
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  child: Row(
                    children: [
                      _FiltreButton(
                        text:
                            seciliSehir != null
                                ? '${AppLocalizations.of(context)!.cityLabel}: $seciliSehir'
                                : AppLocalizations.of(context)!.cityInfo,
                        onTap: _sehirFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text:
                            seciliTarih != null
                                ? '${AppLocalizations.of(context)!.dateLabel}: ${seciliTarih!.day}.${seciliTarih!.month}.${seciliTarih!.year}'
                                : AppLocalizations.of(context)!.tarih,
                        onTap: _tarihFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text:
                            seciliTurTipi != null
                                ? '${AppLocalizations.of(context)!.tourTypeLabel}: $seciliTurTipi'
                                : AppLocalizations.of(context)!.turTipi,
                        onTap: _turTipiFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text:
                            seciliDil != null
                                ? '${AppLocalizations.of(context)!.languageLabel}: $seciliDil'
                                : AppLocalizations.of(context)!.language,
                        onTap: _dilFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text:
                            seciliPuan != null
                                ? '${AppLocalizations.of(context)!.scoreLabel}: ${seciliPuan!.toString()}+'
                                : AppLocalizations.of(context)!.puan,
                        onTap: _puanFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text: AppLocalizations.of(context)!.clear,
                        color: Colors.red[700],
                        onTap: _filtreleriTemizle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // İçerik alanı
                Expanded(
                  child:
                      isLoading
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.loadingGuides,
                                ),
                              ],
                            ),
                          )
                          : errorMessage != null
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadData,
                                  child: Text(
                                    AppLocalizations.of(context)!.tryAgain,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : filtrelenmisRehberler.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!.noGuidesFound,
                                ),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.tryChangingFilters,
                                ),
                              ],
                            ),
                          )
                          : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              itemCount: filtrelenmisRehberler.length,
                              itemBuilder: (context, index) {
                                final rehber = filtrelenmisRehberler[index];
                                return RehberSiralamaCard(
                                  rehber: rehber,
                                  onTap: () {
                                    // Rehber detay sayfasına git
                                    Navigator.pushNamed(
                                      context,
                                      '/rehber_detay',
                                      arguments: {'rehberId': rehber.id},
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 1),
    );
  }
}

class _FiltreButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  const _FiltreButton({required this.text, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? const Color(0xFF22543D),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 2,
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }
}

class _FiltreListModal<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? selected;
  final Widget Function(T)? itemBuilder;
  final void Function(T) onSelected;
  const _FiltreListModal({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.itemBuilder,
    super.key,
  });

  @override
  State<_FiltreListModal<T>> createState() => _FiltreListModalState<T>();
}

class _FiltreListModalState<T> extends State<_FiltreListModal<T>> {
  T? secili;
  @override
  void initState() {
    super.initState();
    secili = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  AppLocalizations.of(context)!.noDataAvailable,
                  style: const TextStyle(color: Colors.grey),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return RadioListTile<T>(
                      title:
                          widget.itemBuilder != null
                              ? widget.itemBuilder!(item)
                              : Text(item.toString()),
                      value: item,
                      groupValue: secili,
                      onChanged: (val) {
                        setState(() {
                          secili = val;
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(secili),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22543D),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.apply),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
