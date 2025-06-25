import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'kayit_ol.dart';
import 'anasayfa_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Firebase Auth ile giriş yap
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        final user = userCredential.user;
        if (user != null && mounted) {
          // UserProvider'ı kullanarak kullanıcı bilgilerini ayarla
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          await userProvider.setUserFromFirebaseAuth(user);

          if (userProvider.currentUser != null) {
            // Başarılı giriş mesajı
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Hoş geldiniz ${userProvider.currentUser!.fullName}!',
                ),
                backgroundColor: Colors.green,
              ),
            );

            // Ana sayfaya yönlendir - artık UserProvider bilgileri var
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AnaSayfaFlutter()),
            );
          } else {
            throw Exception('Kullanıcı bilgileri yüklenemedi');
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'E-posta veya şifrenizi kontrol edin!';
        if (e.code == 'user-not-found') {
          errorMessage = 'Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Hatalı şifre girdiniz.';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Giriş hatası: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen e-posta adresinizi girin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Şifre sıfırlama bağlantısı e-posta adresinize gönderildi',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Şifre sıfırlama işlemi başarısız: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                        // E-posta TextField
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
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'E-posta',
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
                                return 'Lütfen e-posta adresinizi girin';
                              }
                              if (!value.contains('@')) {
                                return 'Geçerli bir e-posta adresi girin';
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
                            onPressed: _resetPassword,
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
                                onPressed: _isLoading ? null : _signIn,
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
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
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
