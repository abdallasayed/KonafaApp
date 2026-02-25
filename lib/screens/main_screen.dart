import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'home_screen.dart';
import 'cart_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('شاشة العروض قريباً')),
    const CartScreen(),
    const Center(child: Text('حسابي')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        indicatorColor: Colors.orange.shade200,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: Colors.deepOrange), label: 'الرئيسية'),
          const NavigationDestination(icon: Icon(Icons.local_offer_outlined), selectedIcon: Icon(Icons.local_offer, color: Colors.deepOrange), label: 'العروض'),
          NavigationDestination(
            icon: Consumer<CartProvider>(
              builder: (_, cart, ch) => Badge(
                label: Text(cart.itemCount.toString()),
                isLabelVisible: cart.itemCount > 0,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
            ),
            selectedIcon: const Icon(Icons.shopping_cart, color: Colors.deepOrange),
            label: 'السلة',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person, color: Colors.deepOrange), label: 'حسابي'),
        ],
      ),
    );
  }
}
