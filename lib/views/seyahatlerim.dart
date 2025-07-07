import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Seyahatlerim extends StatefulWidget {
  const Seyahatlerim({super.key});

  @override
  State<Seyahatlerim> createState() => _SeyahatlerimState();
}

class _SeyahatlerimState extends State<Seyahatlerim> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final darkCard = isDark ? theme.cardColor : Colors.white;
    final darkBg = isDark ? theme.scaffoldBackgroundColor : Colors.grey[100]!;
    final darkText = isDark ? Colors.white : Colors.black87;
    final darkSubText = isDark ? Colors.grey[300]! : Colors.grey[800]!;
    final darkIcon = isDark ? Colors.grey[300]! : Colors.grey[600]!;
    final activeBg = isDark ? Colors.green[900]! : Colors.green[50]!;
    final passiveBg = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final activeText = isDark ? Colors.green[200]! : Colors.green[700]!;
    final passiveText = isDark ? Colors.grey[400]! : Colors.grey[700]!;
    final darkGreen = const Color(0xFF22543D);
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: darkCard,
        title: Text(
          l10n.myTrips,
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.primaryColor,
          labelColor: const Color(0xFF22543D),
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_bus),
                  const SizedBox(width: 8),
                  Text(l10n.activeTrips),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history),
                  const SizedBox(width: 8),
                  Text(l10n.pastTrips),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aktif Seyahatler
          _buildTravelList(true, darkCard, darkSubText, activeBg, passiveBg, activeText, passiveText, darkIcon, theme, l10n),
          // Geçmiş Seyahatler
          _buildTravelList(false, darkCard, darkSubText, activeBg, passiveBg, activeText, passiveText, darkIcon, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildTravelList(bool isActive, Color darkCard, Color darkSubText, Color activeBg, Color passiveBg, Color activeText, Color passiveText, Color darkIcon, ThemeData theme, AppLocalizations l10n) {
    final darkGreen = const Color(0xFF22543D);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Örnek veri
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: darkCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: DecorationImage(
                    image: NetworkImage('https://picsum.photos/500/300?random=$index'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'İstanbul - Antalya',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkSubText,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive ? activeBg : passiveBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isActive ? l10n.active : l10n.completed,
                            style: TextStyle(
                              color: isActive ? activeText : passiveText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: darkIcon),
                        const SizedBox(width: 8),
                        Text(
                          l10n.dateFormat,
                          style: TextStyle(
                            color: darkIcon,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: darkIcon),
                        const SizedBox(width: 8),
                        Text(
                          '5 ${l10n.stops}',
                          style: TextStyle(
                            color: darkIcon,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₺2,500',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(l10n.viewDetails),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 