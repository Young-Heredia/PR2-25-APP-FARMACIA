// lib/views/product/detail_product_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';

class DetailProductView extends StatefulWidget {
  final ProductModel product;

  const DetailProductView({super.key, required this.product});

  @override
  State<DetailProductView> createState() => _DetailProductViewState();
}

class _DetailProductViewState extends State<DetailProductView> {
  late String _alertMessage;
  late Color _alertColor;
  late IconData _alertIcon;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final diff = widget.product.expirationDate.difference(now).inDays;

    if (diff < 0) {
      _alertMessage = 'Este producto ya está vencido.';
      _alertColor = Colors.red.shade300;
      _alertIcon = Icons.warning_amber_rounded;
    } else if (diff == 0) {
      _alertMessage = 'Este producto vence hoy.';
      _alertColor = Colors.deepOrange;
      _alertIcon = Icons.error;
    } else if (diff <= 30) {
      _alertMessage = 'Este producto vence en $diff días.';
      _alertColor = Colors.orange.shade300;
      _alertIcon = Icons.calendar_today;
    } else if (diff <= 60) {
      _alertMessage = 'Este producto vence en $diff días.';
      _alertColor = Colors.blue.shade300;
      _alertIcon = Icons.event_note;
    } else if (diff <= 90) {
      _alertMessage = 'Este producto vence en $diff días.';
      _alertColor = Colors.green.shade300;
      _alertIcon = Icons.check_circle;
    } else {
      _alertMessage = '';
    }

    if (_alertMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_alertMessage),
            backgroundColor: _alertColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Producto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_alertMessage.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _alertColor.withOpacity(0.2),
                border: Border.all(color: _alertColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(_alertIcon, color: _alertColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _alertMessage,
                      style: TextStyle(
                        color: _alertColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(p.imageUrl),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 24),
          _infoCard(
            icon: Icons.label,
            title: 'Nombre',
            value: p.name,
          ),
          _infoCard(
            icon: Icons.description,
            title: 'Descripción',
            value: p.description,
          ),
          _infoCard(
            icon: Icons.attach_money,
            title: 'Precio',
            value: 'Bs ${p.price.toStringAsFixed(2)}',
          ),
          _infoCard(
            icon: Icons.inventory,
            title: 'Cantidad',
            value: '${p.stock} unidades',
          ),
          _infoCard(
            icon: Icons.local_shipping,
            title: 'Proveedor',
            value: p.supplier,
          ),
          _infoCard(
            icon: Icons.calendar_today,
            title: 'Fecha de Vencimiento',
            value: DateFormat('yyyy-MM-dd').format(p.expirationDate),
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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

  Widget _infoCard(
      {required IconData icon, required String title, required String value}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(value),
      ),
    );
  }
}
