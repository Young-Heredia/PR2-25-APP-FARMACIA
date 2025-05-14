// lib/views/shelf/assign_products_to_shelf_view.dart

import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/shelf_model.dart';
import '../../services/firebase_product_service.dart';
import '../../services/firebase_shelf_service.dart';

class AssignProductsToShelfPage extends StatefulWidget {
  final ShelfModel shelf;

  const AssignProductsToShelfPage({super.key, required this.shelf});

  @override
  State<AssignProductsToShelfPage> createState() =>
      _AssignProductsToShelfPageState();
}

class _AssignProductsToShelfPageState extends State<AssignProductsToShelfPage> {
  final productService = FirebaseProductService();
  final shelfService = FirebaseShelfService();

  List<ProductModel> _products = [];
  Set<String> _selectedProductIds = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await productService.getAllProducts();
    setState(() {
      _products = products;
    });
  }

  Future<void> _assignProducts() async {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un producto')),
      );
      return;
    }

    // 1. Obtener los productos ya asignados
    final existingAssignedProducts = widget.shelf.assignedProducts;

    // 2. Unir sin duplicados
    final updatedAssignedProducts =
        {...existingAssignedProducts, ..._selectedProductIds}.toList();

    // 3. Actualizar en Firebase
    await shelfService.assignProductsToShelf(
        widget.shelf.id, updatedAssignedProducts);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Productos asignados correctamente')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Asignar Productos a ${widget.shelf.name}')),
      body: _products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return CheckboxListTile(
                  value: _selectedProductIds.contains(product.id),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        _selectedProductIds.add(product.id);
                      } else {
                        _selectedProductIds.remove(product.id);
                      }
                    });
                  },
                  title: Text(product.name),
                  subtitle: Text(
                      'Cantidad: ${product.stock} | Bs ${product.price.toStringAsFixed(2)}'),
                  secondary: CircleAvatar(
                    backgroundImage: NetworkImage(product.imageUrl),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _assignProducts,
        icon: const Icon(Icons.save),
        label: const Text('Guardar Asignación'),
      ),
    );
  }
}
