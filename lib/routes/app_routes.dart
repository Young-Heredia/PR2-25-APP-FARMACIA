// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../views/home_view.dart';
import '../views/order/inventory_view.dart';
import '../views/order/order_view.dart';
import '../views/product/add_product_view.dart';
import '../views/product/product_manage_view.dart';
import '../views/shelf/shelf_manage_view.dart';
import '../views/shelf/add_shelf_view.dart';
import '../views/notification/notification_view.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomeView(),
  '/inventory': (context) => const InventoryView(),
  '/orders': (context) => const OrderView(),
  '/product-manage': (context) => const ProductManageView(),
  '/add-product': (context) => const AddProductView(),
  '/shelf-manage': (context) => const ShelfManagementPage(),
  '/add-shelf': (context) => const AddShelfView(),
  '/notifications': (context) => NotificationView(),
};
