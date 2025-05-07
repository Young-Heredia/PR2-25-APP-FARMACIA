// lib/views/inventory_view.dart

import 'package:flutter/material.dart';
import '../widgets/product_card.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Productos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              ProductCard(
                image: 'assets/caja_medicamento.jpg',
                name: 'Cefepime 1g',
                description: 'Antibiótico inyectable',
                price: 10.49,
              ),
              ProductCard(
                image: 'assets/blister1.jpg',
                name: 'Paracetamol 50mg',
                description: 'Tabletas x10',
                price: 2.99,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
