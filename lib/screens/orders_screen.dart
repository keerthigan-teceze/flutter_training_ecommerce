import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    try {
      await ref.read(orderProvider.notifier).loadOrders(userId);
      setState(() => _isLoading = false);
    } catch (e) {
      print("Failed to load orders: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? const Center(child: Text("Failed to load orders"))
          : orders.isEmpty
          ? const Center(child: Text("No orders placed yet"))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (_, index) {
          final order = orders[index];

          final totalAmount = order.items.fold<double>(
            0.0,
                (sum, item) => sum + item.product.price,
          );

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            child: ExpansionTile(
              title: Text("Order ${order.id}"),
              subtitle: Text(
                "Status: ${order.status} • Total: \$${totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: order.status == "pending" ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: order.items.map((item) {
                return ListTile(
                  title: Text(item.product.title),
                  trailing: Text(
                      "\$${item.product.price.toStringAsFixed(2)}"),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}