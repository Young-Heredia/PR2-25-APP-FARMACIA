// lib/views/product/detail_product_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';

class DetailProductView extends StatelessWidget {
  final ProductModel product;

  const DetailProductView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Producto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(product.imageUrl),
                backgroundColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 24),
            _infoCard(
              icon: Icons.label,
            title: 'Nombre',
            value: product.name,
            ),
            _infoCard(
            icon: Icons.description,
            title: 'Descripción',
            value: product.description,
          ),
          _infoCard(
            icon: Icons.attach_money,
            title: 'Precio',
            value: 'Bs ${product.price.toStringAsFixed(2)}',
          ),
          _infoCard(
            icon: Icons.inventory,
            title: 'Cantidad',
            value: '${product.stock} unidades',
          ),
          _infoCard(
            icon: Icons.local_shipping,
            title: 'Proveedor',
            value: product.supplier,
          ),
          _infoCard(
            icon: Icons.calendar_today,
            title: 'Fecha de Vencimiento',
            value: DateFormat('yyyy-MM-dd').format(product.expirationDate),
          ),
            const SizedBox(height: 32),
            Center(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            ),
          ],
        ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String value}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
          title: Text(
            title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          subtitle: Text(value),
      ),
    );
  }
}
