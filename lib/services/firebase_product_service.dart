// lib/services/firebase_product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirebaseProductService {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('products');

  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await productsCollection.get();
    return snapshot.docs
        .map((doc) =>
            ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<List<ProductModel>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
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

  Future<void> updateProductShelf(String productId, String? shelfId) async {
    await productsCollection.doc(productId).update({'shelfId': shelfId});
  }

  Future<Map<String, int>> getExpirationsByShelf(String shelfId) async {
    final now = DateTime.now();
    final allProducts = await getAllProducts(); // Ya existe esta función
    final shelfProducts =
        allProducts.where((p) => p.shelfId == shelfId).toList();

    final result = {
      'Vencidos': 0,
      '0 días': 0,
      '30 días': 0,
      '60 días': 0,
      '90 días': 0,
    };

    for (var p in shelfProducts) {
      final days = p.expirationDate.difference(now).inDays;

      if (days < 0) {
        result['Vencidos'] = result['Vencidos']! + 1;
      } else if (days == 0) {
        result['0 días'] = result['0 días']! + 1;
      } else if (days <= 30) {
        result['30 días'] = result['30 días']! + 1;
      } else if (days <= 60) {
        result['60 días'] = result['60 días']! + 1;
      } else if (days <= 90) {
        result['90 días'] = result['90 días']! + 1;
      }
    }

    print('****************************************');
    print('Shelf $shelfId expiration summary: $result');

    return result;
  }

  Future<List<ProductModel>> getExpiringProducts() async {
    final now = DateTime.now();
    final products = await getAllProducts();

    return products.where((product) {
      final days = product.expirationDate.difference(now).inDays;
      return days <= 90 && days >= 0;
    }).toList();
  }
}
