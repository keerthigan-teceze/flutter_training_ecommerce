import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/screens/add_product_screen.dart';
import 'package:shopping/screens/edit_product_screen.dart';
import 'package:shopping/widgets/confirm_dialog.dart';
import 'package:shopping/widgets/toast_message.dart';
import 'package:shopping/models/product_model.dart';
import 'package:shopping/providers/product_provider.dart';
import 'package:shopping/widgets/product_card.dart';



class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final productsAsync = ref.watch(productProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Catalog"),
      ),

      body:
      productsAsync.when(
        data: (products) {
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (_, index) {
              final product = products[index];

              // Disable edit for products that are still syncing (id = -1)
              final canEdit = product.id != -1;

              return ProductCard(
                product: product,

                //edit - only enabled for synced products
                onEdit: canEdit
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProductScreen(product: product),
                          ),
                        );
                      }
                    : null,

                //delete - handle offline created products (id=-1) differently
                onDelete: product.id == -1
                    ? () async {
                        // For offline-created products, show message that they can't be deleted yet
                        await showConfirmDialog(
                          context,
                          title: "Cannot Delete",
                          message: "This product is still syncing. Please wait until it's synced to server before deleting.",
                        );
                      }
                    : () async {
                        final confirm = await showConfirmDialog(
                          context,
                          title: "Delete Product",
                          message: "Are you sure you want to delete this product?",
                        );

                        if (confirm == true) {
                          final success = await ref.read(productActionsProvider).deleteProduct(product.id);
                          if (success) {
                            ToastMessage.show(context, "Product deleted successfully!");
                          } else {
                            ToastMessage.show(context, "Delete saved for sync (offline)");
                          }
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