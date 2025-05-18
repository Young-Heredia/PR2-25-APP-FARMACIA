// lib/views/home_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:app_farmacia/services/firebase_product_service.dart';
import 'package:app_farmacia/models/product_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();
  final FirebaseProductService _productService = FirebaseProductService();

  int _currentPage = 0;
  int _selectedIndex = 0;
  Timer? _carouselTimer;

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
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCarousel(context),
            const SizedBox(height: 24),
            _buildExpiringProductsCard(),
          ],
        ),
      ),
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
            } else if (index == 3) {
              Navigator.pushNamed(context, '/product-manage');
            } else if (index == 4) {
              Navigator.pushNamed(context, '/shelf-manage');
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
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Gestión',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_list),
              label: 'Estantes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiringProductsCard() {
    return FutureBuilder<List<ProductModel>>(
      future: _productService.getExpiringProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                    child: Text('No hay productos próximos a vencer. 🎉')),
              ),
            ),
          );
        }

        final products = snapshot.data!;
        products.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
        final top3Products = products.take(3).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productos Próximos a Vencer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...top3Products.map((product) {
                    final daysRemaining = product.expirationDate
                        .difference(DateTime.now())
                        .inDays;
                    final statusInfo = _getStatusInfo(daysRemaining);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading:
                          Icon(statusInfo['icon'], color: statusInfo['color']),
                      title: Text(product.name),
                      subtitle: Text(statusInfo['message']),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getStatusInfo(int daysRemaining) {
    if (daysRemaining < 0) {
      return {
        'color': Colors.red,
        'message': '❌ Vencido hace ${-daysRemaining} días',
        'icon': Icons.error,
      };
    } else if (daysRemaining == 0) {
      return {
        'color': Colors.redAccent,
        'message': '⚠️ Vence hoy',
        'icon': Icons.warning,
      };
    } else if (daysRemaining <= 30) {
      return {
        'color': Colors.orange,
        'message': '⏳ Vence en $daysRemaining días',
        'icon': Icons.hourglass_top,
      };
    } else if (daysRemaining <= 90) {
      return {
        'color': Colors.amber,
        'message': '🕒 Vence en $daysRemaining días',
        'icon': Icons.access_time,
      };
    } else {
      return {
        'color': Colors.green,
        'message': '✅ Seguro',
        'icon': Icons.check_circle,
      };
    }
  }
}
