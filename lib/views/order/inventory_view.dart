// lib/views/order/inventory_view.dart

import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../../services/firebase_product_service.dart';
import '../../services/firebase_order_service.dart';
import '../../widgets/product_card.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final productService = FirebaseProductService();
  final orderService = FirebaseOrderService();
  final Map<String, int> productQuantities = {};

  late Future<List<ProductModel>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> _products = [];
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<ProductModel>> _loadProducts() async {
    final loaded = await productService.getAllProducts();
    _products = loaded;
    _filteredProducts = loaded;
    for (var p in loaded) {
      productQuantities[p.id] = 0;
    }
    return loaded;
  }

  void _applySearch() {
  final query = _searchController.text.toLowerCase();
  setState(() {
    _filteredProducts = _products.where((p) {
      return p.name.toLowerCase().contains(query) ||
             p.description.toLowerCase().contains(query) ||
             p.supplier.toLowerCase().contains(query);
    }).toList();
  });
}

  double get totalPrice {
    return _products.fold(0.0, (sum, p) {
      final qty = productQuantities[p.id] ?? 0;
      return sum + (p.price * qty);
    });
  }

  void _incrementQty(String productId) {
    setState(() {
      productQuantities[productId] = (productQuantities[productId] ?? 0) + 1;
    });
  }

  void _decrementQty(String productId) {
    setState(() {
      if ((productQuantities[productId] ?? 0) > 0) {
        productQuantities[productId] = productQuantities[productId]! - 1;
      }
    });
  }

  Future<void> _submitOrder() async {
    final selectedItems = _products
        .where((p) => productQuantities[p.id]! > 0)
        .map((p) => OrderItem(
              productId: p.id,
              productName: p.name,
              price: p.price,
              quantity: productQuantities[p.id]!,
            ))
        .toList();

    if (selectedItems.isEmpty) return;

    final newOrder = OrderModel(
      id: '',
      date: DateTime.now(),
      items: selectedItems,
      total: totalPrice,
    );

    try {
      await orderService.addOrder(newOrder);
      if (!mounted) return;

      setState(() {
        for (var p in _products) {
          productQuantities[p.id] = 0;
        }
        _productsFuture = _loadProducts();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Orden registrada con éxito')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar orden: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Productos')),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 
                        'Buscar por nombre, descripción o laboratorio...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),                    
                    const SizedBox(height: 24),
                    const Text(
                      '📦 Productos en Inventario',
                      style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_filteredProducts.isEmpty)
                      const Center(
                        child: 
                        Text('No se encontraron coincidencias.')),
                    ..._filteredProducts.map((p) => ProductCard(
                          image: p.imageUrl,
                          name: p.name,
                          description: p.description,
                          price: p.price,
                          quantity: productQuantities[p.id] ?? 0,
                          onAdd: () => _incrementQty(p.id),
                          onRemove: () => _decrementQty(p.id),
                        )),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: buildBottomBar(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                'Bs ${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          // Botón "ORDENAR AHORA"
          ElevatedButton.icon(
            onPressed: totalPrice > 0 ? _submitOrder : null,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text('COMPRAR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: totalPrice > 0 ? Colors.teal : Colors.grey,
              padding: 
              const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
            ),
          ),
        ],
      ),
    );
  }
}
