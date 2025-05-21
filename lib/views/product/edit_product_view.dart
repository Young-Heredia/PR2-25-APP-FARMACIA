// lib/views/product/edit_product_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_farmacia/models/product_model.dart';
import 'package:app_farmacia/services/firebase_product_service.dart';
import 'package:app_farmacia/services/firebase_shelf_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:app_farmacia/services/cloudinary_service.dart';

class EditProductView extends StatefulWidget {
  final ProductModel product;

  const EditProductView({super.key, required this.product});

  @override
  State<EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<EditProductView> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseProductService();
  final CloudinaryService cloudinary = CloudinaryService(
    cloudName: 'duiiqydcv',
    uploadPreset: 'pr2_25_app_farmacia',
  );

  File? _selectedImageFile;
  String _imageInputMode = 'URL'; // 'URL' o 'Archivo'

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _supplierController;
  late TextEditingController _imageUrlController;
  late DateTime _selectedDate;
  late String? _shelfId;

  late String _alertMessage;
  late Color _alertColor;
  late IconData _alertIcon;

  String? _shelfName;
  final _shelfService = FirebaseShelfService();

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
    _shelfId = p.shelfId;

    _loadShelfName();

    final now = DateTime.now();
    final diff = _selectedDate.difference(now).inDays;

    if (diff < 0) {
      _alertMessage = 'Este producto ya está vencido.';
      _alertColor = Colors.red.shade300;
      _alertIcon = Icons.warning_amber_rounded;
    } else if (diff == 0) {
      _alertMessage = 'Este producto vence hoy.';
      _alertColor = Colors.deepOrange;
      _alertIcon = Icons.error;
    } else if (diff <= 30) {
      _alertMessage = 'Este producto vence en $diff días.';
      _alertColor = Colors.orange.shade300;
      _alertIcon = Icons.calendar_today;
    } else if (diff <= 60) {
      _alertMessage = 'Este producto vence en $diff días.';
      _alertColor = Colors.blue.shade300;
      _alertIcon = Icons.event_note;
    } else if (diff <= 90) {
      _alertMessage = 'Este producto vence en $diff días.';
      _alertColor = Colors.green.shade300;
      _alertIcon = Icons.check_circle;
    } else {
      _alertMessage = '';
    }

    if (_alertMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_alertMessage),
            backgroundColor: _alertColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16),
          ),
        );
      });
    }
  }

  void _loadShelfName() async {
    if (widget.product.shelfId != null) {
      final shelf = await _shelfService.getShelfById(widget.product.shelfId!);
      if (mounted) {
        setState(() {
          _shelfName = shelf?.name ?? 'Estante eliminado';
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 75);

    if (picked != null) {
      setState(() {
        _selectedImageFile = File(picked.path);
        _imageUrlController.clear();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen seleccionada')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = _imageUrlController.text.trim();

      if (_selectedImageFile != null && imageUrl.isEmpty) {
        final uploadedUrl = await cloudinary.uploadImage(_selectedImageFile!);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen')),
          );
          return;
        }
      }

      final updated = ProductModel(
        id: widget.product.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0.0,
        stock: int.tryParse(_stockController.text) ?? 0,
        imageUrl: imageUrl,
        expirationDate: _selectedDate,
        supplier: _supplierController.text.trim(),
        shelfId: _shelfId,
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
              if (_alertMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _alertColor.withOpacity(0.2),
                    border: Border.all(color: _alertColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(_alertIcon, color: _alertColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _alertMessage,
                          style: TextStyle(
                            color: _alertColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
              if (_shelfName != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    border: Border.all(color: Colors.teal),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2, color: Colors.teal),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Estante asignado: $_shelfName',
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              _textField(_nameController, 'Nombre'),
              _textField(_descController, 'Descripción'),
              _textField(_priceController, 'Precio Bs',
                  inputType: TextInputType.number),
              _textField(_stockController, 'Cantidad',
                  inputType: TextInputType.number),
              _textField(_supplierController, 'Proveedor'),
              DropdownButtonFormField<String>(
                value: _imageInputMode,
                decoration: const InputDecoration(
                  labelText: 'Método de Imagen',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'URL', child: Text('Ingresar URL manual')),
                  DropdownMenuItem(
                      value: 'Archivo', child: Text('Tomar foto o galería')),
                ],
                onChanged: (value) {
                  setState(() {
                    _imageInputMode = value!;
                    _selectedImageFile = null;
                    _imageUrlController.clear();
                  });
                },
              ),
              const SizedBox(height: 12),
              if (_imageInputMode == 'Archivo') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Tomar foto'),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.image),
                        label: const Text('Galería'),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                _textField(_imageUrlController, 'URL Imagen'),
              ],
              const SizedBox(height: 12),
              if (_selectedImageFile != null)
                Image.file(_selectedImageFile!, height: 120)
              else if (_imageUrlController.text.isNotEmpty)
                Image.network(_imageUrlController.text, height: 120),
              const SizedBox(height: 12),
              /*if (_shelfName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    enabled: false,
                    initialValue: _shelfName,
                    decoration: const InputDecoration(
                      labelText: 'Estante Asignado',
                      border: OutlineInputBorder(),
                      filled: true,
                    ),
                  ),
                ),*/
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Guardar Cambios'),
              ),
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
