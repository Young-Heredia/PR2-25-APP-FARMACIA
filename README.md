# PR2-25-APP-FARMACIA

**FarmaciaApp** es una aplicación móvil desarrollada en **Flutter** que permite la **gestión integral de productos farmacéuticos**, incluyendo inventario, ventas, vencimientos, estantes y alertas visuales. Está diseñada para funcionar sobre **Firebase (Firestore)** como backend serverless en tiempo real y utiliza **Cloudinary** para almacenamiento de imágenes.

---

## Características Principales

- Registro, edición y eliminación de productos farmacéuticos.
- Control de stock y vencimiento con indicadores de colores.
- Gestión y visualización por estantes físicos.
- Registro de ventas con subtotal y total automáticos.
- Historial de ventas y dashboard estadístico.
- Sincronización en tiempo real con Firebase.
- Subida y recorte de imágenes desde cámara, galería o URL.
- Notificaciones visuales de productos por vencer.
- Interfaz moderna, responsiva e intuitiva.

---

## Tecnologías Utilizadas

| Área        | Tecnología                                                                 |
|-------------|-----------------------------------------------------------------------------|
| **Frontend**| Flutter + Dart                                                              |
| **Backend** | Firebase Cloud Firestore (NoSQL)                                            |
| **Imágenes**| Cloudinary (subida y gestión de imágenes)                                   |
| **Otros**   | Firebase Core, Image Picker, Image Cropper, Intl, Table Calendar, Smooth Page Indicator, Permission Handler |

---

## Estructura del Proyecto
lib/
├── main.dart
├── firebase_options.dart
├── services/
│ ├── cloudinary_service.dart
│ └── firebase_product_service.dart
├── models/
│ └── product_model.dart
├── views/
│ ├── splash_screen_view.dart
│ ├── home_view.dart
│ ├── product/
│ │ ├── add_product_view.dart
│ │ └── edit_product_view.dart
│ ├── shelf/
│ │ ├── add_shelf_view.dart
│ │ └── shelf_manage_view.dart
│ └── order/
│ ├── inventory_view.dart
│ └── order_view.dart
└── notification/
└── notification_view.dart

---

## Dependencias Principales (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.13.1
  cloud_firestore: ^5.6.8
  image_picker: ^1.0.7
  image_cropper: ^9.1.0
  http: ^1.4.0
  intl: ^0.20.2
  table_calendar: ^3.0.9
  permission_handler: ^12.0.0+1
  smooth_page_indicator: ^1.1.0
  cupertino_icons: ^1.0.8
  device_info_plus: ^10.1.0
```

## Instalación y Configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/Young-Heredia/PR2-25-APP-FARMACIA.git
cd PR2-25-APP-FARMACIA
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

Crear un proyecto en Firebase Console

Habilitar Firestore y Firebase Storage

Descargar y agregar `firebase_options.dart` al proyecto

Confirmar la inicialización en `main.dart`:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### 4. Configurar Cloudinary

Crear una cuenta gratuita en [https://cloudinary.com](https://cloudinary.com)

Obtener:

- `cloudName`
- `uploadPreset`

Configurar en `cloudinary_service.dart`:

```dart
final CloudinaryService cloudinary = CloudinaryService(
  cloudName: 'tu_cloud_name',
  uploadPreset: 'tu_upload_preset',
);
```

### ▶️ Ejecutar la App

Conectar un emulador o dispositivo real Android y ejecutar:

```bash
flutter run
```

### Pruebas Funcionales

- Verifica el CRUD completo de productos.
- Simula ventas con productos próximos a vencer.
- Recorta imágenes desde galería o cámara y verifica la subida a Cloudinary.
- Asegúrate de ver notificaciones visuales, alertas de vencimiento y dashboard actualizado.


### Autor / Contacto Técnico

- **Nombre:** Edwin Heredia Saravia  
- **Rol:** Desarrollador FullStack | GitMaster | DB Architect | QA  
- **Repositorio Git:** [https://github.com/Young-Heredia/PR2-25-APP-FARMACIA](https://github.com/Young-Heredia/PR2-25-APP-FARMACIA)  
- **Correo:** hse1010674@est.univalle.edu
