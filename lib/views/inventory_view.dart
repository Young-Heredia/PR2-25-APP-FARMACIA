// lib/views/inventory_view.dart

import 'package:flutter/material.dart';
import '../services/firebase_product_service.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import 'product/add_product_view.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final service = FirebaseProductService();
  //double totalPrice = 0;

  @override
  void initState() {
    super.initState();
    // Si no estás usando un producto directamente, puedes borrar este bloque
    /*
  final p = widget.product;
  if (p != null) {
    _nameController.text = p.name;
    _descController.text = p.description;
    _priceController.text = p.price.toString();
    _stockController.text = p.stock.toString();
    _supplierController.text = p.supplier;
    _imageUrlController.text = p.imageUrl;
    _selectedDate = p.expirationDate;
  }
  */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventario de Productos')),
      body: FutureBuilder<List<ProductModel>>(
        future: service.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos.'));
          }

          final products = snapshot.data!;
          final totalPrice =
              products.fold(0.0, (sum, item) => sum + item.price);

          return Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 100), // espacio para el botón
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ProductCard(
                      image: p.imageUrl,
                      name: p.name,
                      description: p.description,
                      price: p.price,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddProductView(product: p),
                          ),
                        ).then((_) => setState(() {}));
                      },
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: buildBottomBar(context, totalPrice),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductView()),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
      //bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget buildBottomBar(BuildContext context, double totalPrice) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total Price',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          // Botón "ORDER NOW"
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Orden enviada")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            child: const Text(
              'ORDER NOW',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
