import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
              background: Container(
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
                    const SizedBox(height: 16),
                    Text(
                      _tur!.sehir,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
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
            child: Text(
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Tura Katıl'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_tur!.turAdi} turuna katılmak istediğinizden emin misiniz?',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tarih:'),
                        Text(
                          _tur!.tarih,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fiyat:'),
                        Text(
                          '${_tur!.fiyat} ₺',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tura başarıyla katıldınız!'),
                    backgroundColor: primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Katıl', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
