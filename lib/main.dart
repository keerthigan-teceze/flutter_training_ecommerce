import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:shopping/providers/auth_provider.dart';
import 'package:shopping/providers/session_provider.dart';

import 'package:shopping/screens/add_product_screen.dart';
import 'package:shopping/screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

import 'models/offline_product.dart';

import 'providers/connectivity_provider.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(OfflineProductAdapter());
  await Hive.openBox<OfflineProduct>('offline_products');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authToken = ref.watch(authProvider);
    final isFullyOnline = ref.watch(isFullyOnlineProvider);

    // Listen for overall online status changes to trigger sync
    ref.listen<bool>(isFullyOnlineProvider, (previous, next) {
      if (next == true && (previous == false || previous == null)) {
        print("🚀 [App] Server reachable! Triggering sync...");
        ref.read(syncServiceProvider).syncOfflineProducts();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connected to Server! Syncing data...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });

    if (authToken == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Column(
          children: [
            if (!isFullyOnline)
              Material(
                child: Container(
                  width: double.infinity,
                  color: Colors.yellow[700],
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  alignment: Alignment.center,
                  child: const SafeArea(
                    bottom: false,
                    child: Text(
                      "Server Unreachable - Offline Mode",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ),
            Expanded(child: child!),
          ],
        );
      },
      home: authToken.isNotEmpty
          ? const HomeScreen()
          : const LoginScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/addProduct': (_) => const AddProductScreen(),
      },
    );
  }
}