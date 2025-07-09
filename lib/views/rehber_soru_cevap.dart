import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/group_service.dart';
import '../providers/user_provider.dart';
import 'custom_bars.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser == null || !currentUser.isGuide) {
      setState(() {
        _errorMessage = l10n.guideLoginNotFound;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sorular = await GroupService.getUnansweredQuestionsByGuide(
        currentUser.id,
      );
      setState(() {
        _cevaplanmamisSorular = sorular;
        _isLoading = false;
      });
      print(
        '${l10n.questionsLoadedForGuide} ${currentUser.fullName}: ${sorular.length} ${l10n.question.toLowerCase()}',
      );
    } catch (e) {
      print('${l10n.errorLoadingQuestions}: $e');
      setState(() {
        _errorMessage = l10n.errorLoadingQuestions;
        _isLoading = false;
      });
    }
  }

  Future<void> _cevapVer(String turId, String soruId, String cevap) async {
    final l10n = AppLocalizations.of(context)!;
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
          SnackBar(
            content: Text(l10n.answerSentSuccessfully),
            backgroundColor: primaryColor,
          ),
        );
        // Soruları yeniden yükle
        _loadSorular();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorSendingAnswer),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorSendingAnswer),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCevapDialog(Map<String, dynamic> soru) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController cevapController = TextEditingController();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              l10n.answerQuestion,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? darkGreen : primaryColor,
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
                    color: (isDark ? darkGreen : primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tour,
                        color: isDark ? darkGreen : primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          soru['turAdi'] ?? l10n.unknownTour,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isDark ? darkGreen : primaryColor,
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
                    Icon(
                      Icons.person,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      soru['kullaniciAdi'] ?? l10n.anonymous,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTarih(soru['tarih'] ?? ''),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Soru
                Text(
                  '${l10n.question}:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    soru['soru'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cevap alanı
                Text(
                  '${l10n.answer}:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cevapController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: l10n.writeYourAnswer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark ? darkGreen : primaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (cevapController.text.trim().isNotEmpty) {
                    Navigator.of(context).pop();
                    _cevapVer(
                      soru['turId'] ?? '',
                      soru['soruId'] ?? '',
                      cevapController.text.trim(),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? darkGreen : primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.answer),
              ),
            ],
          ),
    );
  }

  String _formatTarih(String tarih) {
    if (tarih.isEmpty) return '';
    try {
      final DateTime dateTime = DateTime.parse(tarih);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return tarih;
    }
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
        title: Text(
          l10n.questionAnswer,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: isDark ? Colors.white : darkGreen,
          ),
        ),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1F222A) : Colors.white,
        foregroundColor: isDark ? Colors.white : darkGreen,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSorular),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSorular,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? darkGreen : primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              )
              : _cevaplanmamisSorular.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.question_answer_outlined,
                      size: 64,
                      color: isDark ? Colors.grey[400] : Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noUnansweredQuestions,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _cevaplanmamisSorular.length,
                itemBuilder: (context, index) {
                  final soru = _cevaplanmamisSorular[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tur bilgisi
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isDark ? darkGreen : primaryColor)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.tour,
                                  color: isDark ? darkGreen : primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      soru['turAdi'] ?? l10n.unknownTour,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTarih(soru['tarih'] ?? ''),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            isDark
                                                ? Colors.white70
                                                : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Kullanıcı bilgisi
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[200],
                                child: Text(
                                  (soru['kullaniciAdi'] ?? l10n.anonymous)
                                          .isNotEmpty
                                      ? (soru['kullaniciAdi'] ??
                                              l10n.anonymous)[0]
                                          .toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                soru['kullaniciAdi'] ?? l10n.anonymous,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color:
                                      isDark
                                          ? Colors.white70
                                          : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Soru
                          Text(
                            '${l10n.question}:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            soru['soru'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Cevapla butonu
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _showCevapDialog(soru),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isDark ? darkGreen : primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                l10n.answer,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
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
      bottomNavigationBar: const CustomBottomBar(currentIndex: 2),
    );
  }
}
