// lib/views/shelf/shelf_manage_view.dart

import 'package:flutter/material.dart';
import '../../models/shelf_model.dart';
import '../../services/firebase_shelf_service.dart';
import 'edit_shelf_view.dart';
import 'detail_shelf_view.dart';

class ShelfManagementPage extends StatefulWidget {
  const ShelfManagementPage({super.key});

  @override
  State<ShelfManagementPage> createState() => _ShelfManagementPageState();
}

class _ShelfManagementPageState extends State<ShelfManagementPage> {
  final service = FirebaseShelfService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Estantes'),
      ),
      body: FutureBuilder<List<ShelfModel>>(
        future: service.getAllShelves(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay estantes registrados.'));
          }

          final shelves = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: shelves.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final shelf = shelves[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 24,
                  child: Icon(Icons.inventory_2),
                ),
                title: Text(shelf.name),
                subtitle: Text(shelf.description),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${shelf.productsCount} productos',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      tooltip: 'Editar Estante',
                      onPressed: () async {
                        final wasUpdated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditShelfPage(shelf: shelf),
                          ),
                        );
                        if (wasUpdated == true) {
                          setState(() {});
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Eliminar Estante',
                      onPressed: () async {
                        await _confirmDelete(context, shelf.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShelfDetailView(shelf: shelf),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-shelf').then((wasAdded) {
            if (wasAdded == true) setState(() {});
          });
        },
        tooltip: 'Agregar Estante',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String shelfId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Estante'),
        content: const Text('¿Estás seguro de eliminar este estante?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () =>
                // TODO: Ejecutar eliminación
                Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await service.deleteShelf(shelfId);
      setState(() {}); // Refrescar la lista
    }
  }
}
