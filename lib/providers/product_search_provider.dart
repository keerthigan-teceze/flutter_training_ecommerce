import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

// Provider for ApiService
final apiServiceProvider = Provider((ref) => ApiService());

// StateNotifier for search + pagination
class ProductSearchNotifier extends StateNotifier<List<Product>> {
  final ApiService api;
  int _page = 1;
  int _limit = 10;
  bool _hasMore = true;
  String _query = '';

  ProductSearchNotifier(this.api) : super([]);

  bool get hasMore => _hasMore;
  int get page => _page;

  Future<void> search(String query, {bool reset = false}) async {
    if (reset) {
      _page = 1;
      _hasMore = true;
      state = [];
      _query = query;
    }

    if (_page < 1) _page = 1;

    final response = await api.searchProducts(_query, page: _page, limit: _limit);
    final products = response.map((e) => Product.fromJson(e)).toList();

    // Determine if more pages exist
    _hasMore = products.length == _limit;

    state = products; // replace the state with current page
  }

  void nextPage() {
    if (_hasMore) {
      _page++;
      search(_query);
    }
  }

  void previousPage() {
    if (_page > 1) {
      _page--;
      search(_query);
    }
  }

  void reset() {
    _page = 1;
    _hasMore = true;
    state = [];
  }
}

// Provider
final productSearchProvider =
StateNotifierProvider<ProductSearchNotifier, List<Product>>(
      (ref) => ProductSearchNotifier(ref.read(apiServiceProvider)),
);