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

    // Initial check for sync on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isOnline = ref.read(connectivityProvider).value ?? false;
      if (isOnline) {
        ref.read(syncServiceProvider).syncOfflineProducts();
      }
    });

    // Listen for connectivity changes to trigger sync
    ref.listen<AsyncValue<bool>>(connectivityProvider, (previous, next) {
      if (next.value == true) {
        print("Back Online! Triggering sync...");
        ref.read(syncServiceProvider).syncOfflineProducts();
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