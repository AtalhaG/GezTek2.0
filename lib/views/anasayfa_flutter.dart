import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'custom_bars.dart';
import 'add_tour_page.dart';
import 'rehber_siralama.dart';
import 'rehber_detay.dart';

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
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        isRehber = args['isRehber'] ?? false;
        userId = args['userId'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> sliderImages = [
      'assets/images/slayt1.png',
      'assets/images/slayt2.png',
      'assets/images/slayt3.png',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          const CustomTopBar(),
          CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              viewportFraction: 0.8,
            ),
            items:
                sliderImages.map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.asset(imagePath, fit: BoxFit.cover),
                        ),
                      );
                    },
                  );
                }).toList(),
          ),
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
                          'assets/images/1.png',
                          '',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RehberSiralamaSayfasi(),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          'assets/images/2.png',
                          '',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RehberSiralamaSayfasi(),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          'assets/images/3.png',
                          '',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RehberSiralamaSayfasi(),
                              ),
                            );
                          },
                        ),
                        _buildCard(
                          'assets/images/4.png',
                          '',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RehberSiralamaSayfasi(),
                              ),
                            );
                          },
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
      floatingActionButton:
          isRehber
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTourPage(),
                      settings: RouteSettings(
                        arguments: {'userId': userId},
                      ),
                    ),
                  );
                },
                backgroundColor: const Color(0xFF006400),
                child: const Icon(Icons.add, size: 32, color: Colors.white),
              )
              : null,
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
