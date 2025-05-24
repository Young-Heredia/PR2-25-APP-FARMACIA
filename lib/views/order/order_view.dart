// lib/views/order/order_view.dart

import 'package:flutter/material.dart';
import 'package:app_farmacia/services/firebase_order_service.dart';
import 'package:app_farmacia/models/order_model.dart';
import 'package:app_farmacia/views/order/order_detail_view.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  final _orderService = FirebaseOrderService();
  late Future<List<OrderModel>> _ordersFuture;

  final Map<DateTime, int> _salesByDay = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getAllOrders();
  }

  Future<void> _refreshOrders() async {
    final newOrders = await _orderService.getAllOrders();
    setState(() {
      _ordersFuture = Future.value(newOrders);
    });
  }

  void _processSales(List<OrderModel> orders) {
    _salesByDay.clear();
    for (final order in orders) {
      final date = DateTime(order.date.year, order.date.month, order.date.day);
      _salesByDay.update(date, (prev) => prev + 1, ifAbsent: () => 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes de Venta')),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('No hay órdenes registradas.'));
          }

          _processSales(orders);

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final count = _salesByDay[
                            DateTime(date.year, date.month, date.day)] ??
                        0;
                    if (count > 0) {
                      return Positioned(
                        bottom: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshOrders,
                  color: Colors.teal,
                  backgroundColor: Colors.white,
                  displacement: 30,
                  strokeWidth: 2,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: orders
                        .where((order) =>
                            _selectedDay == null ||
                            DateTime(order.date.year, order.date.month,
                                    order.date.day) ==
                                DateTime(_selectedDay!.year,
                                    _selectedDay!.month, _selectedDay!.day))
                        .map((order) {
                      final formattedDate =
                          DateFormat('dd-MM-yyyy – HH:mm').format(order.date);
                      final orderCode =
                          '25-${(orders.length - orders.indexOf(order)).toString().padLeft(6, '0')}';
                      final dayNumber = order.date.day.toString();
                      // final totalProducts = order.items.fold(0, (sum, item) => sum + item.quantity);
                      final totalProducts = order.items.length;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailView(order: order),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Orden #$orderCode',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.teal)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _selectedDay != null &&
                                                    DateTime(
                                                            order.date.year,
                                                            order.date.month,
                                                            order.date.day) ==
                                                        DateTime(
                                                            _selectedDay!.year,
                                                            _selectedDay!.month,
                                                            _selectedDay!.day)
                                                ? Colors.teal
                                                : DateUtils.isSameDay(
                                                        order.date,
                                                        DateTime.now())
                                                    ? Colors.orange
                                                    : Colors.grey.shade300,
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            dayNumber,
                                            style: TextStyle(
                                              color: _selectedDay != null &&
                                                      DateTime(
                                                              order.date.year,
                                                              order.date.month,
                                                              order.date.day) ==
                                                          DateTime(
                                                              _selectedDay!
                                                                  .year,
                                                              _selectedDay!
                                                                  .month,
                                                              _selectedDay!.day)
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Bs ${order.total.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$totalProducts productos',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
