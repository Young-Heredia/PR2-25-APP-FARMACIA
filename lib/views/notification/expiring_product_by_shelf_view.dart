// lib/views/notification/expiring_product_by_shelf_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_farmacia/models/product_model.dart';
import 'package:app_farmacia/views/product/detail_product_view.dart';

class ExpiringProductByShelfView extends StatefulWidget {
  final String category;
  final String shelfName;
  final List<ProductModel> products;

  const ExpiringProductByShelfView({
    super.key,
    required this.category,
    required this.shelfName,
    required this.products,
  });

  @override
  State<ExpiringProductByShelfView> createState() =>
      _ExpiringProductByShelfViewState();
}

class _ExpiringProductByShelfViewState
    extends State<ExpiringProductByShelfView> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _filteredProducts = widget.products;
    _searchController.addListener(_applySearch);
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = widget.products.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.description.toLowerCase().contains(query) ||
            p.supplier.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final totalStock = _filteredProducts.fold<int>(0, (sum, p) => sum + p.stock);
    final colorMap = _getStyleByCategory(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - ${widget.shelfName}'),
        backgroundColor: colorMap['color'],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🔹 Card resumen
          Card(
            color: colorMap['color'].withOpacity(0.1),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.category,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorMap['color'])),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.inventory_2, size: 20),
                      const SizedBox(width: 6),
                      Text('Total productos: ${_filteredProducts.length}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.calculate, size: 20),
                      const SizedBox(width: 6),
                      Text('Cantidad total: $totalStock'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.store, size: 20),
                      const SizedBox(width: 6),
                      Text('Estante: ${widget.shelfName}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

         // 🔍 Campo de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, proveedor o descripción...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔸 Lista filtrada
          if (_filteredProducts.isEmpty)
            const Center(child: Text('No se encontraron coincidencias.')),

          ..._filteredProducts.map((p) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailProductView(product: p),
                    ),
                  );
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📷 Imagen del producto
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: p.imageUrl.isNotEmpty
                              ? Image.network(
                                  p.imageUrl,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.broken_image, size: 64),
                                )
                              : const Icon(Icons.image_not_supported, size: 64),
                        ),
                        const SizedBox(width: 12),

                        // 📝 Detalles
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Proveedor: ${p.supplier}'),
                              Text('Cantidad: ${p.stock}'),
                              Text(
                                  'Vence: ${DateFormat('dd-MM-yyyy').format(p.expirationDate)}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStyleByCategory(String category) {
    switch (category) {
      case 'Vencidos':
        return {'color': Colors.red.shade400};
      case '0 días':
        return {'color': Colors.redAccent};
      case '30 días':
        return {'color': Colors.yellow.shade400};
      case '60 días':
        return {'color': Colors.orange.shade400};
      case '90 días':
        return {'color': Colors.green.shade400};
      default:
        return {'color': Colors.grey.shade600};
    }
  }
}
