// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../views/home_view.dart';
import '../views/inventory_view.dart';
import '../views/order_view.dart';
import '../views/product/add_product_view.dart';
import '../views/product/product_manage_view.dart';
import '../views/shelf/shelf_manage_view.dart';
import '../views/shelf/add_shelf_view.dart';
import '../views/shelf/edit_shelf_view.dart';
import '../views/shelf/detail_shelf_view.dart';
import '../views/shelf/assign_products_to_shelf_view.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomeView(),
  '/inventory': (context) => const InventoryView(),
  '/orders': (context) => const OrderView(),
  '/add-product': (context) => const AddProductView(),
  '/inventory-manage': (context) => const InventoryManageView(),
  '/shelf-manage': (context) => const ShelfManagementPage(),
  '/add-shelf': (context) => const AddShelfView(),
  // '/edit-shelf': (context) => const EditShelfView(),
  // '/detail-shelf': (context) => const DetailShelfView(), 
  // '/assign-products-shelf': (context) => const AssignProductsToShelfPagePlaceholder(),
};
