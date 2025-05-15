// lib/views/shelf/add_shelf_view.dart

import 'package:flutter/material.dart';
import '../../models/shelf_model.dart';
import '../../services/firebase_shelf_service.dart';

class AddShelfView extends StatefulWidget {
  const AddShelfView({super.key});

  @override
  State<AddShelfView> createState() => _AddShelfViewState();
}

class _AddShelfViewState extends State<AddShelfView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final FirebaseShelfService _shelfService = FirebaseShelfService();

  bool _isSaving = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final shelf = ShelfModel(
        id: '', // Firestore asignará el ID
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        productsCount: 0, // Nuevo estante empieza sin productos
        assignedProducts: [],
      );

      try {
        await _shelfService.addShelf(shelf);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estante guardado con éxito')),
        );

        Navigator.pop(context, true); // Volver y refrescar la lista
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Estante')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Estante *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Guardar Estante'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
