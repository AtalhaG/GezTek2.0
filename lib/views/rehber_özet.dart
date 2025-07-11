import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geztek/views/message_list.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchTour,
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onChanged: _filterTours,
                )
                : Text(
                  l10n.tourSummary,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1F222A) : Colors.white,
        foregroundColor: isDark ? Colors.white : darkGreen,
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
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    itemCount: _filteredTours.length,
                    itemBuilder: (context, index) {
                      final tour = _filteredTours[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: theme.cardColor,
                        child: ListTile(
                          title: Text(
                            tour['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          subtitle: Text(
                            '${tour['date']} - ${tour['location']}',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 14,
                            ),
                          ),
                          trailing: Text(
                            '${tour['duration']} • ${tour['capacity']}',
                            style: TextStyle(
                              color:
                                  isDark ? darkGreen : const Color(0xFF2E7D32),
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
                      _buildTurBilgileriKarti(theme, isDark, darkGreen),
                      _buildIstatistiklerKarti(theme, isDark, darkGreen),
                      _buildKatilimcilarListesi(theme, isDark, darkGreen),
                    ] else
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
    );
  }

  Widget _buildTurBilgileriKarti(
    ThemeData theme,
    bool isDark,
    Color darkGreen,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedTour == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? darkGreen : const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.green.withOpacity(0.2),
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
                  color:
                      isDark ? Colors.white24 : Colors.white.withOpacity(0.2),
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
                _selectedTour!['location'] ?? l10n.location,
                l10n.meetingPlace,
              ),
              _buildTurBilgiItem(
                Icons.access_time,
                _selectedTour!['duration'] ?? l10n.duration,
                l10n.duration,
              ),
              _buildTurBilgiItem(
                Icons.people,
                '${_selectedTour!['capacity'] ?? '0'} ${l10n.participants}',
                l10n.capacity,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTurBilgiItem(
                Icons.category,
                _selectedTour!['category'] ?? l10n.category,
                l10n.category,
              ),
              _buildTurBilgiItem(
                Icons.language,
                _selectedTour!['language'] ?? l10n.language,
                l10n.language,
              ),
              _buildTurBilgiItem(
                Icons.attach_money,
                '${_selectedTour!['price'] ?? '0'} ₺',
                l10n.price,
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

  Widget _buildIstatistiklerKarti(
    ThemeData theme,
    bool isDark,
    Color darkGreen,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tourStatistics,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? darkGreen : const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildIstatistikKutusu(
                  l10n.totalRevenue,
                  (int.parse(_selectedTour!['anlikKatilimci'] ?? '0') *
                          int.parse(_selectedTour!['price'] ?? '0'))
                      .toString(),
                  Icons.attach_money,
                  isDark ? darkGreen : const Color(0xFF2E7D32),
                  l10n.thisTour,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildIstatistikKutusu(
                  l10n.participants,
                  _selectedTour?["anlikKatilimci"],
                  Icons.people,
                  isDark ? Colors.blue[200]! : const Color(0xFF1976D2),
                  l10n.active,
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

  Widget _buildKatilimcilarListesi(
    ThemeData theme,
    bool isDark,
    Color darkGreen,
  ) {
    final l10n = AppLocalizations.of(context)!;
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
              Text(
                l10n.participants,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? darkGreen : const Color(0xFF2E7D32),
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
                    color:
                        isDark ? Colors.white10 : Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                color: theme.cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        isDark ? Colors.grey[800] : Colors.grey[200],
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
                          color: (isDark ? darkGreen : Colors.green)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.approved,
                          style: TextStyle(
                            color: isDark ? darkGreen : Colors.green,
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
                        color: isDark ? darkGreen : const Color(0xFF2E7D32),
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
