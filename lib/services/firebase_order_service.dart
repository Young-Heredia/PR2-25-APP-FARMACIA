// lib/services/firebase_order_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class FirebaseOrderService {
  final ordersCollection = FirebaseFirestore.instance.collection('orders');

  Future<void> addOrder(OrderModel order) async {
    final snapshot = await ordersCollection.orderBy('date').get();
    final totalOrders = snapshot.size + 1;

    final yearShort = DateTime.now().year % 100; // Ej. 2025 → 25
    final customId = '${yearShort.toString().padLeft(2, '0')}-${totalOrders.toString().padLeft(6, '0')}';

    final docRef = ordersCollection.doc(customId); // Usa ID personalizado

    await docRef.set(order.toMap());
  }

  Future<List<OrderModel>> getAllOrders() async {
    final snapshot =
        await ordersCollection.orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
