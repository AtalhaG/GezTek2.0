import 'package:flutter/material.dart';

class RehberOzetSayfasi extends StatelessWidget {
  const RehberOzetSayfasi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        title: const Text(
          'Tur Özeti',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Backend ekibi filtreleme fonksiyonunu ekleyecek
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Backend ekibi paylaşım fonksiyonunu ekleyecek
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tur Bilgileri Kartı
            _buildTurBilgileriKarti(),
            
            // İstatistikler Kartı
            _buildIstatistiklerKarti(),
            
            // Katılımcılar Listesi
            _buildKatilimcilarListesi(),
          ],
        ),
      ),
    );
  }

  Widget _buildTurBilgileriKarti() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kapadokya Turu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '15 Mart 2024, Cuma',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTurBilgiItem(
                Icons.location_on,
                'Nevşehir',
                'Başlangıç',
              ),
              _buildTurBilgiItem(
                Icons.access_time,
                '3 Gün',
                'Süre',
              ),
              _buildTurBilgiItem(
                Icons.people,
                '6 Kişi',
                'Kapasite',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTurBilgiItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildIstatistiklerKarti() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tur İstatistikleri',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildIstatistikKutusu(
                  'Toplam Gelir',
                  '₺15.000',
                  Icons.attach_money,
                  const Color(0xFF2E7D32),
                  'Bu ay',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIstatistikKutusu(
                  'Katılımcı',
                  '6',
                  Icons.people,
                  const Color(0xFF1976D2),
                  'Aktif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildIstatistikKutusu(
                  'Değerlendirme',
                  '4.8',
                  Icons.star,
                  const Color(0xFFFFA000),
                  'Ortalama',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIstatistikKutusu(
                  'Tamamlanan',
                  '12',
                  Icons.check_circle,
                  const Color(0xFF43A047),
                  'Turlar',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIstatistikKutusu(
      String baslik, String deger, IconData icon, Color renk, String altBaslik) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: renk.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: renk, size: 20),
              const SizedBox(width: 8),
              Text(
                baslik,
                style: TextStyle(
                  color: renk,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            deger,
            style: TextStyle(
              color: renk,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            altBaslik,
            style: TextStyle(
              color: renk.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKatilimcilarListesi() {
    // Placeholder veri - Backend'den gelecek
    final List<Map<String, dynamic>> katilimcilar = [
      {
        'ad': 'Ahmet Yılmaz',
        'telefon': '+90 555 123 4567',
        'avatar': 'https://via.placeholder.com/50',
        'durum': 'Onaylandı',
        'durumRengi': Colors.green,
      },
      {
        'ad': 'Ayşe Demir',
        'telefon': '+90 555 987 6543',
        'avatar': 'https://via.placeholder.com/50',
        'durum': 'Beklemede',
        'durumRengi': Colors.orange,
      },
      // Diğer katılımcılar backend'den gelecek
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Katılımcılar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Backend ekibi katılımcı ekleme fonksiyonunu ekleyecek
                },
                icon: const Icon(Icons.person_add, size: 20),
                label: const Text('Katılımcı Ekle'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: katilimcilar.length,
            itemBuilder: (context, index) {
              final katilimci = katilimcilar[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: NetworkImage(katilimci['avatar']),
                  ),
                  title: Text(
                    katilimci['ad'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        katilimci['telefon'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (katilimci['durumRengi'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          katilimci['durum'],
                          style: TextStyle(
                            color: katilimci['durumRengi'],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.message_outlined),
                        color: const Color(0xFF2E7D32),
                        onPressed: () {
                          // Backend ekibi mesajlaşma fonksiyonunu ekleyecek
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.phone_outlined),
                        color: const Color(0xFF2E7D32),
                        onPressed: () {
                          // Backend ekibi arama fonksiyonunu ekleyecek
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        color: Colors.grey[600],
                        onPressed: () {
                          // Backend ekibi diğer işlemler menüsünü ekleyecek
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}