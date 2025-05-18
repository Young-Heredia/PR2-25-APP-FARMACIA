// lib/views/notification/shelf_notification_card.dart

import 'package:flutter/material.dart';
import 'package:app_farmacia/models/shelf_model.dart';
import 'package:app_farmacia/services/firebase_product_service.dart';

class ShelfNotificationCard extends StatelessWidget {
  final ShelfModel shelf;
  final FirebaseProductService productService;

  const ShelfNotificationCard({
    super.key,
    required this.shelf,
    required this.productService,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: productService.getExpirationsByShelf(shelf.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: LinearProgressIndicator(),
          );
        }

        final data = snapshot.data!;
        final cards = data.entries.where((e) => e.value > 0).toList();
        if (cards.isEmpty) return const SizedBox();

        return Column(
          children: cards.map((entry) {
            final style = _getStyle(entry.key);
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Header del card
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: style['color'],
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
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
                              '1', // O puedes sumar cuántos estantes tienen ese tipo
                              style: TextStyle(
                                color: style['color'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 🔸 Contenido del card
                    Container(
                      width: double
                          .infinity, // 🔥 Esto asegura que ocupe todo el ancho
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estante: ${shelf.name}',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 6),
                          Text('Cantidad: ${entry.value}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Map<String, dynamic> _getStyle(String category) {
    switch (category) {
      case 'Vencidos':
        return {
          'title': 'Medicamentos Vencidos',
          'color': Colors.red.shade300,
          'icon': Icons.warning_amber_rounded,
        };
      case '0 días':
        return {
          'title': 'Vencen Hoy',
          'color': Colors.redAccent,
          'icon': Icons.block,
        };
      case '30 días':
        return {
          'title': 'Vencen en 30 días',
          'color': Colors.orange.shade300,
          'icon': Icons.hourglass_bottom,
        };
      case '60 días':
        return {
          'title': 'Vencen en 60 días',
          'color': Colors.lightBlue.shade400,
          'icon': Icons.calendar_today,
        };
      case '90 días':
        return {
          'title': 'Vencen en 90 días',
          'color': Colors.green.shade300,
          'icon': Icons.check_circle,
        };
      default:
        return {
          'title': 'Productos',
          'color': Colors.grey,
          'icon': Icons.inventory,
        };
    }
  }
}
