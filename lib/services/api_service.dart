// lib/services/api_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseProductService {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await productsCollection.get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addProduct(ProductModel product) async {
    await productsCollection.add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await productsCollection.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await productsCollection.doc(id).delete();
  }
}
