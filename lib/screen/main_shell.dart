import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/screen/cart_screen.dart';
import 'package:ecommerce_app/screen/home_screen.dart';
import 'package:ecommerce_app/screen/profile_screen.dart';
import 'package:ecommerce_app/screen/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../cart/cart_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../wishlist/wishlist_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final cartCount =
        context.select<CartProvider, int>((c) => c.itemCount);
    final wishCount =
        context.select<WishlistProvider, int>((w) => w.count);

    return PopScope(
      // Back on another tab returns to Home first, instead of closing the app
      canPop: nav.index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) nav.setIndex(0);
      },
      child: Scaffold(
        // IndexedStack keeps every tab alive, so scroll positions are kept
        body: IndexedStack(
          index: nav.index,
          children: const [
            HomeScreen(),
            WishlistScreen(),
            CartScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: nav.index,
          onDestinationSelected: nav.setIndex,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryLight,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: wishCount > 0,
                label: Text('$wishCount'),
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: Badge(
                isLabelVisible: wishCount > 0,
                label: Text('$wishCount'),
                child: const Icon(Icons.favorite),
              ),
              label: 'Wishlist',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}