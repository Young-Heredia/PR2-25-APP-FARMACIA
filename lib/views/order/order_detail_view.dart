// lib/views/order/order_detail_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_farmacia/models/order_model.dart';
import 'package:app_farmacia/models/product_model.dart';
import 'package:app_farmacia/services/firebase_product_service.dart';
import 'package:app_farmacia/views/product/detail_product_view.dart';

class OrderDetailView extends StatefulWidget {
  final OrderModel order;

  const OrderDetailView({super.key, required this.order});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  final _productService = FirebaseProductService();
  final Map<String, ProductModel> _productMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProductImages();
  }

  Future<void> _loadProductImages() async {
    final ids = widget.order.items.map((e) => e.productId).toList();
    final products = await _productService.getProductsByIds(ids);
    setState(() {
      _productMap.addEntries(products.map((p) => MapEntry(p.id, p)));
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderCode = widget.order.id.padLeft(6, '0');
    final formattedDate =
        DateFormat('dd-MM-yyyy – HH:mm').format(widget.order.date);

    return Scaffold(
      appBar: AppBar(title: Text('Detalle Orden $orderCode')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('🧾 Código: $orderCode',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.teal)),
                          const SizedBox(height: 8),
                          Text('📅 Fecha: $formattedDate',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                          const SizedBox(height: 8),
                          Text(
                            '💰 Total: Bs ${widget.order.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '📦 Productos:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.order.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.order.items[index];
                        final subtotal = item.price * item.quantity;
                        final product = _productMap[item.productId];

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: product != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(product.imageUrl),
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                            title: Text(item.productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                'Cantidad: ${item.quantity}\nPrecio unitario: Bs ${item.price.toStringAsFixed(2)}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Subtotal',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Text(
                                  'Bs ${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: product != null
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DetailProductView(product: product),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
