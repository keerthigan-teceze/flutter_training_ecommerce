// screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/toast_message.dart';
import 'orders_screen.dart'; // import orders screen

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  Future<bool?> showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Order"),
        content: const Text("Are you sure you want to place this order?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Confirm",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final totalAmount = cartItems.fold<double>(
      0.0,
          (sum, item) => sum + item.product.price,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: cartItems.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : Column(
        children: [
          // Cart items list
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (_, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item.product.title),
                  subtitle: Text("\$${item.product.price.toStringAsFixed(2)}"),
                );
              },
            ),
          ),

          // Total row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "\$${totalAmount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Place order button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("Place Order (Mock Payment)"),
              onPressed: () async {
                final confirmed = await showConfirmDialog(context);
                if (confirmed != true) return;

                final userId = ref.read(currentUserIdProvider);
                if (userId == null) {
                  ToastMessage.show(context, "Please login first");
                  return;
                }

                final order = await ref.read(orderProvider.notifier).checkout(userId);

                if (order != null) {
                  // Show toast
                  ToastMessage.show(context, "Order placed! ID: ${order.id}");

                  // Navigate to My Orders screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );

                  // Optional: simulate webhook in background
                  Future.delayed(const Duration(seconds: 3), () async {
                    await ref.read(orderProvider.notifier)
                        .triggerWebhook(order.id, 'payment_received');
                    ToastMessage.show(context, "Order ${order.id} status updated!");
                  });
                } else {
                  ToastMessage.show(context, "Checkout failed.");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}