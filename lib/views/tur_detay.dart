import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../controllers/group_service.dart';
import '../providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

// Soru-Cevap modeli
class SoruCevapModel {
  final String id;
  final String turId;
  final String soru;
  final String kullaniciAdi;
  final String kullaniciId;
  final String tarih;
  final String? cevap;
  final String? cevapTarihi;
  final String rehberId;

  SoruCevapModel({
    required this.id,
    required this.turId,
    required this.soru,
    required this.kullaniciAdi,
    required this.kullaniciId,
    required this.tarih,
    this.cevap,
    this.cevapTarihi,
    required this.rehberId,
  });

  factory SoruCevapModel.fromFirebase(String id, Map<String, dynamic> data) {
    return SoruCevapModel(
      id: id,
      turId: data['turId']?.toString() ?? '',
      soru: data['soru']?.toString() ?? '',
      kullaniciAdi: data['kullaniciAdi']?.toString() ?? 'Anonim',
      kullaniciId: data['kullaniciId']?.toString() ?? '',
      tarih: data['tarih']?.toString() ?? '',
      cevap: data['cevap']?.toString(),
      cevapTarihi: data['cevapTarihi']?.toString(),
      rehberId: data['rehberId']?.toString() ?? '',
    );
  }
}

// Tur modeli - Firebase Realtime Database yapısına uygun
class TurDetayModel {
  final String id;
  final String turAdi;
  final String sehir;
  final String bulusmaKonumu;
  final String dil;
  final String fiyat;
  final String kategori;
  final String maxKatilimci;
  final String olusturmaTarihi;
  final String tarih;
  final String sure;
  final String resim;
  final List<String> rotalar;

  TurDetayModel({
    required this.id,
    required this.turAdi,
    required this.sehir,
    required this.bulusmaKonumu,
    required this.dil,
    required this.fiyat,
    required this.kategori,
    required this.maxKatilimci,
    required this.olusturmaTarihi,
    required this.tarih,
    required this.sure,
    required this.resim,
    required this.rotalar,
  });

  // Firebase'den gelen veriyi model'e çeviren factory constructor
  factory TurDetayModel.fromFirebase(String id, Map<String, dynamic> data) {
    // Rotalar listesini işle - Firebase'dek
    List<String> rotalarList = [];
    if (data['rotalar'] != null) {
      if (data['rotalar'] is Map) {
        // Firebase'de rotalar Map<String, dynamic> olarak saklanıyor
        final rotalarMap = data['rotalar'] as Map<String, dynamic>;
        rotalarList = rotalarMap.values.map((e) => e.toString()).toList();
      } else if (data['rotalar'] is List) {
        rotalarList = List<String>.from(data['rotalar']);
      } else if (data['rotalar'] is String) {
        rotalarList = [data['rotalar']];
      }
    }

    return TurDetayModel(
      id: id,
      turAdi: data['turAdi']?.toString() ?? 'Tur adı belirtilmemiş',
      sehir: data['sehir']?.toString() ?? 'Şehir belirtilmemiş',
      bulusmaKonumu: data['bulusmaKonumu']?.toString() ?? 'Konum belirtilmemiş',
      dil: data['dil']?.toString() ?? 'Dil belirtilmemiş',
      fiyat: data['fiyat']?.toString() ?? '0',
      kategori: data['kategori']?.toString() ?? 'Kategori belirtilmemiş',
      maxKatilimci: data['maxKatilimci']?.toString() ?? '0',
      olusturmaTarihi: data['olusturmaTarihi']?.toString() ?? '',
      tarih: data['tarih']?.toString() ?? 'Tarih belirtilmemiş',
      sure: data['sure']?.toString() ?? 'Süre belirtilmemiş',
      resim: data['resim']?.toString() ?? '',
      rotalar: rotalarList,
    );
  }
}

class TurDetay extends StatefulWidget {
  final String? turId;

  const TurDetay({super.key, this.turId});

  @override
  State<TurDetay> createState() => _TurDetayState();
}

class _TurDetayState extends State<TurDetay> {
  TurDetayModel? _tur;
  bool _isLoading = true;
  String _errorMessage = '';
  List<SoruCevapModel> _sorular = [];
  bool _isLoadingSorular = false;
  final TextEditingController _soruController = TextEditingController();

