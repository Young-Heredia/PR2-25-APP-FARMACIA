// lib/models/shelf_model.dart

class ShelfModel {
  final String id;
  final String name;
  final String description;
  final int productsCount;
  final List<String> assignedProducts;

  ShelfModel({
    required this.id,
    required this.name,
    required this.description,
    required this.productsCount,
    required this.assignedProducts,
  });

  factory ShelfModel.fromMap(Map<String, dynamic> map, String id) {
    return ShelfModel(
      id: id,
      name: map['name'] as String,
      description: map['description'] as String,
      productsCount: (map['productsCount'] ?? 0) as int,
      assignedProducts: List<String>.from(map['assignedProducts'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'productsCount': productsCount,
      'assignedProducts': assignedProducts,
    };
  }
}
