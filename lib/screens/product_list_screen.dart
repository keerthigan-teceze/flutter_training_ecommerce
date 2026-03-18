import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/providers/session_provider.dart';
import 'package:shopping/screens/add_product_screen.dart';
import 'package:shopping/screens/edit_product_screen.dart';
import 'package:shopping/widgets/confirm_dialog.dart';
import 'package:shopping/widgets/toast_message.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';



class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final productsAsync = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Catalog"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // ✅ Clear session state
              ref.read(sessionProvider.notifier).state = false;
              ToastMessage.show(context, "Logout successfully!");
              // Navigate back to login screen
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),

      body:
      productsAsync.when(
        data: (products) {
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, index) {
              final product = products[index];

              return ProductCard(
                product: product,

                //edit
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProductScreen(product: product),
                    ),
                  );
                },

                //delete
                onDelete: () async {
                  final confirm = await showConfirmDialog(
                    context,
                    title: "Delete Product",
                    message: "Are you sure you want to delete this product?",
                  );

                  if (confirm == true) {
                    await ref.read(productActionsProvider).deleteProduct(product.id);
                    ToastMessage.show(context, "Product deleted successfully!");
                  }
                },

              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}