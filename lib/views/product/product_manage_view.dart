// lib/views/product/product_manage_view.dart

import 'package:app_farmacia/prueba.dart';
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
              final status = _getExpirationStatus(p);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(p.imageUrl),
                ),
                title: Row(
                  children: [
                    Expanded(child: Text(p.name)),
                    Tooltip(
                      message: status['tooltip'],
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: status['color'],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          status['icon'],
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
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

  Map<String, dynamic> _getExpirationStatus(ProductModel p) {
    final now = DateTime.now();
    final days = p.expirationDate.difference(now).inDays;

    if (days < 0) {
      return {
        'icon': Icons.warning_amber_rounded,
        'color': Colors.red,
        'tooltip': 'Medicamento vencido',
      };
    } else if (days == 0) {
      return {
        'icon': Icons.circle,
        'color': Colors.redAccent,
        'tooltip': 'Vence hoy',
      };
    } else if (days <= 30) {
      return {
        'icon': Icons.circle,
        'color': Colors.orange,
        'tooltip': 'Vence en 30 días',
      };
    } else if (days <= 60) {
      return {
        'icon': Icons.circle,
        'color': Colors.blue,
        'tooltip': 'Vence en 60 días',
      };
    } else if (days <= 90) {
      return {
        'icon': Icons.circle,
        'color': Colors.green,
        'tooltip': 'Vence en 90 días',
      };
    } else {
      return {
        'icon': Icons.check,
        'color': Colors.green,
        'tooltip': 'Vence después de 90 días',
      };
    }
  }
}
