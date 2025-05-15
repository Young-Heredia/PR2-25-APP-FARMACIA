// lib/views/shelf/edit_shelf_view.dart

import 'package:flutter/material.dart';
import '../../models/shelf_model.dart';
import '../../services/firebase_shelf_service.dart';

class EditShelfPage extends StatefulWidget {
  final ShelfModel shelf;

  const EditShelfPage({super.key, required this.shelf});

  @override
  State<EditShelfPage> createState() => _EditShelfPageState();
}

class _EditShelfPageState extends State<EditShelfPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseShelfService();

  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shelf.name);
    _descController = TextEditingController(text: widget.shelf.description);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedShelf = ShelfModel(
        id: widget.shelf.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        productsCount: widget.shelf.productsCount, // No se modifica
        assignedProducts: widget.shelf.assignedProducts,
      );

      await _service.updateShelf(updatedShelf);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estante actualizado con éxito')),
      );
      Navigator.pop(context, true); // Retornar éxito
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Estante')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Nombre del Estante', required: true),
              const SizedBox(height: 16),
              _buildTextField(_descController, 'Descripción (opcional)'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Actualizar Estante'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool required = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }
}
