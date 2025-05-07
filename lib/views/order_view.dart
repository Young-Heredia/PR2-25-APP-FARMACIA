// lib/views/order_view.dart

import 'package:flutter/material.dart';

class OrderView extends StatelessWidget {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes de Venta')),
      body: const Center(child: Text('Aquí se mostrarán las órdenes registradas')),
    );
  }
}
