// lib/views/product/add_product_view.dart

import 'package:flutter/material.dart';
import 'package:app_farmacia/models/product_model.dart';
import 'package:app_farmacia/services/firebase_product_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:app_farmacia/services/cloudinary_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';

class AddProductView extends StatefulWidget {
  final ProductModel? product;
  const AddProductView({super.key, this.product});

  @override
  State<AddProductView> createState() => _AddProductViewState();
}

class _AddProductViewState extends State<AddProductView> {
  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseProductService();
  final CloudinaryService cloudinary = CloudinaryService(
    cloudName: 'dxzeoxji9',
    uploadPreset: 'pr2_25_app_farmacia',
  );

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _supplierController = TextEditingController();
  final _imageUrlController = TextEditingController();

  File? _selectedImageFile;
  DateTime? _selectedDate;
  String _imageInputMode = 'URL'; // o 'Archivo'

  Future<int> _getAndroidSDK() async {
    final info = await DeviceInfoPlugin().androidInfo;
    return info.version.sdkInt;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // 🔐 Solicitud de permisos
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de cámara denegado')),
            );
          }
          return;
        }
      }

      if (source == ImageSource.gallery && Platform.isAndroid) {
        final sdk = await _getAndroidSDK();
        if (sdk < 29) {
          final storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permiso de almacenamiento denegado'),
                ),
              );
            }
            return;
          }
        }
      }

// 📷 Selección de imagen
      final picker = ImagePicker();
      final picked = await picker
          .pickImage(
        source: source,
        imageQuality: 75,
        preferredCameraDevice: CameraDevice.rear,
      )
          .catchError((e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudo abrir la cámara o galería: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      });

      if (!mounted || picked == null) return;

// 📐 Recorte cuadrado
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: picked.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 75,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar Imagen',
            toolbarColor: Colors.teal,
            hideBottomControls: true,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Recortar Imagen',
            aspectRatioLockEnabled: true,
          ),
        ],
      );

      if (croppedFile == null) return;

      final imageFile = File(croppedFile.path);

      if (!await imageFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('La imagen seleccionada no es válida')),
          );
        }
        return;
      }

      setState(() {
        _selectedImageFile = imageFile;
        _imageUrlController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen seleccionada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al acceder a la cámara/galería: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      try {
        String imageUrl = _imageUrlController.text.trim();

        // Subir a Cloudinary si aún no se subió
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

        final product = ProductModel(
          id: widget.product?.id ?? '', // Firestore asigna el ID
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          imageUrl: imageUrl,
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
              _textField(_stockController, 'Cantidad',
                  inputType: TextInputType.number),
              _textField(_supplierController, 'Proveedor'),
              DropdownButtonFormField<String>(
                value: _imageInputMode,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar método de imagen',
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
              const SizedBox(height: 16),
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
              ElevatedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(_selectedDate == null
                    ? 'Seleccionar Fecha de Vencimiento'
                    : DateFormat('dd-MM-yyyy').format(_selectedDate!)),
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
