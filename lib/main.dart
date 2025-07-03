import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'views/anasayfa_flutter.dart';
import 'views/tur_detay.dart';
import 'views/login_page.dart';
import 'views/add_tour_page.dart';
import 'views/rehber_özet.dart';
import 'views/rehber_detay.dart';
import 'views/kayit_ol.dart';
import 'views/settings.dart';
import 'views/message_list.dart';
import 'views/profile_view.dart';
import 'views/seyahatlerim.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
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
              brightness: Brightness.light,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF22543D),
                foregroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              cardColor: Colors.white,
              dialogBackgroundColor: Colors.white,
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black),
                bodyMedium: TextStyle(color: Colors.black87),
                titleLarge: TextStyle(color: Colors.black),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.green,
              scaffoldBackgroundColor: const Color(0xFF181A20),
              brightness: Brightness.dark,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1F222A),
                foregroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.white),
              ),
              cardColor: const Color(0xFF23262F),
              dialogBackgroundColor: const Color(0xFF23262F),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
                titleLarge: TextStyle(color: Colors.white),
              ),
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginPage(),
              '/ana_sayfa': (context) => const AnaSayfaFlutter(),
              '/add_tour': (context) => const AddTourPage(),
              '/profile': (context) => const ProfileView(),
              '/seyahatlerim': (context) => const Seyahatlerim(),
              '/rehber_ozet': (context) => const RehberOzetSayfasi(),
              '/tur_detay': (context) => const TurDetay(),
              '/rehber_detay': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>?;
                final rehberId = args?['rehberId'] as String? ?? '';
                return RehberDetay(rehberId: rehberId);
              },
              '/settings': (context) => const SettingsPage(),
              '/messages': (context) => const MessageList(),
            },
          );
        },
      ),
    );
  }
}
