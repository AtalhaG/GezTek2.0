import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class KayitOl extends StatefulWidget {
  const KayitOl({Key? key}) : super(key: key);

  @override
  State<KayitOl> createState() => _KayitOlState();
}

class _KayitOlState extends State<KayitOl> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _tcKimlikController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  bool _obscureText = true;
  bool _obscureTextConfirm = true;
  String _selectedUserType = 'turist'; // 'turist' veya 'rehber'
  String? _selectedGender;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;
  PlatformFile? _criminalRecordFile;
  PlatformFile? _guideCertificateFile;

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

  Widget _buildUserTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _selectedUserType = 'turist'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedUserType == 'turist' ? primaryColor : Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'TURİST',
              style: TextStyle(
                color: _selectedUserType == 'turist' ? Colors.white : Colors.black,
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
              backgroundColor: _selectedUserType == 'rehber' ? primaryColor : Colors.grey[300],
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'REHBER',
              style: TextStyle(
                color: _selectedUserType == 'rehber' ? Colors.white : Colors.black,
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
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscureText : (isPasswordConfirm ? _obscureTextConfirm : false),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: primaryColor),
          suffixIcon: (isPassword || isPasswordConfirm) ? IconButton(
            icon: Icon(
              (isPassword ? _obscureText : _obscureTextConfirm) ? Icons.visibility : Icons.visibility_off,
              color: primaryColor,
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
          ) : null,
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

  Future<void> _pickCriminalRecordFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _criminalRecordFile = result.files.first;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sabıka kaydı dosyası seçildi: ${_criminalRecordFile!.name}'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _pickGuideCertificateFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _guideCertificateFile = result.files.first;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rehber belgesi seçildi: ${_guideCertificateFile!.name}'), backgroundColor: Colors.green),
      );
    }
  }

  Widget _buildRehberSpecificFields() {
    return Column(
      children: [
        const SizedBox(height: 20),
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
                  const Icon(Icons.upload_file, color: primaryColor),
                  const SizedBox(width: 10),
                  const Text(
                    'Sabıka Kaydı Dosyanızı Yükleyin',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _pickCriminalRecordFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Yükle'),
                  ),
                ],
              ),
              if (_criminalRecordFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Seçilen dosya: ${_criminalRecordFile!.name}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
                  const Icon(Icons.upload_file, color: primaryColor),
                  const SizedBox(width: 10),
                  const Text(
                    'Rehber Belgenizi Yükleyin',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _pickGuideCertificateFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Yükle'),
                  ),
                ],
              ),
              if (_guideCertificateFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Seçilen dosya: ${_guideCertificateFile!.name}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return; // Prevent multiple simultaneous picks

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
        setState(() {
          _profileImage = File(pickedFile.path);
        });
        if (mounted) {
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
              onPressed: () => _showImageSourceDialog(),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fotoğraf Seç'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: primaryColor),
              title: const Text('Kamera ile Çek'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: primaryColor),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? Column(
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
                      )
                    : null,
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
                  child: const Icon(Icons.add_a_photo, color: Colors.white, size: 20),
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
    return Scaffold(
      backgroundColor: backgroundColor,
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
                  
                  // Profil Fotoğrafı
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
                  if (_selectedUserType == 'rehber')
                    const SizedBox(height: 20),

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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          ),
                          items: _countryCodes.map((country) {
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
                      prefixIcon: Icon(Icons.calendar_today, color: primaryColor),
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode()); // Klavyeyi kapat
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
                  if (_selectedUserType == 'rehber') _buildRehberSpecificFields(),

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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Kayıt işlemleri burada yapılacak
                          print('Kayıt türü: $_selectedUserType');
                          print('Ad: ${_adController.text}');
                          print('Soyad: ${_soyadController.text}');
                          print('E-posta: ${_emailController.text}');
                          print('Telefon: ${_phoneController.text}');
                          print('Doğum Tarihi: ${_birthDateController.text}');
                          print('Cinsiyet: $_selectedGender');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
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
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}
