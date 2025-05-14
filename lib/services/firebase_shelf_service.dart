// lib/services/firebase_shelf_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shelf_model.dart';

class FirebaseShelfService {
  final CollectionReference shelvesCollection =
      FirebaseFirestore.instance.collection('shelves');

  Future<List<ShelfModel>> getAllShelves() async {
    final snapshot = await shelvesCollection.get();
    return snapshot.docs
        .map((doc) =>
            ShelfModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> addShelf(ShelfModel shelf) async {
    await shelvesCollection.add(shelf.toMap());
  }

  Future<void> updateShelf(ShelfModel shelf) async {
    await shelvesCollection.doc(shelf.id).update(shelf.toMap());
  }

  Future<void> deleteShelf(String id) async {
    await shelvesCollection.doc(id).delete();
  }

  Future<void> assignProductsToShelf(
      String shelfId, List<String> productIds) async {
    await shelvesCollection.doc(shelfId).update({
      'assignedProducts': productIds,
    });
  }
}
