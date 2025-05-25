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
  final String kategoriler;
  final int maxKatilimci;
  final String olusturulmaTarihi;
  final String tarih;
  final String emin;
  final String resim;
  final List<DegerlendirmeModel> degerlendirmeler;

  TurDetayModel({
    required this.id,
    required this.turAdi,
    required this.sehir,
    required this.bulusmaKonumu,
    required this.dil,
    required this.fiyat,
    required this.kategoriler,
    required this.maxKatilimci,
    required this.olusturulmaTarihi,
    required this.tarih,
    required this.emin,
    required this.resim,
    required this.degerlendirmeler,
  });

  // Firebase'den gelen veriyi model'e çeviren factory constructor
  factory TurDetayModel.fromFirebase(String id, Map<String, dynamic> data) {
    return TurDetayModel(
      id: id,
      turAdi: data['turAdi'] ?? '',
      sehir: data['Şehir'] ?? '',
      bulusmaKonumu: data['bulusmaKonumu'] ?? '',
      dil: data['dil'] ?? '',
      fiyat: data['fiyat'] ?? '0',
      kategoriler: data['Kategoriler'] ?? '',
      maxKatilimci: int.tryParse(data['maxKatilimci']?.toString() ?? '0') ?? 0,
      olusturulmaTarihi: data['olusturulma Tarihi'] ?? '',
      tarih: data['tarih'] ?? '',
      emin: data['emin'] ?? '',
      resim: 'https://picsum.photos/800/400?random=1', // Varsayılan resim
      degerlendirmeler: [],
    );
  }
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

// Firebase'den gelecek örnek veri yapısı
final dummyTur = TurDetayModel(
  id: '-OQeK-ZAcbPzDH6MbZtg',
  turAdi: 'İst turu',
  sehir: 'İstanbul',
  bulusmaKonumu: 'Sahil',
  dil: 'Türkçe',
  fiyat: '500',
  kategoriler: 'Yürüyüş Turu',
  maxKatilimci: 6,
  olusturulmaTarihi: '2025-05-19T23:54:58.480',
  tarih: '27/05/2025',
  emin: '5 saat',
  resim: 'https://picsum.photos/800/400?random=1',
  degerlendirmeler: [
    DegerlendirmeModel(
      id: '1',
      kullaniciAdi: 'İyi Birisi',
      kullaniciFoto: 'https://picsum.photos/50?random=20',
      puan: 4.6,
      yorum: 'Harika bir deneyimdi!',
      tarih: '2 gün önce',
    ),
    DegerlendirmeModel(
      id: '2',
      kullaniciAdi: 'Mükemmekli',
      kullaniciFoto: 'https://picsum.photos/50?random=21',
      puan: 5.0,
      yorum: 'Kesinlikle tavsiye ederim.',
      tarih: '1 hafta önce',
    ),
  ],
);

class TurDetay extends StatefulWidget {
  final String? turId;

  const TurDetay({super.key, this.turId});

  @override
  State<TurDetay> createState() => _TurDetayState();
}

class _TurDetayState extends State<TurDetay> {
  late TurDetayModel _tur;
  bool _isLoading = true;

  // Tema renkleri
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF5F6F9);
  static const Color textColor = Color(0xFF2B2B2B);

  @override
  void initState() {
    super.initState();
    _loadTurData();
  }

  Future<void> _loadTurData() async {
    try {
      // Eğer turId yoksa dummy data kullan
      if (widget.turId == null || widget.turId!.isEmpty) {
        setState(() {
          _tur = dummyTur;
          _isLoading = false;
        });
        return;
      }

      // Firebase'den tur verilerini çek
      final response = await http.get(
        Uri.parse(
          'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar/${widget.turId}.json',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> turData = json.decode(response.body);
        if (turData != null) {
          setState(() {
            _tur = TurDetayModel.fromFirebase(widget.turId!, turData);
            _isLoading = false;
          });
        } else {
          // Tur bulunamadı, dummy data kullan
          setState(() {
            _tur = dummyTur;
            _isLoading = false;
          });
        }
      } else {
        // Hata durumunda dummy data kullan
        setState(() {
          _tur = dummyTur;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Hata durumunda dummy data kullan
      setState(() {
        _tur = dummyTur;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar ve Resim
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _tur.resim,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.image, size: 100, color: Colors.grey),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _tur.turAdi,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _tur.sehir,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tur Bilgileri Kartı
                  _buildTurBilgileriCard(),
                  SizedBox(height: 16),

                  // Değerlendirmeler
                  _buildDegerlendirmelerCard(),
                  SizedBox(height: 100), // Bottom button için boşluk
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tur Bilgileri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: 16),

            // Bilgi satırları - Firebase verilerine uygun
            _buildInfoRow(Icons.calendar_today, 'Tarih', _tur.tarih),
            _buildInfoRow(Icons.access_time, 'Süre', _tur.emin),
            _buildInfoRow(
              Icons.location_on,
              'Buluşma Konumu',
              _tur.bulusmaKonumu,
            ),
            _buildInfoRow(Icons.attach_money, 'Fiyat', '${_tur.fiyat} ₺'),
            _buildInfoRow(
              Icons.group,
              'Maksimum Katılım',
              '${_tur.maxKatilimci} kişi',
            ),
            _buildInfoRow(Icons.category, 'Kategori', _tur.kategoriler),
            _buildInfoRow(Icons.language, 'Tur Dili', _tur.dil),
            _buildInfoRow(Icons.location_city, 'Şehir', _tur.sehir),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDegerlendirmelerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Değerlendirmeler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Tümünü Gör',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Değerlendirme listesi
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _tur.degerlendirmeler.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final degerlendirme = _tur.degerlendirmeler[index];
                return _buildDegerlendirmeItem(degerlendirme);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDegerlendirmeItem(DegerlendirmeModel degerlendirme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(degerlendirme.kullaniciFoto),
            onBackgroundImageError: (exception, stackTrace) {},
            child: Icon(Icons.person, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      degerlendirme.kullaniciAdi,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          degerlendirme.puan.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  degerlendirme.yorum,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  degerlendirme.tarih,
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            _showKatilDialog();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Tura Katıl',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showKatilDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tura Katıl'),
          content: Text('Bu tura katılmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tura başarıyla katıldınız!'),
                    backgroundColor: primaryColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text('Katıl', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
