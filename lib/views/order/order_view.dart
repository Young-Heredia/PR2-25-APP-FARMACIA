// lib/views/order/order_view.dart

import 'package:flutter/material.dart';
import 'package:app_farmacia/services/firebase_order_service.dart';
import 'package:app_farmacia/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

@override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  final _orderService = FirebaseOrderService();

  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getAllOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes de Venta')),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('No hay órdenes registradas.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text('Orden #${order.id.substring(0, 6)}'),
                  subtitle: Text(
                    'Fecha: ${DateFormat('yyyy-MM-dd – HH:mm').format(order.date)}\nTotal: Bs ${order.total.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
