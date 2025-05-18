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
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  Map<String, String> _shelfMap = {}; // Mapea shelfId -> shelfName

  @override
  void initState() {
    super.initState();
    _selectedProductIds = widget.shelf.assignedProducts.toSet();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await productService.getAllProducts();
    final shelves = await shelfService.getAllShelves();
    setState(() {
      _products = products;
      _shelfMap = {for (var s in shelves) s.id: s.name};
    });
  }

  List<ProductModel> get _filteredProducts {
    if (_searchTerm.isEmpty) return _products;
    final lowerCaseSearch = _searchTerm.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(lowerCaseSearch) ||
          product.description.toLowerCase().contains(lowerCaseSearch) ||
          product.supplier.toLowerCase().contains(lowerCaseSearch);
    }).toList();
  }

  Future<void> _assignProducts() async {
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione al menos un producto')),
      );
      return;
    }

// Paso 1: Actualizar colección 'shelves'
    await shelfService.assignProductsToShelf(
      widget.shelf.id,
      _selectedProductIds.toList(),
    );

    // Paso 2: Actualizar campo shelfId en cada producto
    for (final product in _products) {
      final wasAssigned = _selectedProductIds.contains(product.id);
      final isCurrentlyAssigned = product.shelfId == widget.shelf.id;

      if (wasAssigned && !isCurrentlyAssigned) {
        await productService.updateProductShelf(product.id, widget.shelf.id);
      } else if (!wasAssigned && isCurrentlyAssigned) {
        await productService.updateProductShelf(product.id, null);
      }
    }

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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchTerm = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? const Center(
                          child: Text(
                            '🔍 No se encontraron productos que coincidan con tu búsqueda.',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            final isAssignedToOtherShelf =
                                product.shelfId != null && product.shelfId != widget.shelf.id;

                            final assignedShelfName = product.shelfId != null
                                ? _shelfMap[product.shelfId] ?? '⚠️ Estante eliminado'
                                : null;

                            return CheckboxListTile(
                              value: _selectedProductIds.contains(product.id),
                              onChanged: isAssignedToOtherShelf
                                  ? null
                                  : (bool? selected) {
                                      setState(() {
                                        if (selected == true) {
                                          _selectedProductIds.add(product.id);
                                        } else {
                                          _selectedProductIds
                                              .remove(product.id);
                                        }
                                      });
                                    },
                              title: Row(
                                children: [
                                  Expanded(child: Text(product.name)),
                                  if (isAssignedToOtherShelf)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$assignedShelfName',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                'Cantidad: ${product.stock} | Bs ${product.price.toStringAsFixed(2)}\nProveedor: ${product.supplier}',
                              ),
                              secondary: CircleAvatar(
                                backgroundImage: NetworkImage(product.imageUrl),
                              ),
                              isThreeLine: true,
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _assignProducts,
        icon: const Icon(Icons.save),
        label: const Text('Guardar Asignación'),
      ),
    );
  }
}
