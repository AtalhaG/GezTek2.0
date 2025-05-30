import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';

class AddTourPage extends StatefulWidget {
  const AddTourPage({super.key});

  @override
  State<AddTourPage> createState() => _AddTourPageState();
}

class _AddTourPageState extends State<AddTourPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tourNameController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _maxParticipantsController =
      TextEditingController();
  final TextEditingController _meetingLocationController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedCity;
  String? _selectedLanguage;
  String? _selectedCategory;
  DateTime? _selectedDate;
  List<String> routes = [];
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages = [];
  bool _isSaving = false;

  final List<String> _cities = [
    'Adana',
    'Adıyaman',
    'Afyonkarahisar',
    'Ağrı',
    'Amasya',
    'Ankara',
    'Antalya',
    'Artvin',
    'Aydın',
    'Balıkesir',
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
    'Edirne',
    'Elazığ',
    'Erzincan',
    'Erzurum',
    'Eskişehir',
    'Gaziantep',
    'Giresun',
    'Gümüşhane',
    'Hakkari',
    'Hatay',
    'Isparta',
    'Mersin',
    'İstanbul',
    'İzmir',
    'Kars',
    'Kastamonu',
    'Kayseri',
    'Kırklareli',
    'Kırşehir',
    'Kocaeli',
    'Konya',
    'Kütahya',
    'Malatya',
    'Manisa',
    'Kahramanmaraş',
    'Mardin',
    'Muğla',
    'Muş',
    'Nevşehir',
    'Niğde',
    'Ordu',
    'Rize',
    'Sakarya',
    'Samsun',
    'Siirt',
    'Sinop',
    'Sivas',
    'Tekirdağ',
    'Tokat',
    'Trabzon',
    'Tunceli',
    'Şanlıurfa',
    'Uşak',
    'Van',
    'Yozgat',
    'Zonguldak',
    'Aksaray',
    'Bayburt',
    'Karaman',
    'Kırıkkale',
    'Batman',
    'Şırnak',
    'Bartın',
    'Ardahan',
    'Iğdır',
    'Yalova',
    'Karabük',
    'Kilis',
    'Osmaniye',
    'Düzce',
  ];

  final List<String> _categories = [
    'Kültür Turu',
    'Doğa Turu',
    'Gastronomi Turu',
    'Fotoğraf Turu',
    'Tarih Turu',
    'Yürüyüş Turu',
  ];

  final List<String> _languages = [
    'Türkçe',
    'İngilizce (English)',
    'Almanca (Deutsch)',
    'Fransızca (Français)',
    'İspanyolca (Español)',
    'İtalyanca (Italiano)',
    'Rusça (Русский)',
    'Arapça (العربية)',
    'Japonca (日本語)',
    'Çince (中文)',
    'Korece (한국어)',
    'Portekizce (Português)',
    'Hollandaca (Nederlands)',
    'Lehçe (Polski)',
    'İsveççe (Svenska)',
  ];

  @override
  void dispose() {
    _tourNameController.dispose();
    _routeController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    _meetingLocationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _addRoute() {
    if (_routeController.text.isNotEmpty) {
      setState(() {
        routes.add(_routeController.text);
        _routeController.clear();
      });
    }
  }

  void _saveTour() async {
    if (_formKey.currentState!.validate()) {
      if (_isSaving) return;

      setState(() {
        _isSaving = true;
      });

      try {
        // Rehber ID'sini al
        final args = ModalRoute.of(context)?.settings.arguments;
        print('Arguments received: $args'); // Debug log

        if (args == null) {
          print('Arguments is null'); // Debug log
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rehber bilgisi bulunamadı. Lütfen tekrar giriş yapın.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final rehberId = args is Map<String, dynamic> ? args['userId'] as String? : null;
        print('Rehber ID: $rehberId'); // Debug log

        if (rehberId == null || rehberId.isEmpty) {
          print('Rehber ID is null or empty'); // Debug log
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Geçerli bir rehber ID\'si bulunamadı. Lütfen tekrar giriş yapın.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Fotoğrafları yükle
        List<String> uploadedImageUrls = [];
        if (_selectedImages != null && _selectedImages!.isNotEmpty) {
          for (var image in _selectedImages!) {
            try {
              // Benzersiz bir dosya adı oluştur
              final fileName = 'turlar/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
              final ref = FirebaseStorage.instance.ref().child(fileName);
              
              // Dosyayı yükle
              final bytes = await image.readAsBytes();
              await ref.putData(bytes);
              
              // Download URL'yi al
              final downloadUrl = await ref.getDownloadURL();
              uploadedImageUrls.add(downloadUrl);
              
              print('Image uploaded successfully: $downloadUrl');
            } catch (e) {
              print('Error uploading image: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Fotoğraf yüklenirken hata oluştu: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              setState(() {
                _isSaving = false;
              });
              return;
            }
          }
        }

        // Tur verilerini hazırla
        final tourData = {
          'turAdi': _tourNameController.text,
          'rotalar': routes,
          'fiyat': _priceController.text,
          'sure': _durationController.text,
          'kategori': _selectedCategory,
          'maxKatilimci': _maxParticipantsController.text,
          'bulusmaKonumu': _meetingLocationController.text,
          'sehir': _selectedCity,
          'dil': _selectedLanguage,
          'tarih': _dateController.text,
          'olusturmaTarihi': DateTime.now().toIso8601String(),
          'resim': uploadedImageUrls.isNotEmpty ? uploadedImageUrls[0] : '', // Ana resim
          'resimler': uploadedImageUrls, // Tüm resimler
        };
        print('Tour data prepared: $tourData'); // Debug log

        // Önce turu kaydet
        final response = await http.post(
          Uri.parse(
            'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/turlar.json',
          ),
          body: json.encode(tourData),
        );
        print('Tour save response status: ${response.statusCode}'); // Debug log
        print('Tour save response body: ${response.body}'); // Debug log

        if (response.statusCode == 200) {
          // Tur ID'sini al
          final responseData = json.decode(response.body);
          final turId = responseData['name']; // Firebase'in otomatik oluşturduğu ID
          print('Tour ID created: $turId'); // Debug log

          // Önce rehberin mevcut bilgilerini al
          final rehberResponse = await http.get(
            Uri.parse(
              'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/rehberler.json',
            ),
          );
          print('Guide fetch response status: ${rehberResponse.statusCode}'); // Debug log
          print('Guide fetch response body: ${rehberResponse.body}'); // Debug log

          if (rehberResponse.statusCode == 200) {
            final rehberler = json.decode(rehberResponse.body) as Map<String, dynamic>;
            print('All guides: $rehberler'); // Debug log

            // Rehberi bul
            String? rehberKey;
            rehberler.forEach((key, value) {
              print('Checking guide key: $key, value: $value'); // Debug log
              if (value['id'] == rehberId) {
                rehberKey = key;
                print('Found guide key: $rehberKey'); // Debug log
              }
            });

            if (rehberKey != null) {
              // Rehberin mevcut turlarını al
              final rehber = rehberler[rehberKey] as Map<String, dynamic>;
              List<String> turlarim = [];

              // Eğer turlarim alanı varsa ve bir liste ise, mevcut turları al
              if (rehber['turlarim'] != null) {
                if (rehber['turlarim'] is List) {
                  turlarim = List<String>.from(rehber['turlarim']);
                } else if (rehber['turlarim'] is String) {
                  // Eğer tek bir tur varsa, onu listeye ekle
                  turlarim.add(rehber['turlarim']);
                }
              }
              print('Current tours: $turlarim'); // Debug log

              // Yeni tur ID'sini listeye ekle (eğer zaten yoksa)
              if (!turlarim.contains(turId)) {
                turlarim.add(turId);
                print('Added new tour ID: $turId'); // Debug log
              } else {
                print('Tour ID already exists: $turId'); // Debug log
              }

              // Rehberin turlarim alanını güncelle
              final rehberTurlarResponse = await http.patch(
                Uri.parse(
                  'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/rehberler/$rehberKey.json',
                ),
                body: json.encode({
                  'turlarim': turlarim,
                }),
              );
              print('Guide update response status: ${rehberTurlarResponse.statusCode}'); // Debug log
              print('Guide update response body: ${rehberTurlarResponse.body}'); // Debug log

              if (rehberTurlarResponse.statusCode == 200) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tur başarıyla kaydedildi!'),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                  // Başarılı kayıt sonrası ana sayfaya dön
                  Navigator.pop(context);
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tur rehber listesine eklenirken bir hata oluştu',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } else {
              print('Guide not found with ID: $rehberId'); // Debug log
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Rehber bulunamadı'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Rehber bilgileri alınamadı'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tur kaydedilirken bir hata oluştu'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotoğraf seçilirken bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E7D32),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Üst Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/geztek.jpg', height: 40),
                      const Text(
                        'Yeni Tur Ekle',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tur Detayları',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Tur Adı
                        const Text(
                          'Tur Adı',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _tourNameController,
                          decoration: InputDecoration(
                            hintText: 'Tur adını girin',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Rotalar
                        const Text(
                          'Rotalar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: [
                            TextFormField(
                              controller: _routeController,
                              decoration: InputDecoration(
                                hintText: 'Rotayı girin',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: _addRoute,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Yeni Rota Ekle',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (routes.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Eklenen Rotalar',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...routes.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final route = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${index + 1}. $route',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    routes.removeAt(index);
                                                  });
                                                },
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Fiyat
                        const Text(
                          'Fiyat',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Fiyatı girin',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tur Süresi
                        const Text(
                          'Tur Süresi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _durationController,
                          decoration: InputDecoration(
                            hintText: 'Tur süresini girin',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tur Kategorisi
                        const Text(
                          'Tur Kategorisi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('Tur Tipi'),
                              value: _selectedCategory,
                              items:
                                  _categories.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Maksimum Katılımcı Sayısı
                        const Text(
                          'Maksimum Katılımcı Sayısı',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _maxParticipantsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Maksimum katılımcı sayısını girin',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Buluşma Konumu
                        const Text(
                          'Buluşma Konumu',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _meetingLocationController,
                          decoration: InputDecoration(
                            hintText: 'Buluşma konumunu girin',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Şehir
                        const Text(
                          'Şehir',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('İl Seçiniz'),
                              value: _selectedCity,
                              items:
                                  _cities.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedCity = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tur Dili
                        const Text(
                          'Tur Dili',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('Dil Seçiniz'),
                              value: _selectedLanguage,
                              items:
                                  _languages.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedLanguage = newValue;
                                });
                              },
                            ),
                          ),
                        ),

                        // Tur Tarihi
                        const SizedBox(height: 20),
                        const Text(
                          'Tur Tarihi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          onTap: _selectDate,
                          decoration: InputDecoration(
                            hintText: 'Tur tarihini seçin',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: Icon(
                              Icons.calendar_today,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Fotoğraf Yükleme Bölümü
                        const SizedBox(height: 20),
                        const Text(
                          'Tur Fotoğrafları',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: _pickImages,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2E7D32),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.photo_library,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Fotoğraf Seç',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_selectedImages != null &&
                                  _selectedImages!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    '${_selectedImages!.length} fotoğraf seçildi',
                                    style: const TextStyle(
                                      color: Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Kaydet Butonu
                        const SizedBox(height: 40),
                        Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isSaving ? null : _saveTour,
                              borderRadius: BorderRadius.circular(12),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.save_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Turu Kaydet',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
