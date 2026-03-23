import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:shopping/providers/auth_provider.dart';
import '../providers/connectivity_provider.dart';
import '../models/offline_product.dart';

import '../services/api_service.dart';
import '../models/product_model.dart';
import '../services/sync_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

// Fetch products (GET) - Merges Online and Offline products
final productProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) {
    return [];
  }

  // Trigger sync in background every time the product list is refreshed
  // (Using Future.microtask to avoid modification during build)
  Future.microtask(() {
    ref.read(syncServiceProvider).syncOfflineProducts();
  });

  List<Product> onlineProducts = [];
  try {
    final data = await api.getProducts();
    onlineProducts = data.map((e) => Product.fromJson(e)).toList();
  } catch (e) {
    print("Failed to fetch products from API: $e");
  }

  // Fetch offline products from Hive
  final box = Hive.box<OfflineProduct>('offline_products');
  final offlineProducts = box.values
      .where((p) => p.userId == userId)
      .map((p) => Product(
            id: -1, // Use a dummy ID for offline products
            title: "${p.title} (Syncing...)",
            price: p.price.toDouble(),
            userId: p.userId,
          ))
      .toList();

  final allItems = [...offlineProducts, ...onlineProducts];
  return allItems.where((p) => p.userId == userId).toList();
});

// all products
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final data = await api.getProducts();
    return data.map((e) => Product.fromJson(e)).toList();
  } catch (e) {
    return [];
  }
});

// Actions
final productActionsProvider = Provider((ref) {
  final api = ref.read(apiServiceProvider);
  return ProductActions(api, ref);
});

class ProductActions {
  final ApiService api;
  final Ref ref;

  ProductActions(this.api, this.ref);

  Future<bool> addProduct(String title, int price) async {
    final userId = ref.read(currentUserIdProvider);

    if (userId == null) {
      throw Exception("Not logged in");
    }

    bool apiSuccess = false;
    try {
      await api.createProduct({
        "title": title,
        "price": price,
        "userId": userId,
      });
      apiSuccess = true;
    } catch (e) {
      print("API failed, saving to offline storage: $e");
      apiSuccess = false;
    }

    // If the API call failed, save to Hive
    if (!apiSuccess) {
      final box = Hive.box<OfflineProduct>('offline_products');
      await box.add(
        OfflineProduct(
          title: title,
          price: price,
          userId: userId,
          createdAt: DateTime.now(),
        ),
      );
    }

    ref.invalidate(productProvider);
    ref.invalidate(allProductsProvider);
    
    return apiSuccess;
  }

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

    ref.invalidate(productProvider);
    ref.invalidate(allProductsProvider);
  }

  Future<void> deleteProduct(int id) async {
    await api.deleteProduct(id);

    ref.invalidate(productProvider);
    ref.invalidate(allProductsProvider);
  }
}