import 'package:flutter/material.dart';
import 'custom_bars.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  // Yeşil renk sabitleri
  final Color _primaryGreen = const Color(0xFF22543D); // Koyu yeşil
  final Color _lightGreen = const Color(0xFF2E7D32); // Orta yeşil

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
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
                    children: [
                      Text(
                        l10n.username,
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
              l10n.appearance,
              [
                _buildSettingsTile(
                  icon: Icons.dark_mode,
                  title: l10n.darkMode,
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
                  title: l10n.language,
                  trailing: DropdownButton<String>(
                    value: languageProvider.currentLanguageCode,
                    items: LanguageProvider.languageOptions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        languageProvider.changeLanguage(newValue);
                      }
                    },
                  ),
                ),
              ],
            ),

            _buildSettingsSection(
              l10n.notifications,
              [
                _buildSettingsTile(
                  icon: Icons.notifications,
                  title: l10n.enableNotifications,
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
              l10n.account,
              [
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: l10n.editProfile,
                  onTap: () {
                    // Profil düzenleme sayfasına yönlendirme
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: l10n.changePassword,
                  onTap: () {
                    // Şifre değiştirme sayfasına yönlendirme
                  },
                ),
              ],
            ),

            _buildSettingsSection(
              l10n.app,
              [
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: l10n.about,
                  onTap: () {
                    // Hakkında sayfasına yönlendirme
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: l10n.helpAndSupport,
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
                child: Text(
                  l10n.logout,
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