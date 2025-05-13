// lib/views/edit_product_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class EditProductView extends StatefulWidget {
  final ProductModel product;

  const EditProductView({super.key, required this.product});

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseProductService();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _supplierController;
  late TextEditingController _imageUrlController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p.name);
    _descController = TextEditingController(text: p.description);
    _priceController = TextEditingController(text: p.price.toString());
    _stockController = TextEditingController(text: p.stock.toString());
    _supplierController = TextEditingController(text: p.supplier);
    _imageUrlController = TextEditingController(text: p.imageUrl);
    _selectedDate = p.expirationDate;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updated = ProductModel(
        id: widget.product.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        imageUrl: _imageUrlController.text.trim(),
        expirationDate: _selectedDate,
        supplier: _supplierController.text.trim(),
      );

      await _service.updateProduct(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado con éxito')),
      );
      Navigator.pop(context);
    }
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _textField(_nameController, 'Nombre'),
              _textField(_descController, 'Descripción'),
              _textField(_priceController, 'Precio', inputType: TextInputType.number),
              _textField(_stockController, 'Stock', inputType: TextInputType.number),
              _textField(_supplierController, 'Proveedor'),
              _textField(_imageUrlController, 'URL Imagen'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Guardar Cambios'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Campo requerido' : null,
      ),
    );
  }
}
