// lib/views/home_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> featuredProducts = [
    {
      'image': 'assets/blister1.jpg',
      'name': 'Paracetamol 50mg',
      'price': 2.99,
      'rxRequired': true
    },
    {
      'image': 'assets/blister2.jpg',
      'name': 'Ibuprofeno 200mg',
      'price': 3.49,
      'rxRequired': false
    },
    {
      'image': 'assets/blister3.jpg',
      'name': 'Cefepime 1g',
      'price': 10.49,
      'rxRequired': true
    },
  ];

  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage =
            (_pageController.page!.round() + 1) % featuredProducts.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF5),
      /*body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildCarousel(context),
            const SizedBox(height: 24),
            _buildNavigationButtons(context),
          ],
        ),
      ),*/
      body: Column(
        children: [
          _buildCarousel(context),
          const Spacer(),
        ],
      ),
      /*body: Stack(
        children: [
          Column(
            children: [
              _buildCarousel(context),
              const Spacer(),
            ],
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: _buildNavigationButtons(context),
          ),
        ],
      ),*/
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 280,
      width: screenWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: featuredProducts.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final product = featuredProducts[index];
              return Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Botón de retroceso
                    Positioned(
                      top: 12,
                      left: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child:
                            const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                    // Botón de ajustes
                    Positioned(
                      top: 12,
                      right: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.settings, color: Colors.black),
                      ),
                    ),
                    // Imagen recortada con bordes redondeados
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                      child: Image.asset(
                        product['image'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit
                            .cover, // o BoxFit.fitWidth si prefieres sin recorte superior/inferior
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Indicador cuadrado
          Positioned(
            bottom: 20,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: featuredProducts.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 10,
                dotWidth: 10,
                spacing: 8,
                radius: 2,
                activeDotColor: Colors.teal,
                dotColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      /*child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botones de Inventario y Órdenes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                _customNavButton(
                  icon: Icons.inventory_2_rounded,
                  text: 'Gestión de Inventario',
                  onPressed: () => Navigator.pushNamed(context, '/inventory'),
                ),
                const SizedBox(height: 10),
                _customNavButton(
                  icon: Icons.receipt_long,
                  text: 'Órdenes de Venta',
                  onPressed: () => Navigator.pushNamed(context, '/orders'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),*/
      // Barra inferior con íconos
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() => _selectedIndex = index);
            if (index == 1) {
              Navigator.pushNamed(context, '/inventory');
            } else if (index == 2) {
              Navigator.pushNamed(context, '/orders');
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: 'Inventario',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Órdenes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _customNavButton(
      {required IconData icon,
      required String text,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.teal.shade900),
        label: Text(text, style: TextStyle(color: Colors.teal.shade900)),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE6F3FB),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 2,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
