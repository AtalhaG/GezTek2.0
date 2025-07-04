import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../utils/encryption_helper.dart';
import '../utils/email_helper.dart';
import 'login_page.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';

class KayitOl extends StatefulWidget {
  const KayitOl({super.key});

  @override
  State<KayitOl> createState() => _KayitOlState();
}

class _KayitOlState extends State<KayitOl> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _tcKimlikController = TextEditingController();
  final TextEditingController _ruhsatNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _selfIntroductionController =
      TextEditingController();
  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  String _selectedUserType = 'turist'; // 'turist' veya 'rehber'
  String? _selectedGender;
  File? _profileImage;
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;
  Map<String, dynamic>? _userKeys;
  String? _userId;
  bool _isSaving = false;
  bool _isFormSubmitted = false;

  // Tour categories for tourists
  final List<String> _tourCategories = [
    'Tarihi ve Kültürel Turlar',
    'Doğa ve Macera Turları',
    'Deniz, Kum, Güneş Turları',
    'Gastronomi Turları',
    'Sanat ve Mimari Turları',
    'Spor Turları',
    'Dini Turlar',
    'Alışveriş Turları',
    'Festival ve Etkinlik Turları',
    'Gece Hayatı Turları',
  ];
  Set<String> _selectedTourCategories = {};

  // Rehber specific fields state
  Set<String> _selectedServiceCities = {};
  Set<String> _selectedLanguages = {};

  // Possible cities and languages (add more as needed)
  final List<String> _popularCities = [
    'İstanbul',
    'Antalya',
    'İzmir',
    'Muğla',
    'Bursa',
  ];
  final List<String> _cities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Aksaray',
    'Amasya',
    'Ankara',
    'Antalya',
    'Ardahan',
    'Artvin',
    'Aydın',
    'Balıkesir',
    'Bartın',
    'Batman',
    'Bayburt',
    'Bilecik',
    'Bingöl',
    'Bitlis',
    'Bolu',
    'Burdur',
    'Bursa',
    'Çanakkale',
    'Çankırı',
    'Çorum',
    'Denizli',
    'Diyarbakır',
    'Düzce',
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkâri',
    'Hatay',
    'Iğdır',
    'Isparta',
    'İstanbul',
    'İzmir',
    'Kahramanmaraş',
    'Karabük',
    'Karaman',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kilis',
    'Kırıkkale',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Mardin',
    'Mersin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Osmaniye',
    'Rize',
    'Sakarya',
    'Samsun',
    'Şanlıurfa',
    'Siirt',
    'Sinop',
    'Sivas',
    'Şırnak',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Uşak',
    'Van',
    'Yalova',
    'Yozgat',
    'Zonguldak',
  ];
  bool _showAllCities = false;
  final List<String> _languages = [
    'English',
    'Chinese',
    'Hindi',
    'Spanish',
    'French',
    'Portuguese',
    'Bengali',
    'Russian',
    'Urdu',
    'Indonesian',
    'German',
    'Japanese',
    'Nigerian Pidgin',
    'Arabic',
    'Marathi',
    'Vietnamese',
    'Telugu',
    'Hausa',
    'Turkish',
  ];

  // Özel renkler
  static const Color primaryColor = Color(0xFF4CAF50); // Yeşil tema
  static const Color backgroundColor = Color(0xFFF5F6F9);
  static const Color textColor = Color(0xFF2B2B2B);

  final List<Map<String, String>> _countryCodes = [
    {'code': '+90', 'abbr': 'TR'},
    {'code': '+1', 'abbr': 'US'},
    {'code': '+44', 'abbr': 'UK'},
    {'code': '+49', 'abbr': 'DE'},
    {'code': '+33', 'abbr': 'FR'},
    {'code': '+7', 'abbr': 'RU'},
    {'code': '+39', 'abbr': 'IT'},
    {'code': '+966', 'abbr': 'SA'},
    {'code': '+355', 'abbr': 'AL'},
    {'code': '+994', 'abbr': 'AZ'},
  ];
  String _selectedCountryCode = '+90';

  // Encrypted data variables
  String? encryptedAd;
  String? encryptedSoyad;
  String? encryptedTC;
  String? encryptedRuhsatNo;
  String? encryptedEmail;
  String? encryptedPassword;
  String? encryptedPhone;
  String? encryptedBirthDate;
  String? encryptedGender;

  String? _verificationCode;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _userKeys = EncryptionHelper.generateUserKeys();
  }

  Widget _buildUserTypeSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final scaffoldBg = isDark ? theme.scaffoldBackgroundColor : backgroundColor;
    final inputBg = isDark ? Colors.grey[900]! : Colors.white;
    final inputText = isDark ? Colors.white : textColor;
    final hintText = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? darkGreen : primaryColor;
    final chipSelected = isDark ? darkGreen : primaryColor;
    final chipBg = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final chipText = isDark ? Colors.white : Colors.black87;
    final buttonBg = darkGreen;
    final buttonText = Colors.white;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedUserType = 'turist'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _selectedUserType == 'turist'
                      ? chipSelected
                      : chipBg,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'TURİST',
              style: TextStyle(
                color:
                    _selectedUserType == 'turist' ? Colors.white : chipText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedUserType = 'rehber'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _selectedUserType == 'rehber'
                      ? chipSelected
                      : chipBg,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'REHBER',
              style: TextStyle(
                color:
                    _selectedUserType == 'rehber' ? Colors.white : chipText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordConfirm = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final scaffoldBg = isDark ? theme.scaffoldBackgroundColor : backgroundColor;
    final inputBg = isDark ? Colors.grey[900]! : Colors.white;
    final inputText = isDark ? Colors.white : textColor;
    final hintText = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? darkGreen : primaryColor;
    final chipSelected = isDark ? darkGreen : primaryColor;
    final chipBg = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final chipText = isDark ? Colors.white : Colors.black87;
    final buttonBg = darkGreen;
    final buttonText = Colors.white;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText:
            isPassword
                ? _obscureText
                : (isPasswordConfirm ? _obscureTextConfirm : false),
        keyboardType: keyboardType,
        style: TextStyle(color: inputText),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: borderColor),
          hintStyle: TextStyle(color: hintText),
          suffixIcon:
              (isPassword || isPasswordConfirm)
                  ? IconButton(
                    icon: Icon(
                      (isPassword ? _obscureText : _obscureTextConfirm)
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: borderColor,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isPassword) {
                          _obscureText = !_obscureText;
                        } else {
                          _obscureTextConfirm = !_obscureTextConfirm;
                        }
                      });
                    },
                  )
                  : null,
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      children: [
        const Text('Cinsiyet', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 20),
        Radio<String>(
          value: 'Erkek',
          groupValue: _selectedGender,
          onChanged: (value) => setState(() => _selectedGender = value),
          activeColor: primaryColor,
        ),
        const Text('Erkek'),
        const SizedBox(width: 20),
        Radio<String>(
          value: 'Kadın',
          groupValue: _selectedGender,
          onChanged: (value) => setState(() => _selectedGender = value),
          activeColor: primaryColor,
        ),
        const Text('Kadın'),
      ],
    );
  }

  Widget _buildRehberSpecificFields() {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Kendinizi Tanıtın Alanı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Kendinizi Tanıtın',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message:
                        'Turistlere sizi önerirken kullanacağımız ve profilinizi ziyaret eden turistlerin göreceği metin',
                    child: const Icon(
                      Icons.info_outline,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _selfIntroductionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Kendinizi en az 100 karakter ile tanıtın...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen kendinizi tanıtın';
                  }
                  if (value.length < 100) {
                    return 'Tanıtımınız en az 100 karakter olmalıdır';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Hizmet Verilen Şehirler Alanı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hizmet Verebileceğiniz Şehirler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            if (_selectedServiceCities.length ==
                                (_showAllCities
                                    ? _cities.length
                                    : _popularCities.length)) {
                              _selectedServiceCities.clear();
                            } else {
                              _selectedServiceCities =
                                  (_showAllCities ? _cities : _popularCities)
                                      .toSet();
                            }
                          });
                        },
                        icon: Icon(
                          _selectedServiceCities.length ==
                                  (_showAllCities
                                      ? _cities.length
                                      : _popularCities.length)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: primaryColor,
                        ),
                        label: Text(
                          'Tümünü Seç',
                          style: TextStyle(color: primaryColor),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showAllCities = !_showAllCities;
                          });
                        },
                        icon: Icon(
                          _showAllCities
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: primaryColor,
                        ),
                        tooltip:
                            _showAllCities
                                ? 'Popüler Şehirleri Göster'
                                : 'Tüm Şehirleri Göster',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Lütfen hizmet verebileceğiniz şehirleri seçin.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children:
                    (_showAllCities ? _cities : _popularCities).map((city) {
                      final isSelected = _selectedServiceCities.contains(city);
                      return ChoiceChip(
                        label: Text(city),
                        selected: isSelected,
                        selectedColor: primaryColor,
                        backgroundColor: Colors.grey[300],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedServiceCities.add(city);
                            } else {
                              _selectedServiceCities.remove(city);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
              if (_isFormSubmitted && _selectedServiceCities.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Lütfen en az bir şehir seçiniz.',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Konuşulan Diller Alanı
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Konuştuğunuz Diller',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Lütfen tur düzenleyebileceğiniz dilleri seçin.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children:
                    _languages.map((language) {
                      final isSelected = _selectedLanguages.contains(language);
                      return ChoiceChip(
                        label: Text(language),
                        selected: isSelected,
                        selectedColor: primaryColor,
                        backgroundColor: Colors.grey[300],
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedLanguages.add(language);
                            } else {
                              _selectedLanguages.remove(language);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
              if (_isFormSubmitted && _selectedLanguages.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Lütfen en az bir dil seçiniz.',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTuristSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Sizi yakından tanımak istiyoruz',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Lütfen ilgi alanlarınıza giren en az 3 tur kategorisi seçin.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children:
              _tourCategories.map((category) {
                final isSelected = _selectedTourCategories.contains(category);
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: primaryColor,
                  backgroundColor: Colors.grey[300],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTourCategories.add(category);
                      } else {
                        _selectedTourCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
        ),
        if (_isFormSubmitted && _selectedTourCategories.length < 3)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Lütfen en az 3 tur kategorisi seçiniz.',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _profileImageBytes = bytes;
            // Web platformu için File nesnesi oluşturmaya gerek yok
            if (!kIsWeb) {
              _profileImage = File(pickedFile.path);
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fotoğraf başarıyla seçildi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Fotoğraf seçilirken bir hata oluştu';
        if (e.toString().contains('permission')) {
          errorMessage = 'Lütfen gerekli izinleri verin';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: () {
                if (mounted) {
                  _showImageSourceDialog();
                }
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _showImageSourceDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Fotoğraf Seç'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: primaryColor),
                  title: const Text('Kamera ile Çek'),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: primaryColor),
                  title: const Text('Galeriden Seç'),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('İptal', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  Widget _buildProfilePhoto() {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child:
                    _profileImageBytes != null
                        ? Image.memory(
                          _profileImageBytes!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.person, size: 40, color: Colors.grey),
                              SizedBox(height: 4),
                              Text(
                                'Fotoğraf Ekle',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
          ),
          if (!_isPickingImage)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.add_a_photo,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          if (_isPickingImage)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);
    final cardColor = isDark ? theme.cardColor : Colors.white;
    final scaffoldBg = isDark ? theme.scaffoldBackgroundColor : backgroundColor;
    final inputBg = isDark ? Colors.grey[900]! : Colors.white;
    final inputText = isDark ? Colors.white : textColor;
    final hintText = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final borderColor = isDark ? darkGreen : primaryColor;
    final chipSelected = isDark ? darkGreen : primaryColor;
    final chipBg = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final chipText = isDark ? Colors.white : Colors.black87;
    final buttonBg = darkGreen;
    final buttonText = Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildUserTypeSelector(),
                  const SizedBox(height: 30),

                  // Profil Fotoğrafı (Sadece rehber için)
                  if (_selectedUserType == 'rehber') ...[
                    _buildProfilePhoto(),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Profil Fotoğrafı Ekleyin',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Ad ve Soyad
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          hint: 'Ad',
                          controller: _adController,
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen adınızı giriniz';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInputField(
                          hint: 'Soyad',
                          controller: _soyadController,
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen soyadınızı giriniz';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // TC Kimlik No (Sadece rehber için)
                  if (_selectedUserType == 'rehber')
                    _buildInputField(
                      hint: 'TC Kimlik No',
                      controller: _tcKimlikController,
                      icon: Icons.credit_card,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen TC Kimlik numaranızı giriniz';
                        }
                        if (value.length != 11) {
                          return 'TC Kimlik numarası 11 haneli olmalıdır';
                        }
                        return null;
                      },
                    ),
                  if (_selectedUserType == 'rehber') const SizedBox(height: 20),

                  // Ruhsat No (Sadece rehber için)
                  if (_selectedUserType == 'rehber')
                    _buildInputField(
                      hint: 'Rehber Ruhsat No',
                      controller: _ruhsatNoController,
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen rehber ruhsat numaranızı giriniz';
                        }
                        if (value.length < 6) {
                          return 'Ruhsat numarası en az 6 haneli olmalıdır';
                        }
                        return null;
                      },
                    ),
                  if (_selectedUserType == 'rehber') const SizedBox(height: 20),

                  _buildInputField(
                    hint: 'E-Posta',
                    controller: _emailController,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen e-posta adresinizi giriniz';
                      }
                      if (!value.contains('@')) {
                        return 'Geçerli bir e-posta adresi giriniz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    hint: 'Parola',
                    controller: _passwordController,
                    icon: Icons.lock,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen parolanızı giriniz';
                      }
                      if (value.length < 6) {
                        return 'Parola en az 6 karakter olmalıdır';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    hint: 'Parolanızı Tekrar Giriniz',
                    controller: _passwordConfirmController,
                    icon: Icons.lock,
                    isPasswordConfirm: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen parolanızı tekrar giriniz';
                      }
                      if (value != _passwordController.text) {
                        return 'Parolalar eşleşmiyor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Telefon
                  Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCountryCode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 0,
                            ),
                          ),
                          items:
                              _countryCodes.map((country) {
                                return DropdownMenuItem<String>(
                                  value: country['code'],
                                  child: Text(country['code']!),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCountryCode = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _buildInputField(
                          hint: 'Telefon Numaranız',
                          controller: _phoneController,
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen telefon numaranızı giriniz';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _birthDateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Doğum Tarihiniz',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(
                        Icons.calendar_today,
                        color: primaryColor,
                      ),
                    ),
                    onTap: () async {
                      FocusScope.of(
                        context,
                      ).requestFocus(FocusNode()); // Klavyeyi kapat
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        locale: const Locale('tr', 'TR'),
                      );
                      if (pickedDate != null) {
                        String formattedDate =
                            "${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}";
                        setState(() {
                          _birthDateController.text = formattedDate;
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen doğum tarihinizi giriniz';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildGenderSelection(),
                  const SizedBox(height: 20),

                  // Rehbere özel alanlar
                  if (_selectedUserType == 'rehber')
                    _buildRehberSpecificFields(),

                  // Turiste özel alanlar
                  if (_selectedUserType == 'turist')
                    _buildTuristSpecificFields(),

                  const SizedBox(height: 30),

                  // Kaydet Butonu
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed:
                          _isSaving
                              ? null
                              : () {
                                if (_formKey.currentState!.validate()) {
                                  kaydet();
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child:
                          _isSaving
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Kaydet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _tcKimlikController.dispose();
    _ruhsatNoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _selfIntroductionController.dispose();
    super.dispose();
  }

  // Doğrulama kodu dialog widget'ı
  Future<bool> _showVerificationDialog() {
    final TextEditingController codeController = TextEditingController();
    bool isVerified = false;
    final FocusNode focusNode = FocusNode();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('E-posta Doğrulama'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'E-posta adresinize gönderilen 6 haneli doğrulama kodunu giriniz.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: codeController,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: '------',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  // Sadece sayı girişine izin ver
                  if (value.isNotEmpty) {
                    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                    if (value != numericValue) {
                      codeController.text = numericValue;
                      codeController.selection = TextSelection.fromPosition(
                        TextPosition(offset: numericValue.length),
                      );
                    }
                  }
                  
                  // 6 karakter girildiğinde otomatik doğrula
                  if (value.length == 6) {
                    if (value == _verificationCode) {
                      isVerified = true;
                      Navigator.of(context).pop(true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Doğrulama kodu hatalı!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      codeController.clear();
                      focusNode.requestFocus();
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (codeController.text == _verificationCode) {
                  isVerified = true;
                  Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Doğrulama kodu hatalı!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  codeController.clear();
                  focusNode.requestFocus();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: const Text('Doğrula'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void kaydet() async {
    setState(() {
      _isFormSubmitted = true;
    });

    if (_userKeys == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kullanıcı bilgileri oluşturulamadı. Lütfen tekrar deneyin.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate required selections
    if (_selectedUserType == 'rehber') {
      if (_selectedServiceCities.isEmpty || _selectedLanguages.isEmpty) {
        return;
      }
    } else if (_selectedUserType == 'turist') {
      if (_selectedTourCategories.length < 3) {
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Encrypt all data
      encryptedAd = EncryptionHelper.encryptUserData(
        _adController.text,
        _userKeys!['key'],
        _userKeys!['iv'],
      );
      encryptedSoyad = EncryptionHelper.encryptUserData(
        _soyadController.text,
        _userKeys!['key'],
        _userKeys!['iv'],
      );
      encryptedEmail = EncryptionHelper.encryptUserData(
        _emailController.text,
        _userKeys!['key'],
        _userKeys!['iv'],
      );
      encryptedPassword = EncryptionHelper.encryptUserData(
        _passwordController.text,
        _userKeys!['key'],
        _userKeys!['iv'],
      );
      encryptedPhone = EncryptionHelper.encryptUserData(
        _phoneController.text,
        _userKeys!['key'],
        _userKeys!['iv'],
      );
      encryptedBirthDate = EncryptionHelper.encryptUserData(
        _birthDateController.text,
        _userKeys!['key'],
        _userKeys!['iv'],
      );
      encryptedGender = EncryptionHelper.encryptUserData(
        _selectedGender ?? '',
        _userKeys!['key'],
        _userKeys!['iv'],
      );

      if (_selectedUserType == "rehber") {
        encryptedTC = EncryptionHelper.encryptUserData(
          _tcKimlikController.text.trim(),
          _userKeys!['key'],
          _userKeys!['iv'],
        );
        encryptedRuhsatNo = EncryptionHelper.encryptUserData(
          _ruhsatNoController.text.trim(),
          _userKeys!['key'],
          _userKeys!['iv'],
        );
      }

      // 6 haneli rastgele doğrulama kodu oluştur
      _verificationCode = (100000 + Random().nextInt(900000)).toString();

      // Önce e-posta doğrulama işlemi
      final functions = FirebaseFunctions.instanceFor(
        region: 'europe-west1',
      );
      final callable = functions.httpsCallable(
        'sendUserWelcomeEmail',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );

      final fullName = '${_adController.text} ${_soyadController.text}'.trim();
      final userEmail = _emailController.text.trim();

      final Map<String, dynamic> emailData = {
        'recipientName': fullName,
        'userType': _selectedUserType,
        'userEmail': userEmail,
        'verificationCode': _verificationCode,
      };

      // E-posta gönderme işlemi
      final emailResponse = await callable.call(emailData);
      debugPrint('E-posta gönderme başarılı: ${emailResponse.data}');

      // Doğrulama dialog'unu göster
      final isVerified = await _showVerificationDialog();

      if (!isVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doğrulama işlemi iptal edildi.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Doğrulama başarılı ise kayıt işlemini gerçekleştir
      await _add();

      // Admin bildirimi gönder
      final adminCallable = functions.httpsCallable(
        'sendAdminNotification',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
      );

      // Admin bildirimi için veri hazırla
      final Map<String, dynamic> adminData = {
        'recipientName': fullName,
        'userType': _selectedUserType,
        'userEmail': userEmail,
      };

      // Rehber ise TC ve ruhsat no ekle
      if (_selectedUserType == 'rehber') {
        adminData['tcKimlikNo'] = _tcKimlikController.text.trim();
        adminData['ruhsatNo'] = _ruhsatNoController.text.trim();
      }

      await adminCallable.call(adminData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kayıt başarıyla tamamlandı!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'İşlem sırasında bir hata oluştu';
        
        if (e is FirebaseFunctionsException) {
          errorMessage = 'E-posta gönderme hatası: ${e.message}';
        } else if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'Bu e-posta adresi zaten kullanımda';
              break;
            case 'invalid-email':
              errorMessage = 'Geçersiz e-posta adresi';
              break;
            case 'operation-not-allowed':
              errorMessage = 'E-posta/şifre girişi etkin değil';
              break;
            case 'weak-password':
              errorMessage = 'Şifre çok zayıf';
              break;
            default:
              errorMessage = 'Kimlik doğrulama hatası: ${e.message}';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _add() async {
    try {
      // 1. ADIM: Önce Firebase Auth ile kullanıcıyı oluştur ve gerçek UID'yi al.
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. ADIM: Auth'dan gelen UID'yi al ve state'e ata. Bu artık bizim tekil ve kalıcı kimliğimiz.
      final String authUid = userCredential.user!.uid;
      _userId = authUid;

      // 3. ADIM: Profil fotoğrafı yükleme (sadece rehber için), artık doğru UID'yi kullanacak.
      String? profilePhotoUrl;
      if (_selectedUserType == "rehber" && _profileImageBytes != null) {
        profilePhotoUrl = await _uploadProfilePhoto();
      }

      // 4. ADIM: Kullanıcı verilerini hazırla. Bu fonksiyonlar artık doğru _userId'yi (yani authUid) kullanacak.
      final userData = _selectedUserType == "turist"
          ? _prepareTouristData()
          : _prepareGuideData(profilePhotoUrl);

      // 5. ADIM (EN ÖNEMLİ DEĞİŞİKLİK): Verileri Firebase'e UID'yi anahtar olarak kullanarak kaydet.
      final dbRef = FirebaseDatabase.instance.ref();
      final userNode =
          _selectedUserType == "turist" ? "turistler" : "rehberler";
      await dbRef.child(userNode).child(authUid).set(userData);

      print(
        '${_selectedUserType == "turist" ? "Turist" : "Rehber"} başarıyla kaydedildi. UID: $authUid',
      );
    } catch (e) {
      _handleError(e);
    }
  }

  // Profil fotoğrafı yükleme
  Future<String?> _uploadProfilePhoto() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profil_fotolari')
          .child('$_userId.jpg');

      final uploadTask = await storageRef.putData(
        _profileImageBytes!,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': _userId!},
        ),
      );

      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Profil fotoğrafı yüklenirken hata: $e');
      rethrow;
    }
  }

  // Turist verilerini hazırla
  Map<String, dynamic> _prepareTouristData() {
    return {
      'id': _userId,
      'isim': _adController.text,
      'soyisim': _soyadController.text,
      'email': _emailController.text,
      'telefon': encryptedPhone,
      'dogumgunu': encryptedBirthDate,
      'cinsiyet': _selectedGender,
      'hakkında': _selectedTourCategories.toList(),
      'iv': _userKeys!['iv'],
    };
  }

  // Rehber verilerini hazırla
  Map<String, dynamic> _prepareGuideData(String? profilePhotoUrl) {
    return {
      'id': _userId,
      'isim': _adController.text,
      'soyisim': _soyadController.text,
      'email': _emailController.text,
      'telefon': encryptedPhone,
      'dogumgunu': encryptedBirthDate,
      'cinsiyet': _selectedGender,
      'tc': encryptedTC,
      'ruhsatNo': encryptedRuhsatNo,
      'hakkinda': _selfIntroductionController.text,
      'hizmetVerilenSehirler': _selectedServiceCities.toList(),
      'konusulanDiller': _selectedLanguages.toList(),
      'iv': _userKeys!['iv'],
      'puan': '4.7',
      'profilfoto': profilePhotoUrl ?? '',
      'turlarim': [],
    };
  }

  // Hata yönetimi
  void _handleError(dynamic e) {
    print('Kayıt sırasında detaylı hata: $e');
    if (mounted) {
      String errorMessage = 'Kayıt sırasında bir hata oluştu';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Bu e-posta adresi zaten kullanımda';
            break;
          case 'invalid-email':
            errorMessage = 'Geçersiz e-posta adresi';
            break;
          case 'operation-not-allowed':
            errorMessage = 'E-posta/şifre girişi etkin değil';
            break;
          case 'weak-password':
            errorMessage = 'Şifre çok zayıf';
            break;
          default:
            errorMessage = 'Kimlik doğrulama hatası: ${e.message}';
        }
      } else if (e is Exception) {
        errorMessage = 'Sistem hatası: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
