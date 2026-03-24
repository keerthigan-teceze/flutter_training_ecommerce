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
      
      // Process each offline operation
      for (var product in unsynced) {
        try {
          print("📤 [SyncService] Syncing ${product.operationType.name} operation: ${product.title}...");
          
          bool success = false;
          
          switch (product.operationType) {
            case OfflineOperationType.create:
              success = await _syncCreateOperation(product);
              break;
            case OfflineOperationType.update:
              success = await _syncUpdateOperation(product);
              break;
            case OfflineOperationType.delete:
              success = await _syncDeleteOperation(product);
              break;
          }

          if (success) {
            // Remove the synced item from offline storage
            await product.delete();
            anySynced = true;
            print("✅ [SyncService] Synced: ${product.operationType.name} - ${product.title}");
          } else {
            print("⚠️ [SyncService] Failed to sync ${product.operationType.name}: ${product.title}");
            // Stop syncing and try again later
            break;
          }
        } catch (e) {
          print("❌ [SyncService] Error syncing ${product.title}: $e");
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

  /// Sync a CREATE operation
  Future<bool> _syncCreateOperation(OfflineProduct product) async {
    try {
      await api.createProduct({
        "title": product.title,
        "price": product.price,
        "userId": product.userId,
      });
      return true;
    } catch (e) {
      print("❌ [SyncService] CREATE failed: $e");
      return false;
    }
  }

  /// Sync an UPDATE operation
  Future<bool> _syncUpdateOperation(OfflineProduct product) async {
    if (product.originalProductId == null) {
      print("❌ [SyncService] UPDATE failed: No original product ID");
      return false;
    }
    
    try {
      await api.updateProduct(product.originalProductId!, {
        "title": product.title,
        "price": product.price,
        "userId": product.userId,
      });
      return true;
    } catch (e) {
      print("❌ [SyncService] UPDATE failed: $e");
      return false;
    }
  }

  /// Sync a DELETE operation
  Future<bool> _syncDeleteOperation(OfflineProduct product) async {
    if (product.originalProductId == null) {
      print("❌ [SyncService] DELETE failed: No original product ID");
      return false;
    }
    
    try {
      await api.deleteProduct(product.originalProductId!);
      return true;
    } catch (e) {
      print("❌ [SyncService] DELETE failed: $e");
      return false;
    }
  }

  /// Manually trigger sync (can be called from UI)
  Future<void> triggerSync() async {
    await syncOfflineProducts();
  }
}
