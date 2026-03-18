import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red, // color for the selected icon
      unselectedItemColor: Colors.grey, // color for unselected icons
      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'All Products',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'My Products',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'My Cart',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'My Orders',
        ),
      ],
    );
  }
}