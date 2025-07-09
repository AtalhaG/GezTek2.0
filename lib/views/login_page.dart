import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'kayit_ol.dart';
import 'anasayfa_flutter.dart';
import 'forgot_pass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../providers/user_provider.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
                  '${l10n.welcomeMessage} ${userProvider.currentUser!.fullName}!',
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
        String errorMessage = l10n.checkEmailPassword;
        if (e.code == 'user-not-found') {
          errorMessage = l10n.userNotFound;
        } else if (e.code == 'wrong-password') {
          errorMessage = l10n.wrongPassword;
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
              content: Text('${l10n.loginError}: ${e.toString()}'),
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
    final l10n = AppLocalizations.of(context)!;
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterEmail),
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
          SnackBar(
            content: Text(l10n.passwordResetSent),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.passwordResetFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkGreen = const Color(0xFF22543D);
    final cardColor =
        isDark ? theme.cardColor : const Color.fromRGBO(205, 229, 210, 1);
    final scaffoldBg =
        isDark
            ? theme.scaffoldBackgroundColor
            : const Color.fromARGB(255, 252, 251, 251);
    final inputBg = isDark ? Colors.grey[900]! : Colors.white;
    final inputBorder =
        isDark ? darkGreen : const Color.fromARGB(255, 18, 61, 21);
    final inputText =
        isDark ? Colors.white : const Color.fromARGB(255, 18, 61, 21);
    final hintText =
        isDark ? Colors.grey[400]! : const Color.fromARGB(255, 18, 61, 21);
    final buttonBg = darkGreen;
    final buttonText = Colors.white;
    return Scaffold(
      backgroundColor: scaffoldBg,
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
                      color: inputBg,
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
                      color: cardColor,
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
                            color: inputBg,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: inputBorder),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: l10n.email,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              hintStyle: TextStyle(color: hintText),
                            ),
                            style: TextStyle(color: inputText),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterEmail;
                              }
                              if (!value.contains('@')) {
                                return l10n.enterValidEmail;
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
                            color: inputBg,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: inputBorder),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: l10n.password,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                              hintStyle: TextStyle(color: hintText),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: inputText,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            style: TextStyle(color: inputText),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.pleaseEnterPassword;
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPassPage(),
                                ),
                              );
                            },
                            child: Text(
                              l10n.forgotPassword,
                              style: TextStyle(color: inputText, fontSize: 12),
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
                                  backgroundColor: buttonBg,
                                  foregroundColor: buttonText,
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
                                        : Text(
                                          l10n.login,
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
                                  backgroundColor: buttonBg,
                                  foregroundColor: buttonText,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  l10n.register,
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

  Widget _socialButton(String imageUrl, Color inputBg) {
    return Container(
      width: 50,
      height: 50,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: inputBg,
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
