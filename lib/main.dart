import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/providers/auth_provider.dart';
import 'package:shopping/providers/session_provider.dart';
import 'package:shopping/screens/add_product_screen.dart';
import 'package:shopping/screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authToken = ref.watch(authProvider); // this will be null until token loads

    // show a loading screen until token is checked
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