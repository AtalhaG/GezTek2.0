import 'package:flutter/material.dart';
import 'message_list.dart';
import 'settings.dart';

class CustomTopBar extends StatelessWidget {
  final String hintText;
  final void Function(String)? onSearch;
  const CustomTopBar({
    super.key,
    this.hintText = 'Rehber Ara...',
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, left: 12, right: 12, bottom: 8),
      child: Row(
        children: [
          // Logo
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/geztek.jpg'),
            radius: 26, // Modern ve ideal boyut
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(width: 12),
          // Arama kutusu
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  const Icon(Icons.search, color: Colors.grey, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: onSearch,
                      decoration: InputDecoration(
                        hintText: hintText,
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Profil ikonu
          CircleAvatar(
            backgroundColor: const Color(0xFF22543D), // Koyu yeşil
            radius: 24,
            child: const Icon(Icons.person, size: 28, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;
  const CustomBottomBar({super.key, this.currentIndex = 1, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF22543D),
      unselectedItemColor: const Color(0xFF22543D),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.map, size: 28), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.home, size: 28), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.message, size: 28), label: ''),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, size: 28),
          label: '',
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else {
          switch (index) {
            case 0: // Harita
              // Harita sayfasına yönlendirme
              break;
            case 1: // Ana Sayfa
              Navigator.pushReplacementNamed(context, '/ana_sayfa');
              break;
            case 2: // Mesajlar
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessageList()),
              );
              break;
            case 3: // Ayarlar
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              break;
          }
        }
      },
    );
  }
}
