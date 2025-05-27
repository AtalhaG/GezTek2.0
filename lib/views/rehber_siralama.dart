import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_bars.dart';

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

  const RehberSiralamaCard({
    super.key,
    required this.rehber,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Diller: ${rehber.dillerText}',
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: rehber.calistigiSehirler.contains('Şehir bilgisi mevcut değil')
                              ? Colors.red[50]
                              : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: rehber.calistigiSehirler.contains('Şehir bilgisi mevcut değil')
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
                              color: rehber.calistigiSehirler.contains('Şehir bilgisi mevcut değil')
                                  ? Colors.red[600]
                                  : Colors.green[700],
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                rehber.calistigiSehirler.contains('Şehir bilgisi mevcut değil')
                                    ? 'Şehir bilgisi mevcut değil'
                                    : '📍 ${rehber.sehirlerText}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: rehber.calistigiSehirler.contains('Şehir bilgisi mevcut değil')
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
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: rehber.profilFotoUrl.isNotEmpty
                        ? NetworkImage(rehber.profilFotoUrl)
                        : const AssetImage('assets/images/geztek.jpg') as ImageProvider,
                    onBackgroundImageError: (_, __) {},
                    child: rehber.profilFotoUrl.isEmpty
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
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
    // Rehberleri çek
    final rehberResponse = await http.get(
      Uri.parse('https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/rehberler.json'),
    );

    // Turları çek
    final turResponse = await http.get(
      Uri.parse('https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar.json'),
    );

    if (rehberResponse.statusCode != 200 || turResponse.statusCode != 200) {
      throw Exception('Veri çekme hatası');
    }

    final rehberData = json.decode(rehberResponse.body) as Map<String, dynamic>?;
    final turData = json.decode(turResponse.body) as Map<String, dynamic>?;

    if (rehberData == null) {
      throw Exception('Rehber verisi bulunamadı');
    }

    // Tur verilerini işle
    Map<String, List<Map<String, dynamic>>> rehberTurlari = {};
    Set<String> sehirlerSet = {};
    Set<String> turTipleriSet = {};
    Set<String> dillerSet = {};

    if (turData != null) {
      turData.forEach((turId, turInfo) {
        final tur = turInfo as Map<String, dynamic>;
        final sehir = tur['sehir']?.toString();
        final kategori = tur['Kategoriler']?.toString() ?? tur['kategori']?.toString();
        final dil = tur['dil']?.toString();
        final tarih = tur['tarih']?.toString();

        if (sehir != null) sehirlerSet.add(sehir);
        if (kategori != null) {
          turTipleriSet.add(kategori);
        }
        if (dil != null) dillerSet.add(dil);

        // Rehber ID'sini bul (turlarim alanından)
        rehberData.forEach((rehberId, rehberInfo) {
          final rehber = rehberInfo as Map<String, dynamic>;
          final turlarim = rehber['turlarim'];
          
          bool rehberinTuru = false;
          if (turlarim is List) {
            rehberinTuru = turlarim.contains(turId);
          } else if (turlarim is String) {
            rehberinTuru = turlarim == turId;
          }

          if (rehberinTuru) {
            if (!rehberTurlari.containsKey(rehberId)) {
              rehberTurlari[rehberId] = [];
            }
            rehberTurlari[rehberId]!.add({
              'sehir': sehir,
              'kategori': kategori,
              'dil': dil,
              'tarih': tarih,
            });
          }
        });
      });
    }

    // Rehberleri işle
    List<RehberModel> rehberler = [];
    rehberData.forEach((rehberId, rehberInfo) {
      final rehber = rehberInfo as Map<String, dynamic>;
      
      // Rehberin HizmetVerilenŞehirler alanından şehir bilgilerini al
      List<String> hizmetVerilenSehirler = [];
      
      // Firebase'deki farklı alan adı olasılıklarını kontrol et
      final hizmetVerilenSehirlerData = rehber['HizmetVerilenŞehirler'] ?? 
                                        rehber['hizmetVerilenSehirler'] ?? 
                                        rehber['HizmetVerilenSehirler'] ??
                                        rehber['sehirler'] ??
                                        rehber['calistigiSehirler'];
      
      if (hizmetVerilenSehirlerData != null) {
        if (hizmetVerilenSehirlerData is List) {
          hizmetVerilenSehirler = hizmetVerilenSehirlerData.cast<String>();
        } else if (hizmetVerilenSehirlerData is String) {
          hizmetVerilenSehirler = [hizmetVerilenSehirlerData];
        }
      }
      
      // Eğer hala boşsa, varsayılan değer ata
      if (hizmetVerilenSehirler.isEmpty) {
        hizmetVerilenSehirler = ['Şehir bilgisi mevcut değil'];
      }

      // Rehberin turlarından kategori bilgilerini al
      final rehberinTurlari = rehberTurlari[rehberId] ?? [];
      final yaptigiTurTipleri = rehberinTurlari
          .map((tur) => tur['kategori']?.toString())
          .where((kategori) => kategori != null)
          .cast<String>()
          .toSet()
          .toList();
      
      final aktifTarihler = rehberinTurlari
          .map((tur) => tur['tarih']?.toString())
          .where((tarih) => tarih != null)
          .cast<String>()
          .toSet()
          .toList();

      // Konuştuğu dilleri işle
      List<String> konusulanDiller = [];
      final konusulanDillerData = rehber['konusulanDiller'];
      if (konusulanDillerData is List) {
        konusulanDiller = konusulanDillerData.cast<String>();
      } else if (konusulanDillerData is String) {
        konusulanDiller = [konusulanDillerData];
      }

      // Dilleri global listeye ekle
      dillerSet.addAll(konusulanDiller);
      
      // Hizmet verilen şehirleri global listeye ekle
      sehirlerSet.addAll(hizmetVerilenSehirler);

      // Puan hesapla (şimdilik rastgele, gerçek uygulamada yorumlardan hesaplanacak)
      final puan = 3.0 + (rehberId.hashCode % 21) / 10.0; // 3.0-5.0 arası

      rehberler.add(RehberModel(
        id: rehberId,
        isim: rehber['isim']?.toString() ?? 'İsim',
        soyisim: rehber['soyisim']?.toString() ?? 'Soyisim',
        puan: puan,
        diller: konusulanDiller,
        calistigiSehirler: hizmetVerilenSehirler,
        aktifTarihler: aktifTarihler,
        email: rehber['email']?.toString() ?? '',
        profilFotoUrl: rehber['profilFotoUrl']?.toString() ?? '',
        turTipleri: yaptigiTurTipleri,
      ));
    });

    setState(() {
      tumRehberler = rehberler;
      tumSehirler = sehirlerSet.toList()..sort();
      tumTurTipleri = turTipleriSet.toList()..sort();
      tumDiller = dillerSet.toList()..sort();
    });
  }

  void _applyFilters() {
    List<RehberModel> filtered = List.from(tumRehberler);

    // Şehir filtresi (HizmetVerilenŞehirler'e göre)
    if (seciliSehir != null) {
      filtered = filtered.where((rehber) => 
        rehber.calistigiSehirler.contains(seciliSehir)).toList();
    }

    // Tur tipi filtresi (turlardan çekilen kategorilere göre)
    if (seciliTurTipi != null) {
      filtered = filtered.where((rehber) => 
        rehber.turTipleri.contains(seciliTurTipi)).toList();
    }

    // Dil filtresi (konuşulanDiller'e göre)
    if (seciliDil != null) {
      filtered = filtered.where((rehber) => 
        rehber.diller.contains(seciliDil)).toList();
    }

    // Puan filtresi (rehberden minimum puan seviyesine göre)
    if (seciliPuan != null) {
      filtered = filtered.where((rehber) => 
        rehber.puan >= seciliPuan!).toList();
    }

    // Tarih filtresi (rehberin aktif olduğu tarihlere göre - turlardan çekilen bilgilere göre)
    if (seciliTarih != null) {
      filtered = filtered.where((rehber) {
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
          title: 'Hizmet Verilen Şehir Seçiniz',
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
          title: 'Tur Tipi Seçiniz',
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
          title: 'Dil Seçiniz',
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
          title: 'Minimum Puan Seçiniz',
          items: puanlar,
          selected: seciliPuan,
          itemBuilder: (puan) => Row(
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
      helpText: 'Tur Tarihi Seçin',
      confirmText: 'Seç',
      cancelText: 'İptal',
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
    return Scaffold(
      backgroundColor: const Color(0xFFE8F6F3),
      body: Column(
        children: [
          const CustomTopBar(),
          Expanded(
            child: Column(
              children: [
                // Filtre butonları
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  child: Row(
                    children: [
                      _FiltreButton(
                        text: seciliSehir != null ? 'Şehir: $seciliSehir' : 'Şehir',
                        onTap: _sehirFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text: seciliTarih != null
                            ? 'Tarih: ${seciliTarih!.day}.${seciliTarih!.month}.${seciliTarih!.year}'
                            : 'Tarih',
                        onTap: _tarihFiltreAc,
                      ),
                        const SizedBox(width: 8),
                        _FiltreButton(
                          text: seciliTurTipi != null ? 'Tur Tipi: $seciliTurTipi' : 'Tur Tipi',
                          onTap: _turTipiFiltreAc,
                        ),
                        const SizedBox(width: 8),
                        _FiltreButton(
                          text: seciliDil != null ? 'Dil: $seciliDil' : 'Dil',
                          onTap: _dilFiltreAc,
                        ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text: seciliPuan != null ? 'Puan: ${seciliPuan!.toString()}+' : 'Puan',
                        onTap: _puanFiltreAc,
                      ),
                      const SizedBox(width: 8),
                      _FiltreButton(
                        text: 'Temizle',
                        color: Colors.red[700],
                        onTap: _filtreleriTemizle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // İçerik alanı
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Rehberler yükleniyor...'),
                            ],
                          ),
                        )
                      : errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error, size: 64, color: Colors.red),
                                  const SizedBox(height: 16),
                                  Text(errorMessage!, textAlign: TextAlign.center),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadData,
                                    child: const Text('Tekrar Dene'),
                                  ),
                                ],
                              ),
                            )
                          : filtrelenmisRehberler.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text('Filtrelere uygun rehber bulunamadı'),
                                      Text('Filtreleri değiştirmeyi deneyin'),
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
  const _FiltreButton({
    required this.text,
    required this.onTap,
    this.color,
  });

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
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Henüz veri bulunmuyor',
                  style: TextStyle(color: Colors.grey),
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
                      title: widget.itemBuilder != null
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
                  child: const Text('İptal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(secili),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22543D),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Uygula'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


