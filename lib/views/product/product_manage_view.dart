// lib/views/product/product_manage_view.dart

import 'package:app_farmacia/views/product/detail_product_view.dart';
import 'package:app_farmacia/views/product/edit_product_view.dart';
import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/firebase_product_service.dart';
import 'add_product_view.dart';

class ProductManageView extends StatefulWidget {
  const ProductManageView({super.key});

  @override
  State<ProductManageView> createState() => _ProductManageViewState();
}

class _ProductManageViewState extends State<ProductManageView> {
  final service = FirebaseProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Productos')),
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
                    'Cantidad: ${p.stock}  |  Bs ${p.price.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Editar Producto',
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
                      tooltip: 'Eliminar Producto',
                      onPressed: () async {
                        await service.deleteProduct(p.id);
                        setState(() {});
                      },
                    ),
                  ],
                ),
                onTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cargando detalle...'),
                      duration: Duration(milliseconds: 800),
                      backgroundColor: Colors.teal,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16),
                    ),
                  );
                  await Future.delayed(const Duration(milliseconds: 800));
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailProductView(product: p)),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Agregar Producto',
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
