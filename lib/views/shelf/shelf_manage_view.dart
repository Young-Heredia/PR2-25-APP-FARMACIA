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
  final TextEditingController _searchController = TextEditingController();

  List<ShelfModel> _allShelves = [];
  List<ShelfModel> _filteredShelves = [];

  @override
  void initState() {
    super.initState();
    _loadShelves();
    _searchController.addListener(_applySearch);
  }

  void _loadShelves() async {
    final shelves = await service.getAllShelves();
    setState(() {
      _allShelves = shelves;
      _filteredShelves = shelves;
    });
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredShelves = _allShelves
          .where((shelf) => shelf.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Estantes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre de estante...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: _filteredShelves.isEmpty
                ? const Center(child: Text('No se encontraron estantes.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredShelves.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final shelf = _filteredShelves[index];
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
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.teal.shade100,
                              child: Text(
                                '${shelf.productsCount}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal),
                              ),
                            ),
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
                                if (wasUpdated == true) _loadShelves();
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
                        onTap: () async {
                          final wasUpdated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ShelfDetailView(shelf: shelf),
                            ),
                          );
                          if (wasUpdated == true) _loadShelves();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-shelf').then((wasAdded) {
            if (wasAdded == true) _loadShelves();
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
      _loadShelves();
    }
  }
}
