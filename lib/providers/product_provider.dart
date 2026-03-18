import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';

final apiServiceProvider = Provider((ref) => ApiService());

// Fetch products (GET)
final productProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final userId = ref.watch(currentUserIdProvider);   // or ref.watch(authProvider).userId

  if (userId == null) {
    return []; // or throw if you want
  }
  final data = await api.getProducts();
  final allProducts = data.map((e) => Product.fromJson(e)).toList();

  // Filter: only show products owned by this user
  return allProducts.where((p) => p.userId == userId).toList();

});


// NEW: all products – no filter
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final data = await api.getProducts();
  return data.map((e) => Product.fromJson(e)).toList();
});

// Actions: add/update product
final productActionsProvider = Provider((ref) {
  final api = ref.read(apiServiceProvider);
  return ProductActions(api, ref);
});

class ProductActions {
  final ApiService api;
  final Ref ref;

  ProductActions(this.api, this.ref);

  // Add product
  Future<void> addProduct(String title, int price) async {

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw Exception("Cannot add product: not logged in");
    }

    await api.createProduct({
      "title": title,
      "price": price,
      "userId": userId,
    });

    ref.invalidate(productProvider); // refresh product list
    ref.invalidate(allProductsProvider);
  }

  // Update product
  Future<void> updateProduct(int id, String title, int price) async {

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw Exception("Cannot update product: not logged in");
    }

    await api.updateProduct(id, {
      "title": title,
      "price": price,
      "userId": userId,
    });

    ref.invalidate(productProvider); // refresh product list
    ref.invalidate(allProductsProvider);
  }

  // Delete product
  Future<void> deleteProduct(int id) async {
    await api.deleteProduct(id);

    ref.invalidate(productProvider); // refresh list
    ref.invalidate(allProductsProvider);
  }

}