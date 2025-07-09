import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../controllers/group_service.dart';
import '../providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';

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
      kullaniciAdi: data['kullaniciAdi']?.toString() ?? 'Anonymous',
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
      turAdi: data['turAdi']?.toString() ?? 'Tour name not specified',
      sehir: data['sehir']?.toString() ?? 'City not specified',
      bulusmaKonumu:
          data['bulusmaKonumu']?.toString() ?? 'Location not specified',
      dil: data['dil']?.toString() ?? 'Language not specified',
      fiyat: data['fiyat']?.toString() ?? '0',
      kategori: data['kategori']?.toString() ?? 'Category not specified',
      maxKatilimci: data['maxKatilimci']?.toString() ?? '0',
      olusturmaTarihi: data['olusturmaTarihi']?.toString() ?? '',
      tarih: data['tarih']?.toString() ?? 'Date not specified',
      sure: data['sure']?.toString() ?? 'Duration not specified',
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

  // Koyu tema için koyu yeşil
  static const Color darkGreen = Color(0xFF22543D);

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
      print('Fetching tour data from Firebase: $turId');

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
            _errorMessage = 'Tour not found';
            _isLoading = false;
          });
          return;
        }

        final Map<String, dynamic> turData = json.decode(responseBody);

        setState(() {
          _tur = TurDetayModel.fromFirebase(turId, turData);
          _isLoading = false;
        });

        print('Tour data loaded successfully: ${_tur!.turAdi}');

        // Tur verisi yüklendikten sonra soruları da yükle
        _loadSorular();
      } else {
        setState(() {
          _errorMessage =
              'Data could not be fetched (HTTP ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Data loading error: $e');
      setState(() {
        _errorMessage = 'Error occurred while loading data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTurData() async {
    if (widget.turId == null || widget.turId!.isEmpty) {
      setState(() {
        _errorMessage = 'Tour ID not specified';
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
      final sorularData = await GroupService.getTourQuestions(_tur!.id);

      List<SoruCevapModel> sorular = [];
      for (final soruData in sorularData) {
        sorular.add(
          SoruCevapModel(
            id: soruData['id'] ?? '',
            turId: _tur!.id,
            soru: soruData['soru'] ?? '',
            kullaniciAdi: soruData['kullaniciAdi'] ?? 'Anonymous',
            kullaniciId: soruData['kullaniciId'] ?? '',
            tarih: soruData['tarih'] ?? '',
            cevap: soruData['cevap'],
            cevapTarihi: soruData['cevapTarihi'],
            rehberId:
                _tur!.id, // Tur ID'sini rehber ID olarak kullanıyoruz geçici
          ),
        );
      }

      setState(() {
        _sorular = sorular;
        _isLoadingSorular = false;
      });
    } catch (e) {
      print('Error while loading questions: $e');
      setState(() {
        _isLoadingSorular = false;
      });
    }
  }

  // Yeni soru gönder
  Future<void> _soruGonder() async {
    if (_soruController.text.trim().isEmpty || _tur == null) return;

    try {
      // Kullanıcı bilgilerini provider'dan al
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Soru sormak için giriş yapmanız gerekiyor'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      bool success = await GroupService.sendQuestion(
        turId: _tur!.id,
        soru: _soruController.text.trim(),
        kullaniciId: currentUser.id,
        kullaniciAdi: currentUser.fullName,
      );

      if (success) {
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Soru gönderilirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final scaffoldBg =
        isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF5F6F9);
    final textColor = isDark ? Colors.white : const Color(0xFF2B2B2B);
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? Colors.white10 : Colors.grey.withOpacity(0.3);
    final green = isDark ? darkGreen : const Color(0xFF2E7D32);
    final blue = isDark ? Colors.blue[200]! : Colors.blue;
    final blueBg = isDark ? Colors.blueGrey[900]! : Colors.blue[50]!;
    final blueBorder = isDark ? Colors.blue[200]! : Colors.blue[200]!;
    final blueText = isDark ? Colors.blue[100]! : Colors.blue[800]!;

    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          title: Text(l10n.tourDetails),
          backgroundColor: green,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loading),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          title: Text(l10n.tourDetails),
          backgroundColor: green,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark ? Colors.red[200] : Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTurData,
                style: ElevatedButton.styleFrom(backgroundColor: green),
                child: Text(
                  l10n.tryAgain,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_tur == null) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        appBar: AppBar(
          title: Text(l10n.tourDetails),
          backgroundColor: green,
          foregroundColor: Colors.white,
        ),
        body: Center(child: Text(l10n.tourNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        slivers: [
          // App Bar ve Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: green,
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
                    Container(color: Colors.black),
                    if (_tur!.resim.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: _tur!.resim,
                        fit: BoxFit.contain,
                        placeholder:
                            (context, url) => Container(
                              color: green.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [green.withOpacity(0.8), green],
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
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

                  const SizedBox(height: 100), // Space for bottom button
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
    final l10n = AppLocalizations.of(context)!;
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
                    Text(
                      l10n.tourInformation,
                      style: const TextStyle(
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
                  label: Text(
                    l10n.askQuestion,
                    style: const TextStyle(fontSize: 12),
                  ),
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
                      l10n.noQuestionsYet,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.beFirstToAsk,
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
                        : _sorular.length, // Show first 3 questions
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
                    'All Questions (${_sorular.length})',
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
    final l10n = AppLocalizations.of(context)!;

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
                      _formatTarih(soru.tarih, l10n),
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
                  cevaplandi ? l10n.answered : 'Pending',
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
                      Text(
                        l10n.guideAnswer,
                        style: const TextStyle(
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
                      _formatTarih(soru.cevapTarihi!, l10n),
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

  String _formatTarih(String tarih, AppLocalizations l10n) {
    try {
      final date = DateTime.parse(tarih);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return l10n.now;
      }
    } catch (e) {
      return tarih;
    }
  }

  void _showSoruSorDialog() {
    final TextEditingController _soruController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
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
              Text(l10n.askQuestion),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Write your question to the guide',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _soruController,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Example question: How long does your tour take?',
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
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: _soruGonder,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.send),
            ),
          ],
        );
      },
    );
  }

  void _showTumSorularDialog() {
    final l10n = AppLocalizations.of(context)!;
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
                      Text(
                        l10n.allQuestions,
                        style: const TextStyle(
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
                      label: Text(l10n.askQuestion),
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
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.tourInformation,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bilgi satırları
            _buildInfoRow(Icons.calendar_today, l10n.date, _tur!.tarih, l10n),
            _buildInfoRow(Icons.access_time, l10n.duration, _tur!.sure, l10n),
            _buildInfoRow(
              Icons.location_on,
              l10n.location,
              _tur!.bulusmaKonumu,
              l10n,
            ),
            _buildInfoRow(
              Icons.attach_money,
              l10n.price,
              '${_tur!.fiyat} ₺',
              l10n,
            ),
            _buildInfoRow(
              Icons.group,
              l10n.maxParticipants,
              '${_tur!.maxKatilimci} person(s)',
              l10n,
            ),
            _buildInfoRow(
              Icons.category,
              l10n.category,
              getCategoryLocalized(_tur!.kategori, l10n),
              l10n,
            ),
            _buildInfoRow(
              Icons.language,
              l10n.language,
              getLanguageLocalized(_tur!.dil, l10n),
              l10n,
            ),
            _buildInfoRow(Icons.location_city, l10n.city, _tur!.sehir, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildRotalarCard() {
    final l10n = AppLocalizations.of(context)!;
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
                Text(
                  l10n.tourRoutes,
                  style: const TextStyle(
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

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    AppLocalizations l10n,
  ) {
    final isLocation = label == l10n.location;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                color: isDark ? Colors.white : textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child:
                isLocation
                    ? GestureDetector(
                      onTap: () => _openMapWithAddress(value, l10n),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : Colors.blue, // clickable
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    )
                    : Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : textColor,
                      ),
                      textAlign: TextAlign.right,
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapWithAddress(
    String address,
    AppLocalizations l10n,
  ) async {
    final encodedAddress = Uri.encodeComponent(address);
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(
        Uri.parse(googleMapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.error)));
    }
  }

  Widget _buildBottomButton() {
    final l10n = AppLocalizations.of(context)!;
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
                    'Price',
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
                child: Text(
                  l10n.joinTour,
                  style: const TextStyle(
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
    final l10n = AppLocalizations.of(context)!;

    // Check if user is not logged in
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loginRequiredToJoin),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if guide tries to join own tour
    if (currentUser.isGuide) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.guidesCannotJoinOwnTours),
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
              Text(l10n.joinTour),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello ${currentUser.fullName}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.confirmJoinTour is Function
                    ? l10n.confirmJoinTour(_tur!.turAdi)
                    : (l10n.confirmJoinTour as String).replaceAll(
                      '{tourName}',
                      _tur!.turAdi,
                    ),
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
                    _buildDetailRow('📅 Date:', _tur!.tarih, l10n: l10n),
                    _buildDetailRow('⏰ Duration:', _tur!.sure, l10n: l10n),
                    _buildDetailRow(
                      '📍 Meeting Point:',
                      _tur!.bulusmaKonumu,
                      l10n: l10n,
                    ),
                    _buildDetailRow('🌍 Tour Language:', _tur!.dil, l10n: l10n),
                    const Divider(color: primaryColor),
                    _buildDetailRow(
                      '💰 Price:',
                      '${_tur!.fiyat} ₺',
                      isPrice: true,
                      l10n: l10n,
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
                      l10n.afterJoiningGroupMessage,
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
              child: Text(
                l10n.close,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _processPaymentAndJoinTour(currentUser, l10n);
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
                    l10n.payAndJoin('${_tur!.fiyat}'),
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

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isPrice = false,
    required AppLocalizations l10n,
  }) {
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

  Future<void> _processPaymentAndJoinTour(
    currentUser,
    AppLocalizations l10n,
  ) async {
    // 1. Payment process (simulation)
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
                Text(l10n.processingPayment),
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

    // Payment simulation (2 seconds wait)
    await Future.delayed(const Duration(seconds: 2));

    // Loading dialog'u kapat
    Navigator.pop(context);

    // 2. Payment successful - Join group
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
                Text('Added to group'),
              ],
            ),
          ),
    );

    // 3. Tura katıl ve gruba ekle
    bool success = await GroupService.addUserToTour(
      turId: _tur!.id,
      userId: currentUser.id,
      userName: currentUser.fullName,
    );

    // Loading dialog'u kapat
    Navigator.pop(context);

    // 4. Sonuç mesajı
    if (success) {
      // Increase anlikKatilimci
      if (_tur != null && _tur!.id.isNotEmpty) {
        try {
          final turId = _tur!.id;
          // Önce mevcut değeri çek
          final getResp = await http.get(
            Uri.parse(
              'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar/$turId/anlikKatilimci.json',
            ),
          );
          int mevcutKatilimci = 0;
          if (getResp.statusCode == 200 && getResp.body != 'null') {
            mevcutKatilimci =
                int.tryParse(getResp.body.replaceAll('"', '')) ?? 0;
          }
          final yeniKatilimci = mevcutKatilimci + 1;
          await http.patch(
            Uri.parse(
              'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar/$turId.json',
            ),
            body: json.encode({'anlikKatilimci': yeniKatilimci}),
          );

          // Katılımcı ismini ekle
          if (currentUser.fullName.isNotEmpty) {
            // Katılımcılar dizisini çek
            final katilimciResp = await http.get(
              Uri.parse(
                'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar/$turId/katilimcilar.json',
              ),
            );
            List<dynamic> katilimcilar = [];
            if (katilimciResp.statusCode == 200 &&
                katilimciResp.body != 'null') {
              final decoded = json.decode(katilimciResp.body);
              if (decoded is List) {
                katilimcilar = decoded;
              }
            }
            katilimcilar.add(currentUser.fullName);
            await http.patch(
              Uri.parse(
                'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar/$turId.json',
              ),
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
                  Text(l10n.success),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.successfullyJoinedTour),
                  const SizedBox(height: 8),
                  Text(l10n.paymentCompleted),
                  Text('Added to group'),
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
                            'Added to group',
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
                  child: Text(
                    l10n.messages,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close),
                ),
              ],
            ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tourJoinError),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showFullScreenImage(String imageUrl) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(10),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  errorWidget:
                      (context, url, error) => Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                  placeholder:
                      (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
    );
  }

  // Helper to translate category
  String getCategoryLocalized(String kategori, AppLocalizations l10n) {
    final locale = l10n.localeName;
    if (locale.startsWith('en')) {
      switch (kategori) {
        case 'Kültür':
          return 'Culture';
        case 'Doğa':
          return 'Nature';
        case 'Yemek':
          return 'Food';
        case 'Tarih':
          return 'History';
        case 'Sanat':
          return 'Art';
        case 'Macera':
          return 'Adventure';
        case 'Alışveriş':
          return 'Shopping';
        case 'Eğlence':
          return 'Entertainment';
        case 'Spor':
          return 'Sports';
        case 'Teknoloji':
          return 'Technology';
        default:
          return kategori;
      }
    }
    return kategori;
  }

  // Helper to translate language
  String getLanguageLocalized(String dil, AppLocalizations l10n) {
    final locale = l10n.localeName;
    if (locale.startsWith('en')) {
      switch (dil) {
        case 'Türkçe':
          return 'Turkish';
        case 'İngilizce':
          return 'English';
        case 'Almanca':
          return 'German';
        case 'Fransızca':
          return 'French';
        case 'İspanyolca':
          return 'Spanish';
        case 'Arapça':
          return 'Arabic';
        case 'Rusça':
          return 'Russian';
        case 'İtalyanca':
          return 'Italian';
        case 'Çince':
          return 'Chinese';
        case 'Japonca':
          return 'Japanese';
        default:
          return dil;
      }
    }
    return dil;
  }

  // Helper to translate location (optional, for city names you can expand as needed)
  String getLocationLocalized(String location, AppLocalizations l10n) {
    // Example: Istanbul -> Istanbul (no change), but you can expand for other cities
    return location;
  }
}
