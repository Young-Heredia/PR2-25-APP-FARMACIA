// lib/routes/app_routes.dart

import 'package:flutter/material.dart';
import '../views/home_view.dart';
import '../views/inventory_view.dart';
import '../views/order_view.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomeView(),
  '/inventory': (context) => const InventoryView(),
  '/orders': (context) => const OrderView(),
};
