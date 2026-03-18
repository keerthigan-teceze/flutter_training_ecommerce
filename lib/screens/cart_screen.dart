// screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/screens/checkout_screen.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/toast_message.dart';
import '../providers/auth_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];
                return ProductCard(
                  product: cartItem.product,
                  onDelete: () async {
                    await ref
                        .read(cartProvider.notifier)
                        .removeFromCart(cartItem);
                    ToastMessage.show(
                        context,
                        "${cartItem.product.title} removed from cart");
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: cartItems.isEmpty
                  ? null
                  : () {
                final userId =
                ref.read(currentUserIdProvider);
                if (userId == null) {
                  ToastMessage.show(
                      context, "Please login first");
                  return;
                }

                // Navigate to CheckoutScreen only
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CheckoutScreen(),
                  ),
                );
              },
              child: const Text("Proceed to Checkout"),
            ),
          ),
        ],
      ),
    );
  }
}