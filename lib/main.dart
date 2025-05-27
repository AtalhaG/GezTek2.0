import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/anasayfa_flutter.dart';
import 'views/tur_detay.dart';

import 'views/login_page.dart';
import 'views/add_tour_page.dart';
import 'views/rehber_özet.dart';
import 'views/rehber_detay.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GezTek',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', 'TR')],
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F6F9),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/ana_sayfa': (context) => const AnaSayfaFlutter(),
        '/add_tour': (context) => const AddTourPage(),
        '/rehber_ozet': (context) => const RehberOzetSayfasi(),
        '/tur_detay': (context) => const TurDetay(),
        '/rehber_detay': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final rehberId = args?['rehberId'] as String? ?? '';
          return RehberDetay(rehberId: rehberId);
        },
      },
    );
  }
}
