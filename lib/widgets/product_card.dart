import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(product.title),
        subtitle: Text("\$${product.price}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)

              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),

            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),

            if (onAddToCart != null)
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.green),
                onPressed: onAddToCart,
              ),
          ],
        ),
      ),
    );
  }
}