import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geztek/views/message_list.dart';

class RehberOzetSayfasi extends StatefulWidget {
  const RehberOzetSayfasi({Key? key}) : super(key: key);

  @override
  State<RehberOzetSayfasi> createState() => _RehberOzetSayfasiState();
}

class _RehberOzetSayfasiState extends State<RehberOzetSayfasi> {
  bool _isSearching = true;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredTours = [];
  List<Map<String, dynamic>> _allTours = [];
  Map<String, dynamic>? _selectedTour;

  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _loadTours();
  }

  Future<void> _loadTours() async {
    try {
      final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final DatabaseReference ref = FirebaseDatabase.instance.ref("turlar");
      final DatabaseEvent event = await ref.once();
      final DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> data =
            snapshot.value as Map<dynamic, dynamic>;
        print('Yüklenen veri: $data');
        setState(() {
          _allTours =
              data.entries
                  .map((entry) {
                    final Map<dynamic, dynamic> tour =
                        entry.value as Map<dynamic, dynamic>;
                    print('İşlenen tur: $tour');
                    return {
                      'id': entry.key,
                      'name': tour['turAdi']?.toString() ?? '',
                      'date': tour['tarih']?.toString() ?? '',
                      'location': tour['bulusmaKonumu']?.toString() ?? '',
                      'duration': tour['sure']?.toString() ?? '',
                      'capacity': tour['maxKatilimci']?.toString() ?? '',
                      'price': tour['fiyat']?.toString() ?? '',
                      'category': tour['kategori']?.toString() ?? '',
                      'city': tour['sehir']?.toString() ?? '',
                      'language': tour['dil']?.toString() ?? '',
                      'rehberId': tour['rehberId']?.toString() ?? '',
                      'katilimcilar': tour['katilimcilar'] ?? [],
                      'anlikKatilimci':
                          tour['anlikKatilimci']?.toString() ?? [],
                    };
                  })
                  .where((tour) => tour['rehberId'] == currentUserId)
                  .toList();
          _filteredTours = List.from(_allTours);
          if (_allTours.isNotEmpty) {
            _selectedTour = _allTours[0];
            print('Seçilen tur: $_selectedTour');
          }
        });
      } else {
        print('Veri bulunamadı veya null');
        setState(() {
          _allTours = [];
          _filteredTours = [];
          _selectedTour = null;
        });
      }
    } catch (e) {
      print('Turlar yüklenirken hata oluştu: $e');
      setState(() {
        _allTours = [];
        _filteredTours = [];
        _selectedTour = null;
      });
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _filteredTours = _allTours;
    });
  }

  void _filterTours(String query) {
    setState(() {
      _filteredTours =
          _allTours
              .where(
                (tour) =>
                    tour['name'].toLowerCase().contains(query.toLowerCase()) ||
                    tour['location'].toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tur Ara...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterTours,
                )
                : const Text(
                  'Tur Özeti',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2E7D32),
        actions: [
          if (_isSearching)
            IconButton(icon: const Icon(Icons.close), onPressed: _stopSearch)
          else
            IconButton(icon: const Icon(Icons.search), onPressed: _startSearch),
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
      body:
          _isSearching
              ? _allTours.isEmpty
                  ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                  )
                  : ListView.builder(
                    itemCount: _filteredTours.length,
                    itemBuilder: (context, index) {
                      final tour = _filteredTours[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            tour['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${tour['date']} - ${tour['location']}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          trailing: Text(
                            '${tour['duration']} • ${tour['capacity']}',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _isSearching = false;
                              _selectedTour = tour;
                            });
                          },
                        ),
                      );
                    },
                  )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    if (_selectedTour != null) ...[
                      _buildTurBilgileriKarti(),
                      _buildIstatistiklerKarti(),
                      _buildKatilimcilarListesi(),
                    ] else
                      const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTurBilgileriKarti() {
    if (_selectedTour == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      );
    }

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedTour!['name'] ?? 'Tur Adı',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedTour!['date'] ?? 'Tarih'} - ${_selectedTour!['city'] ?? 'Şehir'}',
                      style: const TextStyle(
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
                _selectedTour!['location'] ?? 'Konum',
                'Buluşma Yeri',
              ),
              _buildTurBilgiItem(
                Icons.access_time,
                _selectedTour!['duration'] ?? 'Süre',
                'Süre',
              ),
              _buildTurBilgiItem(
                Icons.people,
                '${_selectedTour!['capacity'] ?? '0'} Kişi',
                'Kapasite',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTurBilgiItem(
                Icons.category,
                _selectedTour!['category'] ?? 'Kategori',
                'Kategori',
              ),
              _buildTurBilgiItem(
                Icons.language,
                _selectedTour!['language'] ?? 'Dil',
                'Dil',
              ),
              _buildTurBilgiItem(
                Icons.attach_money,
                '${_selectedTour!['price'] ?? '0'} ₺',
                'Fiyat',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTurBilgiItem(IconData icon, String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
        const SizedBox(height: 8),
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
          style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                  (int.parse(_selectedTour!['anlikKatilimci'] ?? '0') *
                          int.parse(_selectedTour!['price'] ?? '0'))
                      .toString(),
                  Icons.attach_money,
                  const Color(0xFF2E7D32),
                  'Bu tur',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIstatistikKutusu(
                  'Katılımcı',
                  _selectedTour?["anlikKatilimci"],
                  Icons.people,
                  const Color(0xFF1976D2),
                  'Aktif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIstatistikKutusu(
    String baslik,
    String deger,
    IconData icon,
    Color renk,
    String altBaslik,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: renk.withOpacity(0.2), width: 1),
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
            style: TextStyle(color: renk.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildKatilimcilarListesi() {
    final List<String> katilimciIsimleri =
        _selectedTour?["katilimcilar"] is List
            ? List<String>.from(_selectedTour?["katilimcilar"])
            : [];

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
            ],
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: katilimciIsimleri.length,
            itemBuilder: (context, index) {
              final katilimciAdi = katilimciIsimleri[index];
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
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/50',
                    ),
                    child: Text(
                      katilimciAdi.isNotEmpty ? katilimciAdi[0] : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    katilimciAdi,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Onaylandı',
                          style: TextStyle(
                            color: Colors.green,
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MessageList(),
                            ),
                          );
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
