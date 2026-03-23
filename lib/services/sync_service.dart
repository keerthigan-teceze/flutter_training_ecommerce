import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/offline_product.dart';
import '../services/api_service.dart';
import '../providers/product_provider.dart';

final syncServiceProvider = Provider((ref) {
  final api = ref.read(apiServiceProvider);
  return SyncService(api, ref);
});

class SyncService {
  final ApiService api;
  final Ref ref;
  bool _isSyncing = false;

  SyncService(this.api, this.ref);

  Future<void> syncOfflineProducts() async {
    print("🔄 [SyncService] syncOfflineProducts called...");
    
    if (_isSyncing) {
      print("⏳ [SyncService] Already syncing, ignoring request.");
      return;
    }
    
    _isSyncing = true;

    try {
      if (!Hive.isBoxOpen('offline_products')) {
        await Hive.openBox<OfflineProduct>('offline_products');
      }
      
      final box = Hive.box<OfflineProduct>('offline_products');
      final unsynced = box.values.toList();

      if (unsynced.isEmpty) {
        print("✅ [SyncService] No offline products to sync.");
        return;
      }

      print("📦 [SyncService] Found ${unsynced.length} items to sync.");

      bool anySynced = false;
      for (var product in unsynced) {
        try {
          print("📤 [SyncService] Syncing product: ${product.title}...");
          await api.createProduct({
            "title": product.title,
            "price": product.price,
            "userId": product.userId,
          });

          await product.delete(); 
          anySynced = true;
          print("✅ [SyncService] Synced: ${product.title}");
        } catch (e) {
          print("❌ [SyncService] Failed to sync ${product.title}: $e");
          // If it fails, stop and try again later
          break; 
        }
      }

      if (anySynced) {
        ref.invalidate(productProvider);
        ref.invalidate(allProductsProvider);
      }
    } finally {
      _isSyncing = false;
    }
  }
}