// lib/widgets/product_card.dart

import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final bool isExpired;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    this.onAdd,
    this.onRemove,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Imagen
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 64),
            ),
          ),
          const SizedBox(width: 12),

          // Información
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isExpired)
                  const Text(
                    'Producto vencido',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: isExpired ? null : onRemove,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        size: 20,
                        color: isExpired ? Colors.grey.shade400 : Colors.red,
                      ),
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontSize: 14),
                    ),
                    IconButton(
                      onPressed: isExpired ? null : onAdd,
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: isExpired ? Colors.grey.shade400 : Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Precio
          Text(
            'Bs ${price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
