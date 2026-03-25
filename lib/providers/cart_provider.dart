// providers/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/models/product_model.dart';
import 'package:shopping/models/cart_item_model.dart';
import 'package:shopping/services/api_service.dart';
import 'package:shopping/providers/auth_provider.dart';

final cartProvider =
StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  final api = ref.read(apiServiceProvider);
  return CartNotifier(ref, api);
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  final Ref ref;
  final ApiService api;

  CartNotifier(this.ref, this.api) : super([]) {
    loadCart(); // load cart immediately if user is logged in
  }

  int? get userId => ref.read(currentUserIdProvider); // always get current userId

  Future<void> loadCart() async {
    final _userId = userId;
    if (_userId == null) return;
    final data = await api.getCart(_userId);
    state = data.map((e) => CartItem.fromJson(e)).toList();
    print("Cart loaded: ${state.length} items");
  }

  Future<void> addToCart(Product product) async {
    final _userId = userId;
    if (_userId == null) {
      print("Cannot add to cart: user not logged in");
      return;
    }

    final item = {
      "userId": _userId,
      "productId": product.id,
      "title": product.title,
      "price": product.price,
    };

    print("Adding to cart: $item"); // debug
    await api.addToCart(item);       // call API
    await loadCart();                // refresh cart
    print("${product.title} added to cart successfully");
  }

  Future<void> removeFromCart(CartItem cartItem) async {
    final _userId = userId;
    if (_userId == null) return;

    await api.removeFromCart(cartItem.id);
    await loadCart();
  }
}