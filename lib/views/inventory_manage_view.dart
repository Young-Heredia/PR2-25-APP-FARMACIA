// lib/views/inventory_manage_view.dart

import 'package:app_farmacia/views/edit_product_view.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'add_product_view.dart';

class InventoryManageView extends StatefulWidget {
  const InventoryManageView({super.key});

  @override
  State<InventoryManageView> createState() => _InventoryManageViewState();
}

class _InventoryManageViewState extends State<InventoryManageView> {
  final service = FirebaseProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión del Inventario')),
      body: FutureBuilder<List<ProductModel>>(
        future: service.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos registrados.'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(p.imageUrl),
                ),
                title: Text(p.name),
                subtitle: Text(
                    'Stock: ${p.stock}  |  \$${p.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Editar producto',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProductView(
                                product: p), // ✅ PASA EL PRODUCTO
                          ),
                        ).then((_) =>
                            setState(() {})); // Refresca la lista al volver
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Eliminar producto',
                      onPressed: () async {
                        await service.deleteProduct(p.id);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddProductView()),
                  ).then(
                      (_) => setState(() {})); // refrescar lista tras registrar
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar producto',
        onPressed: () {
          Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddProductView()),
          ).then((wasAdded) {
            if (wasAdded == true) setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
