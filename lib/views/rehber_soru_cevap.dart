import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/group_service.dart';
import '../providers/user_provider.dart';
import 'custom_bars.dart';

class RehberSoruCevapSayfasi extends StatefulWidget {
  const RehberSoruCevapSayfasi({super.key});

  @override
  State<RehberSoruCevapSayfasi> createState() => _RehberSoruCevapSayfasiState();
}

class _RehberSoruCevapSayfasiState extends State<RehberSoruCevapSayfasi> {
  List<Map<String, dynamic>> _cevaplanmamisSorular = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Tema renkleri
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF5F6F9);

  @override
  void initState() {
    super.initState();
    _loadSorular();
  }

  Future<void> _loadSorular() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null || !currentUser.isGuide) {
      setState(() {
        _errorMessage = 'Rehber girişi bulunamadı';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sorular = await GroupService.getUnansweredQuestionsByGuide(currentUser.id);
      setState(() {
        _cevaplanmamisSorular = sorular;
        _isLoading = false;
      });
      print('Rehber ${currentUser.fullName} için ${sorular.length} cevaplanmamış soru yüklendi');
    } catch (e) {
      print('Sorular yüklenirken hata: $e');
      setState(() {
        _errorMessage = 'Sorular yüklenirken hata oluştu';
        _isLoading = false;
      });
    }
  }

  Future<void> _cevapVer(String turId, String soruId, String cevap) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return;

    try {
      bool success = await GroupService.answerQuestion(
        turId: turId,
        soruId: soruId,
        cevap: cevap,
        rehberId: currentUser.id,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cevabınız başarıyla gönderildi!'),
            backgroundColor: primaryColor,
          ),
        );
        // Soruları yeniden yükle
        _loadSorular();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cevap gönderilirken hata oluştu'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cevap gönderilirken hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCevapDialog(Map<String, dynamic> soru) {
    final TextEditingController cevapController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Soruyu Cevapla',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tur adı
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.tour, color: primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      soru['turAdi'] ?? 'Bilinmeyen Tur',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Kullanıcı bilgisi
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey[600], size: 16),
                const SizedBox(width: 8),
                Text(
                  soru['kullaniciAdi'] ?? 'Anonim',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatTarih(soru['tarih'] ?? ''),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Soru
            Text(
              'Soru:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                soru['soru'] ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            
            // Cevap alanı
            Text(
              'Cevabınız:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cevapController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Cevabınızı buraya yazın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: primaryColor),
                ),
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
              if (cevapController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _cevapVer(
                  soru['turId'] ?? '',
                  soru['id'] ?? '',
                  cevapController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text(
              'Cevapla',
              style: TextStyle(color: Colors.white),
            ),
          ),
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
      return 'Bilinmiyor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final scaffoldBg = isDark ? theme.scaffoldBackgroundColor : backgroundColor;
    final inputBg = isDark ? Colors.grey[900]! : Colors.white;
    final inputText = isDark ? Colors.white : Colors.black87;
    final hintText = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? darkGreen : primaryColor;
    final chipSelected = isDark ? darkGreen : primaryColor;
    final chipBg = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final chipText = isDark ? Colors.white : Colors.black87;
    final buttonBg = darkGreen;
    final buttonText = Colors.white;
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final currentUser = userProvider.currentUser;

        return Scaffold(
          backgroundColor: scaffoldBg,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Soru & Cevap',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (currentUser != null)
                  Text(
                    'Rehber: ${currentUser.fullName}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            backgroundColor: buttonBg,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadSorular,
                tooltip: 'Yenile',
              ),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: primaryColor),
                      SizedBox(height: 16),
                      Text(
                        'Sorular yükleniyor...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadSorular,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            child: const Text(
                              'Tekrar Dene',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _cevaplanmamisSorular.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.question_answer,
                                    size: 64,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Henüz cevaplanmamış soru yok',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Turlarınızda sorular sorulduğunda burada görünecek',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadSorular,
                          color: primaryColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _cevaplanmamisSorular.length,
                            itemBuilder: (context, index) {
                              final soru = _cevaplanmamisSorular[index];
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Tur adı ve tarih
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: chipBg,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.tour,
                                                  size: 14,
                                                  color: borderColor,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  soru['turAdi'] ?? 'Bilinmeyen Tur',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: borderColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            _formatTarih(soru['tarih'] ?? ''),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: hintText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Kullanıcı adı
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.blue.withOpacity(0.1),
                                            child: Icon(
                                              Icons.person,
                                              size: 14,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            soru['kullaniciAdi'] ?? 'Anonim',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Soru
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: inputBg,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                                          ),
                                        ),
                                        child: Text(
                                          soru['soru'] ?? '',
                                          style: TextStyle(
                                            fontSize: 15,
                                            height: 1.4,
                                            color: inputText,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      
                                      // Cevapla butonu
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _showCevapDialog(soru),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: buttonBg,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.reply,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            'Cevapla',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        );
      },
    );
  }
} 