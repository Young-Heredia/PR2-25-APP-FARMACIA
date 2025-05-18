// lib/models/product_model.dart

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final DateTime expirationDate;
  final String supplier;
  final String? shelfId;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.expirationDate,
    required this.supplier,
    this.shelfId,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'],
      description: map['description'],
      price: map['price'].toDouble(),
      stock: map['stock'],
      imageUrl: map['imageUrl'],
      expirationDate: DateTime.parse(map['expirationDate']),
      supplier: map['supplier'],
      shelfId: map['shelfId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'expirationDate': expirationDate.toIso8601String(),
      'supplier': supplier,
      'shelfId': shelfId,
    };
  }
}
