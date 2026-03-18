// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping/screens/cart_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import 'product_list_screen.dart';
import 'all_products_screen.dart';
import 'package:shopping/screens/orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AllProductsScreen(),
    ProductListScreen(),
    CartScreen(),
    OrdersScreen()
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      // Optional: FAB only for "My Products" screen
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addProduct');
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}