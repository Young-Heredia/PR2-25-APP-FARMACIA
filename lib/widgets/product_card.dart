// lib/widgets/product_card.dart

import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String image;
  final String name;
  final String description;
  final double price;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
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
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {}, // disminuir cantidad
                        icon: const Icon(Icons.remove_circle_outline,
                            size: 20, color: Colors.grey),
                      ),
                      const Text(
                        '1',
                        style: TextStyle(fontSize: 14),
                      ),
                      IconButton(
                        onPressed: () {}, // aumentar cantidad
                        icon: const Icon(Icons.add_circle_outline,
                            size: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Precio
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
