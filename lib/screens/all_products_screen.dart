import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/providers/auth_provider.dart';
import 'package:shopping/providers/cart_provider.dart';
import 'package:shopping/providers/session_provider.dart';
import 'package:shopping/widgets/confirm_dialog.dart';
import '../providers/product_search_provider.dart';
import '../widgets/product_card.dart';

class AllProductsScreen extends ConsumerStatefulWidget {
  const AllProductsScreen({super.key});

  @override
  ConsumerState<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends ConsumerState<AllProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initial load
    Future.microtask(() => ref.read(productSearchProvider.notifier).search(''));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productSearchProvider);
    final notifier = ref.read(productSearchProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Properly log out
              await ref.read(authProvider.notifier).logout();

              // Show confirmation
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logout successfully!")),
                );
              }

              // Navigate to login
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),


      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (value == _searchController.text) {
                    notifier.search(value, reset: true);
                  }
                });
              },
            ),
          ),

          // Product list
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text("No products found"))
                : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onAddToCart: () async {
                    final confirm = await showConfirmDialog(
                      context,
                      title: "Add to Cart",
                      message: "Do you want to add this product to your cart?",
                    );
                    if (confirm == true) {
                      await ref.read(cartProvider.notifier).addToCart(product);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${product.title} added to cart")),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),

          // Pagination buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Previous button
                ElevatedButton(
                  onPressed: notifier.page > 1
                      ? () {
                    notifier.previousPage();
                  }
                      : null,
                  child: const Text("Previous"),
                ),
                const SizedBox(width: 16),
                // Next button
                ElevatedButton(
                  onPressed: notifier.hasMore
                      ? () {
                    notifier.nextPage();
                  }
                      : null,
                  child: const Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}