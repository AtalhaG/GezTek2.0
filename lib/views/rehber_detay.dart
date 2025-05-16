import 'package:flutter/material.dart';

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
  hakkimda: '10 yıllık deneyimli rehberimiz Ahmet Yılmaz, İstanbul\'un tarihi ve kültürel zenginliklerini keşfetmeniz için sizlere rehberlik ediyor.',
  uzmanlikAlanlari: ['Tarihi Turlar', 'Kültür Turları', 'Müze Turları', 'Gastronomi Turları'],
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
      kullaniciFoto: 'https://picsum.photos/100?random=${index + 100}', // Network resmi kullanıyoruz
      puan: 4.5,
      yorum: 'Harika bir tur deneyimiydi! Rehberimiz çok bilgili ve ilgiliydi.',
      tarih: '${index + 1} gün önce',
    ),
  ),
);

class RehberDetay extends StatefulWidget {
  final String rehberId; // Backend ekibi bu ID'yi kullanarak veriyi çekecek

  const RehberDetay({
    Key? key,
    required this.rehberId,
  }) : super(key: key);

  @override
  State<RehberDetay> createState() => _RehberDetayState();
}

class _RehberDetayState extends State<RehberDetay> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RehberModel _rehber; // Backend'den gelecek veri için hazır

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
    // Şimdilik dummy data kullanıyoruz
    setState(() {
      _rehber = dummyRehber;
    });
  }

  // Yorum ekleme dialog'unu göster
  void _showYorumEkleDialog() {
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
              onPressed: () {
                if (_yorumController.text.trim().isNotEmpty) {
                  // Backend ekibi burada yorumu kaydedecek
                  // Şimdilik dummy data olarak ekliyoruz
                  setState(() {
                    _rehber.degerlendirmeler.insert(
                      0,
                      DegerlendirmeModel(
                        id: 'yeni_${DateTime.now().millisecondsSinceEpoch}',
                        kullaniciAdi: 'Ben',
                        kullaniciFoto: 'https://picsum.photos/100?random=999',
                        puan: _secilenPuan,
                        yorum: _yorumController.text.trim(),
                        tarih: 'Şimdi',
                      ),
                    );
                  });
                  Navigator.pop(context);
                  _yorumController.clear();
                  _secilenPuan = 5.0;
                  
                  // Başarılı mesajı göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Değerlendirmeniz başarıyla eklendi'),
                      backgroundColor: Colors.green,
                    ),
                  );
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
    _yorumController.dispose(); // Controller'ı dispose et
    _tabController.dispose();
    super.dispose();
  }

  // Modüler widget'lar
  Widget _buildProfileHeader() {
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
            backgroundImage: NetworkImage('https://picsum.photos/200'), // Geçici olarak network resmi kullanıyoruz
          ),
          const SizedBox(height: 15),
          Text(
            '${_rehber.ad} ${_rehber.soyad}',
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
                _rehber.puan.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                '(${_rehber.degerlendirmeSayisi} değerlendirme)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
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
              _buildInfoChip(Icons.location_on, _rehber.konum),
              _buildInfoChip(Icons.language, _rehber.diller.join(', ')),
              if (_rehber.onayliRehber)
                _buildInfoChip(Icons.verified, 'Onaylı Rehber'),
              _buildInfoChip(Icons.work_history, _rehber.deneyim),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Rehber Hakkında'),
          const SizedBox(height: 10),
          Text(
            _rehber.hakkimda,
            style: const TextStyle(
              fontSize: 14,
              color: textColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Uzmanlık Alanları'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _rehber.uzmanlikAlanlari
                .map((alan) => _buildExpertiseChip(alan))
                .toList(),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Eğitim Bilgileri'),
          const SizedBox(height: 10),
          ..._rehber.egitimBilgileri.map((egitim) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.school, size: 20, color: primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    egitim,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
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
              children: _rehber.calismaSaatleri.entries.map((entry) {
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
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _rehber.turlar.length,
      itemBuilder: (context, index) {
        final tur = _rehber.turlar[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  tur.resim,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(
                          'Max ${tur.maxKisi} kişi',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
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
                            // Backend ekibi tur detayı sayfasına yönlendirme ekleyebilir
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
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _rehber.degerlendirmeler.length,
            itemBuilder: (context, index) {
              final degerlendirme = _rehber.degerlendirmeler[index];
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
          Icon(
            Icons.smart_toy,
            size: 64,
            color: primaryColor.withOpacity(0.5),
          ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: NestedScrollView(
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
              delegate: _SliverAppBarDelegate(
                _buildTabBar(),
              ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Backend ekibi iletişim sayfasına yönlendirme ekleyebilir
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.message),
        label: const Text('İletişime Geç'),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverAppBarDelegate(this.child);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: child,
    );
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
