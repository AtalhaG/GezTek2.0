import 'package:flutter/material.dart';
import 'custom_bars.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Türkçe';

  // Yeşil renk sabitleri
  final Color _primaryGreen = const Color(0xFF22543D); // Koyu yeşil
  final Color _lightGreen = const Color(0xFF2E7D32); // Orta yeşil

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        elevation: 0,
        backgroundColor: _primaryGreen,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profil Bölümü
            Container(
              padding: const EdgeInsets.all(20),
              color: _primaryGreen.withOpacity(0.1),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _primaryGreen,
                    child: const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Kullanıcı Adı',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'kullanici@email.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ayarlar Listesi
            _buildSettingsSection(
              'Görünüm',
              [
                _buildSettingsTile(
                  icon: Icons.dark_mode,
                  title: 'Karanlık Mod',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    activeColor: _primaryGreen,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: 'Dil',
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    items: ['Türkçe', 'English'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            _buildSettingsSection(
              'Bildirimler',
              [
                _buildSettingsTile(
                  icon: Icons.notifications,
                  title: 'Bildirimleri Etkinleştir',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    activeColor: _primaryGreen,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            _buildSettingsSection(
              'Hesap',
              [
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Profil Düzenle',
                  onTap: () {
                    // Profil düzenleme sayfasına yönlendirme
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Şifre Değiştir',
                  onTap: () {
                    // Şifre değiştirme sayfasına yönlendirme
                  },
                ),
              ],
            ),

            _buildSettingsSection(
              'Uygulama',
              [
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'Hakkında',
                  onTap: () {
                    // Hakkında sayfasına yönlendirme
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Yardım ve Destek',
                  onTap: () {
                    // Yardım sayfasına yönlendirme
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Çıkış Yap Butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Çıkış yapılırken hata oluştu: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Çıkış Yap',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(currentIndex: 3),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _primaryGreen,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: _primaryGreen),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
} 