  // Tema renkleri
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF5F6F9);
  static const Color textColor = Color(0xFF2B2B2B);

  @override
  void initState() {
    super.initState();
    _loadTurData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Route arguments'tan tur ID'sini al
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['turId'] != null) {
      final turId = args['turId'] as String;
      if (widget.turId != turId) {
        _loadTurDataWithId(turId);
      }
    }
  }

  @override
  void dispose() {
    _soruController.dispose();
    super.dispose();
  }

  Future<void> _loadTurDataWithId(String turId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('Firebase\'den tur verisi çekiliyor: $turId');

      final response = await http.get(
        Uri.parse(
          'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar/$turId.json',
        ),
      );

      print('Firebase response status: ${response.statusCode}');
      print('Firebase response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;

        if (responseBody == 'null' || responseBody.isEmpty) {
          setState(() {
            _errorMessage = 'Tur bulunamadı';
            _isLoading = false;
          });
          return;
        }

        final Map<String, dynamic> turData = json.decode(responseBody);

        setState(() {
          _tur = TurDetayModel.fromFirebase(turId, turData);
          _isLoading = false;
        });

        print('Tur verisi başarıyla yüklendi: ${_tur!.turAdi}');

        // Tur verisi yüklendikten sonra soruları da yükle
        _loadSorular();
      } else {
        setState(() {
          _errorMessage = 'Veri çekilemedi (HTTP ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Veri yükleme hatası: $e');
      setState(() {
        _errorMessage = 'Veri yüklenirken hata oluştu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTurData() async {
    if (widget.turId == null || widget.turId!.isEmpty) {
      setState(() {
        _errorMessage = 'Tur ID\'si belirtilmemiş';
        _isLoading = false;
      });
      return;
    }

    await _loadTurDataWithId(widget.turId!);
  }

  // Soruları Firebase'den yükle
  Future<void> _loadSorular() async {
    if (_tur == null) return;

    setState(() {
      _isLoadingSorular = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/soru_cevaplar.json',
        ),
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;

        if (responseBody != 'null' && responseBody.isNotEmpty) {
          final Map<String, dynamic> soruData = json.decode(responseBody);

          List<SoruCevapModel> sorular = [];
          soruData.forEach((key, value) {
            if (value['turId'] == _tur!.id) {
              sorular.add(SoruCevapModel.fromFirebase(key, value));
            }
          });

          // Soruları tarihe göre sırala (en yeni önce)
          sorular.sort((a, b) => b.tarih.compareTo(a.tarih));

          setState(() {
            _sorular = sorular;
            _isLoadingSorular = false;
          });
        } else {
          setState(() {
            _sorular = [];
            _isLoadingSorular = false;
          });
        }
      }
    } catch (e) {
      print('Sorular yüklenirken hata: $e');
      setState(() {
        _isLoadingSorular = false;
      });
    }
  }

  // Yeni soru gönder
  Future<void> _soruGonder() async {
    if (_soruController.text.trim().isEmpty || _tur == null) return;

    try {
      final soruData = {
        'turId': _tur!.id,
        'soru': _soruController.text.trim(),
        'kullaniciAdi':
            'Kullanıcı ${DateTime.now().millisecondsSinceEpoch}', // Geçici
        'kullaniciId':
            'user_${DateTime.now().millisecondsSinceEpoch}', // Geçici
        'tarih': DateTime.now().toIso8601String(),
        'rehberId': 'rehber_temp', // Bu normalde turdan alınmalı
      };

      final response = await http.post(
        Uri.parse(
          'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/soru_cevaplar.json',
        ),
        body: json.encode(soruData),
      );

      if (response.statusCode == 200) {
        _soruController.clear();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sorunuz gönderildi! Rehber size kısa sürede cevap verecektir.',
            ),
            backgroundColor: primaryColor,
          ),
        );
        // Soruları yeniden yükle
        _loadSorular();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Soru gönderilirken hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Tur Detayı'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor),
              SizedBox(height: 16),
              Text('Tur bilgileri yükleniyor...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Tur Detayı'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTurData,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                child: const Text(
                  'Tekrar Dene',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_tur == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Tur Detayı'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Tur bilgisi bulunamadı')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar ve Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _tur!.turAdi,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_tur!.resim.isNotEmpty) {
                    _showFullScreenImage(_tur!.resim);
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Arkaplan rengi
                    Container(
                      color: Colors.black,
                    ),
                    if (_tur!.resim.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: _tur!.resim,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: primaryColor.withOpacity(0.3),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                primaryColor.withOpacity(0.8),
                                primaryColor,
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 60),
                              Icon(
                                Icons.tour,
                                size: 80,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [primaryColor.withOpacity(0.8), primaryColor],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            Icon(
                              Icons.tour,
                              size: 80,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ],
                        ),
                      ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    // Şehir ve fiyat bilgisi
                    Positioned(
                      bottom: 50,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tur!.sehir,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_tur!.fiyat}₺ • ${_tur!.sure}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black45,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              IconButton(icon: const Icon(Icons.share), onPressed: () {}),
            ],
          ),

          // İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tur Bilgileri Kartı
                  _buildTurBilgileriCard(),
                  const SizedBox(height: 16),

                  // Rotalar Kartı
                  if (_tur!.rotalar.isNotEmpty) _buildRotalarCard(),
                  if (_tur!.rotalar.isNotEmpty) const SizedBox(height: 16),

                  // Soru & Cevap Kartı
                  _buildSoruCevapCard(),

                  const SizedBox(height: 100), // Bottom button için boşluk
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildSoruCevapCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.quiz, color: primaryColor, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Soru & Cevap',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showSoruSorDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Soru Sor', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoadingSorular)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_sorular.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.help_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Henüz soru sorulmamış',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bu tur hakkında ilk soruyu siz sorun!',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    _sorular.length > 3
                        ? 3
                        : _sorular.length, // İlk 3 soruyu göster
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final soru = _sorular[index];
                  return _buildSoruWidget(soru);
                },
              ),

            if (_sorular.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton(
                  onPressed: () {
                    _showTumSorularDialog();
                  },
                  child: Text(
                    'Tüm soruları gör (${_sorular.length})',
                    style: const TextStyle(color: primaryColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoruWidget(SoruCevapModel soru) {
    final bool cevaplandi = soru.cevap != null && soru.cevap!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cevaplandi ? primaryColor.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              cevaplandi
                  ? primaryColor.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soru kısmı
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.person, size: 16, color: primaryColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      soru.kullaniciAdi,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      soru.soru,
                      style: const TextStyle(fontSize: 14, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTarih(soru.tarih),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cevaplandi ? primaryColor : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  cevaplandi ? 'Cevaplandı' : 'Bekliyor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Cevap kısmı
          if (cevaplandi) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.support_agent, size: 16, color: primaryColor),
                      const SizedBox(width: 6),
                      const Text(
                        'Rehber Cevabı',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    soru.cevap!,
                    style: const TextStyle(fontSize: 14, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  if (soru.cevapTarihi != null)
                    Text(
                      _formatTarih(soru.cevapTarihi!),
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTarih(String tarih) {
    try {
      final date = DateTime.parse(tarih);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} gün önce';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} saat önce';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} dakika önce';
      } else {
        return 'Şimdi';
      }
    } catch (e) {
      return tarih;
    }
  }

  void _showSoruSorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.quiz, color: primaryColor),
              const SizedBox(width: 8),
              const Text('Soru Sor'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bu tur hakkında rehbere sormak istediğiniz soruyu yazın:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _soruController,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Örn: Bu turda öğle yemeği dahil mi?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _soruController.clear();
                Navigator.pop(context);
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: _soruGonder,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Gönder'),
            ),
          ],
        );
      },
    );
  }

  void _showTumSorularDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.quiz, color: primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Tüm Sorular',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _sorular.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildSoruWidget(_sorular[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSoruSorDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Yeni Soru Sor'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTurBilgileriCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: primaryColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Tur Bilgileri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bilgi satırları
            _buildInfoRow(Icons.calendar_today, 'Tarih', _tur!.tarih),
            _buildInfoRow(Icons.access_time, 'Süre', _tur!.sure),
            _buildInfoRow(
              Icons.location_on,
              'Buluşma Konumu',
              _tur!.bulusmaKonumu,
            ),
            _buildInfoRow(Icons.attach_money, 'Fiyat', '${_tur!.fiyat} ₺'),
            _buildInfoRow(
              Icons.group,
              'Maksimum Katılımcı',
              '${_tur!.maxKatilimci} kişi',
            ),
            _buildInfoRow(Icons.category, 'Kategori', _tur!.kategori),
            _buildInfoRow(Icons.language, 'Tur Dili', _tur!.dil),
            _buildInfoRow(Icons.location_city, 'Şehir', _tur!.sehir),
          ],
        ),
      ),
    );
  }

  Widget _buildRotalarCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.route, color: primaryColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Tur Rotaları',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rotalar listesi
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tur!.rotalar.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _tur!.rotalar[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ),
                      Icon(Icons.location_on, color: primaryColor, size: 20),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final isLocation = label == 'Buluşma Konumu';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child:
                isLocation
                    ? GestureDetector(
                      onTap: () => _openMapWithAddress(value),
                      child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              Colors
                                  .blue, // Tıklanabilir olduğunu belli etmek için
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    )
                    : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapWithAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Hata mesajı göster
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harita açılamadı')));
    }
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fiyat',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    '${_tur!.fiyat} ₺',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  _showKatilDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tura Katıl',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKatilDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    // Giriş yapmamış kullanıcı kontrolü
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tura katılmak için önce giriş yapmanız gerekiyor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Rehber kendi turuna katılamaz kontrolü
    if (currentUser.isGuide) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rehber olarak kendi turlarınıza katılamazsınız'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.tour, color: primaryColor),
              const SizedBox(width: 8),
              const Text('Tura Katıl'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba ${currentUser.fullName}!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_tur!.turAdi} turuna katılmak istediğinizden emin misiniz?',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('📅 Tarih:', _tur!.tarih),
                    _buildDetailRow('⏰ Süre:', _tur!.sure),
                    _buildDetailRow('📍 Buluşma:', _tur!.bulusmaKonumu),
                    _buildDetailRow('🌍 Dil:', _tur!.dil),
                    const Divider(color: primaryColor),
                    _buildDetailRow(
                      '💰 Ödeme:',
                      '${_tur!.fiyat} ₺',
                      isPrice: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Katıldıktan sonra tur mesaj grubuna ekleneceksiniz',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _processPaymentAndJoinTour(currentUser);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.payment, size: 16, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    '${_tur!.fiyat} ₺ Öde & Katıl',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
              color: isPrice ? primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPaymentAndJoinTour(currentUser) async {
    // 1. Ödeme işlemi (simülasyon)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 16),
                const Text('Ödeme işleniyor...'),
                const SizedBox(height: 8),
                Text(
                  '${_tur!.fiyat} ₺',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
    );

    // Ödeme simülasyonu (2 saniye bekleme)
    await Future.delayed(const Duration(seconds: 2));

    // Loading dialog'u kapat
    Navigator.pop(context);

    // 2. Ödeme başarılı - Gruba katıl
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: primaryColor),
                SizedBox(height: 16),
                Text('Grup mesajlarına ekleniyor...'),
              ],
            ),
          ),
    );

    // 3. Tura katıl ve gruba ekle
    bool success = await GroupService.joinTourAndGroup(
      turId: _tur!.id,
      turAdi: _tur!.turAdi,
      userId: currentUser.id,
      userName: currentUser.fullName,
    );

    // Loading dialog'u kapat
    Navigator.pop(context);

    // 4. Sonuç mesajı
    if (success) {
      // anlikKatilimci'yi arttır
      if (_tur != null && _tur!.id.isNotEmpty) {
        try {
          final turId = _tur!.id;
          // Önce mevcut değeri çek
          final getResp = await http.get(Uri.parse('https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar/$turId/anlikKatilimci.json'));
          int mevcutKatilimci = 0;
          if (getResp.statusCode == 200 && getResp.body != 'null') {
            mevcutKatilimci = int.tryParse(getResp.body.replaceAll('"', '')) ?? 0;
          }
          final yeniKatilimci = mevcutKatilimci + 1;
          await http.patch(
            Uri.parse('https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar/$turId.json'),
            body: json.encode({'anlikKatilimci': yeniKatilimci}),
          );

          // Katılımcı ismini ekle
          if (currentUser.fullName.isNotEmpty) {
            // Katılımcılar dizisini çek
            final katilimciResp = await http.get(Uri.parse('https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar/$turId/katilimcilar.json'));
            List<dynamic> katilimcilar = [];
            if (katilimciResp.statusCode == 200 && katilimciResp.body != 'null') {
              final decoded = json.decode(katilimciResp.body);
              if (decoded is List) {
                katilimcilar = decoded;
              }
            }
            katilimcilar.add(currentUser.fullName);
            await http.patch(
              Uri.parse('https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar/$turId.json'),
              body: json.encode({'katilimcilar': katilimcilar}),
            );
          }
        } catch (e) {
          print('anlikKatilimci veya katilimcilar güncellenemedi: $e');
        }
      }
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  const Text('Başarılı!'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🎉 Tura başarıyla katıldınız!'),
                  const SizedBox(height: 8),
                  const Text('✅ Ödeme işlemi tamamlandı'),
                  const Text('✅ Mesaj grubuna eklendiniz'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.message, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Alt menüdeki "Mesajlar" bölümünden diğer katılımcılarla iletişim kurabilirsiniz',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Mesajlar sayfasına yönlendir
                    Navigator.pushNamed(context, '/messages');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text(
                    'Mesajlara Git',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kapat'),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Tura katılım sırasında bir hata oluştu. Ödeme iade edildi.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  void _showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.white, size: 60),
                ),
              ),
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
