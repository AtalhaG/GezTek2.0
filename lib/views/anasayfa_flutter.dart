import 'package:flutter/material.dart';
import 'custom_bars.dart';

class AnaSayfaFlutter extends StatefulWidget {
  const AnaSayfaFlutter({super.key});

  @override
  State<AnaSayfaFlutter> createState() => _AnaSayfaFlutterState();
}

class _AnaSayfaFlutterState extends State<AnaSayfaFlutter> {
  bool isRehber = false;
  String userId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        isRehber = args['isRehber'] ?? false;
        userId = args['userId'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const CustomTopBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 6),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1,
                      children: [
                        _buildCard(
                          'assets/images/fotoadiyaman1.jpg',
                          'TÜM TURLAR',
                          onTap: () {},
                        ),
                        _buildCard(
                          'assets/images/fotoadiyaman1.jpg',
                          'SENİN İÇİN',
                          onTap: () {},
                        ),
                        _buildCard(
                          'assets/images/fotoadiyaman1.jpg',
                          'KEŞFEDİLMEMİŞ YERLER',
                          onTap: () {},
                        ),
                        _buildCard(
                          'assets/images/fotoadiyaman1.jpg',
                          'POPÜLER TURLAR',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isRehber ? FloatingActionButton(
        onPressed: () {
          // Rehber için tur ekleme sayfasına yönlendir
          Navigator.pushNamed(
            context,
            '/add_tour',
            arguments: {'userId': userId},
          );
        },
        backgroundColor: const Color(0xFF006400), // koyu yeşil
        child: Icon(Icons.add, size: 32, color: Colors.white),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const CustomBottomBar(currentIndex: 1),
    );
  }

  Widget _buildCard(String imagePath, String label, {VoidCallback? onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                padding: EdgeInsets.all(8),
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
