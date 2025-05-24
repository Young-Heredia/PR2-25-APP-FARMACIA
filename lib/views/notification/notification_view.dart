// lib/views/notification/notification_view.dart

import 'package:flutter/material.dart';
import 'package:app_farmacia/services/firebase_product_service.dart';
import 'package:app_farmacia/services/firebase_shelf_service.dart';
import 'package:app_farmacia/models/product_model.dart';
import 'package:app_farmacia/models/shelf_model.dart';
import 'package:app_farmacia/views/notification/expiring_product_by_shelf_view.dart';
//import 'package:app_farmacia/views/notification/shelf_notification_card.dart';

class NotificationView extends StatefulWidget {
  NotificationView({super.key});
  final FirebaseProductService _productService = FirebaseProductService();
  final FirebaseShelfService _shelfService = FirebaseShelfService();

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  late Future<List<ProductModel>> _productsFuture;
  late Future<List<ShelfModel>> _shelvesFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = widget._productService.getAllProducts();
    _shelvesFuture = widget._shelfService.getAllShelves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones de Vencimiento')),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, productSnapshot) {
          if (productSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }

          return FutureBuilder<List<ShelfModel>>(
            future: _shelvesFuture,
            builder: (context, shelfSnapshot) {
              if (!shelfSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final shelves = shelfSnapshot.data!;
              final shelfMap = {
                for (var shelf in shelves) shelf.id: shelf.name
              };

              final now = DateTime.now();
              final Map<String, List<ProductModel>> grouped = {
                'Vencidos': [],
                '0 días': [],
                '30 días': [],
                '60 días': [],
                '90 días': [],
              };

              for (var p in productSnapshot.data!) {
                final days = p.expirationDate.difference(now).inDays;
                if (days < 0) {
                  grouped['Vencidos']!.add(p);
                } else if (days == 0) {
                  grouped['0 días']!.add(p);
                } else if (days <= 30) {
                  grouped['30 días']!.add(p);
                } else if (days <= 60) {
                  grouped['60 días']!.add(p);
                } else if (days <= 90) {
                  grouped['90 días']!.add(p);
                }
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: grouped.entries
                    .where((e) => e.value.isNotEmpty)
                    .map(
                        (e) => _buildNotificationCard(e.key, e.value, shelfMap))
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(String category, List<ProductModel> products,
      Map<String, String> shelfMap) {
    final info = _getCardStyle(category);

    // Estantes únicos
    //final shelfSet = products.map((p) => p.shelfId ?? 'no_shelf').toSet();

    // Conteo de productos por estante
    //final Map<String, int> productCountMap = {};

    // Agrupar productos por shelfId
    final Map<String, List<ProductModel>> groupedByShelf = {};
    for (var product in products) {
      final shelfId = product.shelfId ?? 'no_shelf';
      groupedByShelf[shelfId] = [...groupedByShelf[shelfId] ?? [], product];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: info['background'],
      ),
      child: Column(
        children: [
          // 🔹 Header del Card
          Container(
            decoration: BoxDecoration(
              color: info['color'],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //margin: const EdgeInsets.only(bottom: 0),
            child: Row(
              children: [
                Icon(info['icon'], color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.white,
                  child: Text(
                    groupedByShelf.length.toString(), // Número de estantes
                    style: TextStyle(
                      color: info['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔸 Contenido del Card (lista de estantes)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: groupedByShelf.entries.map((entry) {
                final shelfId = entry.key;
                final shelfProducts = entry.value;
                final shelfName = shelfMap[shelfId] ?? 'Sin estante asignado';

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExpiringProductByShelfView(
                          category: category,
                          shelfName: shelfName,
                          products: shelfProducts,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withOpacity(0.8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cantidad: ${shelfProducts.length}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Estante: $shelfName',
                            style: const TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // 🛠️ Función auxiliar para determinar el color, mensaje e ícono
  Map<String, dynamic> _getCardStyle(String category) {
    switch (category) {
      case 'Vencidos':
        return {
          'title': 'Medicamentos Vencidos',
          'color': Colors.red,
          'background': Colors.red.shade100,
          'icon': Icons.error,
        };
      case '0 días':
        return {
          'title': 'Vencen Hoy',
          'color': Colors.redAccent,
          'background': Colors.redAccent.shade100,
          'icon': Icons.warning_amber_rounded,
        };
      case '30 días':
        return {
          'title': 'Vencen en 30 días',
          'color': Colors.yellow,
          'background': Colors.yellow.shade50,
          'icon': Icons.hourglass_bottom,
        };
      case '60 días':
        return {
          'title': 'Vencen en 60 días',
          'color': Colors.orange,
          'background': Colors.orange.shade50,
          'icon': Icons.calendar_today,
        };
      case '90 días':
        return {
          'title': 'Vencen en 90 días',
          'color': Colors.green,
          'background': Colors.green.shade50,
          'icon': Icons.check_circle,
        };
      default:
        return {
          'title': 'Productos',
          'color': Colors.grey,
          'background': Colors.grey.shade200,
          'icon': Icons.inventory,
        };
    }
  }
}
