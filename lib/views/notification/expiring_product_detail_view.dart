// lib/views/notification/expiring_product_detail_view.dart

import 'package:flutter/material.dart';
import 'package:app_farmacia/models/product_model.dart';

class ExpiringProductDetailView extends StatelessWidget {
  final String category;
  final List<ProductModel> products;
  final Map<String, String> shelfMap;

  const ExpiringProductDetailView({
    super.key,
    required this.category,
    required this.products,
    required this.shelfMap,
  });

  @override
  Widget build(BuildContext context) {
    final groupedByShelf = <String, List<ProductModel>>{};

    for (var p in products) {
      final shelfId = p.shelfId?.trim() ?? 'no_shelf';
      groupedByShelf[shelfId] = [...groupedByShelf[shelfId] ?? [], p];
    }

    final style = _getStyleByCategory(category);

    return Scaffold(
      appBar: AppBar(title: Text('Notificaciones de $category')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: groupedByShelf.entries.map((entry) {
          final shelfId = entry.key;
          final shelfName = shelfMap[shelfId] ?? 'Sin estante asignado';
          final quantity = entry.value.fold<int>(0, (sum, p) => sum + p.stock);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header colorido
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: style['color'],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Icon(style['icon'], color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          style['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: style['color'],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estante: $shelfName',
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      Text('ID: $shelfId'),
                      const SizedBox(height: 6),
                      Text('Cantidad: $quantity'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Map<String, dynamic> _getStyleByCategory(String category) {
    switch (category) {
      case 'Vencidos':
        return {
          'title': '⚠️ Medicamentos Vencidos',
          'color': Colors.red.shade300,
          'icon': Icons.warning_amber_rounded,
        };
      case '0 días':
        return {
          'title': '⛔ Vencen Hoy',
          'color': Colors.redAccent,
          'icon': Icons.block,
        };
      case '30 días':
        return {
          'title': '⏳ Vencen en 30 días',
          'color': Colors.orange.shade300,
          'icon': Icons.hourglass_bottom,
        };
      case '60 días':
        return {
          'title': '📅 Vencen en 60 días',
          'color': Colors.lightBlue.shade400,
          'icon': Icons.calendar_today,
        };
      case '90 días':
        return {
          'title': '✅ Vencen en 90 días',
          'color': Colors.green.shade300,
          'icon': Icons.check_circle,
        };
      default:
        return {
          'title': 'Productos por Caducar',
          'color': Colors.grey,
          'icon': Icons.inventory,
        };
    }
  }
}
