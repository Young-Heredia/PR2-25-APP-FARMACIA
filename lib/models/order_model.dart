// lib/models/order_model.dart

class OrderModel {
  final String id;
  final DateTime date;
  final List<OrderItem> items;
  final double total;

  OrderModel({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      date: DateTime.parse(map['date']),
      items: (map['items'] as List)
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      total: map['total'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }
}
