// lib/services/firebase_order_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class FirebaseOrderService {
  final ordersCollection = FirebaseFirestore.instance.collection('orders');

  Future<void> addOrder(OrderModel order) async {
    await ordersCollection.add(order.toMap());
  }

  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await ordersCollection.orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
