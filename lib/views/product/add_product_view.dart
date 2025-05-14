// lib/views/product/add_product_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/product_model.dart';
import '../../services/firebase_product_service.dart';

class AddProductView extends StatefulWidget {
  final ProductModel? product;
  const AddProductView({super.key, this.product});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseProductService();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _supplierController = TextEditingController();
  final _imageUrlController = TextEditingController();
  DateTime? _selectedDate;

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        final product = ProductModel(
          id: widget.product?.id ?? '', // Firestore asignará el ID
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          imageUrl: _imageUrlController.text.trim(),
          expirationDate: _selectedDate!,
          supplier: _supplierController.text.trim(),
        );

        if (widget.product == null) {
          await _service.addProduct(product);
        } else {
          await _service.updateProduct(product);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto guardado con éxito')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  void _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _textField(_nameController, 'Nombre'),
              _textField(_descController, 'Descripción'),
              _textField(_priceController, 'Precio',
                  inputType: TextInputType.number),
              _textField(_stockController, 'Stock',
                  inputType: TextInputType.number),
              _textField(_supplierController, 'Proveedor'),
              _textField(_imageUrlController, 'URL Imagen'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDate == null
                    ? 'Seleccionar Fecha de Vencimiento'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Guardar Producto'),
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
