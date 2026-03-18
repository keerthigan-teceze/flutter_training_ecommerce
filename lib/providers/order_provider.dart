import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/providers/auth_provider.dart';
import '../services/api_service.dart';
import 'cart_provider.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

// OrderNotifier
class OrderNotifier extends StateNotifier<List<Order>> {
  final ApiService api;
  final Ref ref;

  OrderNotifier(this.ref, this.api) : super([]);

  // Load orders from API
  Future<void> loadOrders(int userId) async {
    try {
      final data = await api.getOrders(userId);

      if (data == null) {
        throw Exception("No data received");
      }

      state = data.map((e) => Order.fromJson(e)).toList();
      print("Orders loaded: ${state.length}");
    } catch (e) {
      print("Load orders error: $e");
      rethrow; // ✅ IMPORTANT
    }
  }

  // Checkout flow
  Future<Order?> checkout(int userId) async {
    final cartItems = ref.read(cartProvider); // get latest cart items
    if (cartItems.isEmpty) return null;

    final cartData = cartItems.map((e) => e.toJson()).toList();
    final res = await api.checkout(userId, cartData);

    final newOrder = Order(
      id: res['id'].toString(),
      status: res['status'] ?? 'pending',
      items: List.from(cartItems),
    );

    // Add new order to state
    state = [...state, newOrder];

    // Clear cart after checkout
    await api.clearCart(userId);
    await ref.read(cartProvider.notifier).loadCart(); // refresh cart

    // Automatic webhook simulation after 3 seconds
    Future.delayed(const Duration(seconds: 3), () async {
      await ref.read(orderProvider.notifier).triggerWebhook(newOrder.id, "paid");
    });

    return newOrder;
  }

  // Webhook simulation
  Future<void> triggerWebhook(String orderId, String event) async {
    final res = await api.triggerWebhook(orderId, event);

    state = state.map((order) {
      if (order.id == orderId) {
        return Order(
          id: order.id,
          status: res['status'], // updated status from DB
          items: order.items,
        );
      }
      return order;
    }).toList();
  }
}

// Provider
final orderProvider = StateNotifierProvider<OrderNotifier, List<Order>>((ref) {
  final api = ref.read(apiServiceProvider);
  return OrderNotifier(ref, api);
});