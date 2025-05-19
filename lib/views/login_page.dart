import 'package:flutter/material.dart';
import 'kayit_ol.dart';
import 'anasayfa_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 251, 251),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Logo
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: const DecorationImage(
                        image: AssetImage('assets/images/geztek.jpg'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // Giriş formu container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(205, 229, 210, 1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Kullanıcı Adı TextField
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color.fromARGB(255, 18, 61, 21),
                            ),
                          ),
                          child: TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              hintText: 'Kullanıcı Adı',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 18, 61, 21),
                              ),
                            ),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 18, 61, 21),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen kullanıcı adınızı girin';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        // Şifre TextField
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color.fromARGB(255, 18, 61, 21),
                            ),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Şifre',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              hintStyle: const TextStyle(
                                color: Color.fromARGB(255, 18, 61, 21),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: const Color.fromARGB(255, 18, 61, 21),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 18, 61, 21),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen şifrenizi girin';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Parolanızı mı unuttunuz?
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Şifre sıfırlama sayfasına yönlendirme
                            },
                            child: const Text(
                              'Parolanızı mı unuttunuz?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 18, 61, 21),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Giriş Yap ve Üye Ol Butonları
                        Row(
                          children: [
                            // Giriş Yap Butonu
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  print('Giriş yap butonuna tıklandı');
                                  if (_formKey.currentState != null &&
                                      _formKey.currentState!.validate()) {
                                    print('Form doğrulaması başarılı');
                                    try {
                                      if (_usernameController.text.isEmpty ||
                                          _passwordController.text.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Lütfen tüm alanları doldurun',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      // Kullanıcıları getir
                                      final usersResponse = await http.get(
                                        Uri.parse(
                                          'https://geztek-17441-default-rtdb.europe-west1.firebasedatabase.app/.json',
                                        ),
                                      );

                                      if (usersResponse.statusCode == 200) {
                                        final usersData = json.decode(usersResponse.body);
                                        bool isAuthenticated = false;
                                        bool isRehber = false;
                                        String userId = '';

                                        if (usersData != null) {
                                          // Önce rehberler içinde ara
                                          if (usersData['rehberler'] != null) {
                                            usersData['rehberler'].forEach((key, value) {
                                              if (value is Map<String, dynamic>) {
                                                final userEmail = value['email']?.toString();
                                                final userPassword = value['sifre']?.toString();

                                                if (userEmail?.toLowerCase() == _usernameController.text.toLowerCase() &&
                                                    userPassword == _passwordController.text) {
                                                  isAuthenticated = true;
                                                  isRehber = true;
                                                  userId = value['id']?.toString() ?? '';
                                                }
                                              }
                                            });
                                          }

                                          // Eğer rehberler içinde bulunamadıysa turistler içinde ara
                                          if (!isAuthenticated && usersData['turistler'] != null) {
                                            usersData['turistler'].forEach((key, value) {
                                              if (value is Map<String, dynamic>) {
                                                final userEmail = value['email']?.toString();
                                                final userPassword = value['sifre']?.toString();

                                                if (userEmail?.toLowerCase() == _usernameController.text.toLowerCase() &&
                                                    userPassword == _passwordController.text) {
                                                  isAuthenticated = true;
                                                  isRehber = false;
                                                  userId = value['id']?.toString() ?? '';
                                                }
                                              }
                                            });
                                          }
                                        }

                                        if (isAuthenticated) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('Giriş başarılı'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                            // Kullanıcı tipini ve ID'sini ana sayfaya gönder
                                            Navigator.pushReplacementNamed(
                                              context,
                                              '/ana_sayfa',
                                              arguments: {
                                                'isRehber': isRehber,
                                                'userId': userId,
                                              },
                                            );
                                          }
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Kullanıcı adı veya şifre yanlış',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Kullanıcı bilgileri alınamadı',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      print('Hata: ${e.toString()}');
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Bir hata oluştu: ${e.toString()}',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    // Form doğrulaması başarısız olduğunda
                                    print('Form doğrulaması başarısız');
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Lütfen tüm alanları doldurun',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    18,
                                    61,
                                    21,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Giriş Yap',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Üye Ol Butonu
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const KayitOl(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    18,
                                    61,
                                    21,
                                  ),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Üye Ol',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          ],
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

  Widget _socialButton(String imageUrl) {
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Image.network(imageUrl),
    );
  }
}
