// lib/views/shelf/detail_shelf_view.dart

import 'package:flutter/material.dart';
import '../../models/shelf_model.dart';
import '../../models/product_model.dart';
import '../../services/firebase_product_service.dart';
import 'assign_products_to_shelf_view.dart';

class ShelfDetailView extends StatefulWidget {
  final ShelfModel shelf;

  const ShelfDetailView({super.key, required this.shelf});

  @override
  State<ShelfDetailView> createState() => _ShelfDetailViewState();
}

class _ShelfDetailViewState extends State<ShelfDetailView> {
  final productService = FirebaseProductService();
  List<ProductModel> assignedProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignedProducts();
  }

  Future<void> _loadAssignedProducts() async {
    if (widget.shelf.assignedProducts.isNotEmpty) {
      final products =
          await productService.getProductsByIds(widget.shelf.assignedProducts);
      setState(() {
        assignedProducts = products;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Estante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal.shade100,
                child:
                    const Icon(Icons.inventory_2, size: 40, color: Colors.teal),
              ),
            ),
            const SizedBox(height: 24),
            Text('Nombre:', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(widget.shelf.name,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Text('Descripción:', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              widget.shelf.description.isNotEmpty
                  ? widget.shelf.description
                  : 'Sin descripción',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text('Productos asignados:',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : assignedProducts.isEmpty
                    ? const Text('No hay productos asignados.')
                    : Expanded(
                        child: ListView.builder(
                          itemCount: assignedProducts.length,
                          itemBuilder: (context, index) {
                            final product = assignedProducts[index];
                            return ListTile(
                              title: Text(product.name),
                              subtitle: Text(
                                  'Cantidad: ${product.stock} | Precio: Bs ${product.price.toStringAsFixed(2)}'),
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(product.imageUrl),
                              ),
                            );
                          },
                        ),
                      ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final wasAssigned = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AssignProductsToShelfPage(shelf: widget.shelf),
                    ),
                  );

                  if (wasAssigned == true) {
                    _loadAssignedProducts(); // ← volver a cargar productos si se asignaron
                  }
                },
                icon: const Icon(Icons.playlist_add),
                label: const Text('Asignar Productos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
