import 'package:ecommerce_app/core/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/wishlist_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('You will need to login again to continue.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final tabs = context.read<NavigationProvider>();
    await context.read<AuthProvider>().logout();
    tabs.setIndex(0); // next login starts on Home
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final orders = context.select<OrderProvider, int>((o) => o.count);
    final wishlist = context.select<WishlistProvider, int>((w) => w.count);
    final cartItems = context.select<CartProvider, int>((c) => c.itemCount);

    final name = user?.name ?? 'Guest';
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ---------- Avatar, name, email ----------
              const SizedBox(height: 8),
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  child: Text(initial,
                      style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: Text(user?.email ?? '',
                    style: const TextStyle(color: AppColors.textLight)),
              ),
              const SizedBox(height: 24),

              // ---------- Stats ----------
              Row(
                children: [
                  _StatCard(value: '$orders', label: 'Orders'),
                  const SizedBox(width: 12),
                  _StatCard(value: '$wishlist', label: 'Wishlist'),
                  const SizedBox(width: 12),
                  _StatCard(value: '$cartItems', label: 'In cart'),
                ],
              ),
              const SizedBox(height: 24),

              // ---------- Menu ----------
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _MenuTile(
                        icon: Icons.receipt_long_outlined,
                        title: 'My orders',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.orders),
                      ),
                      const Divider(height: 1),
                      _MenuTile(
                        icon: Icons.favorite_border,
                        title: 'My wishlist',
                        onTap: () =>
                            context.read<NavigationProvider>().setIndex(1),
                      ),
                      const Divider(height: 1),
                      _MenuTile(
                        icon: Icons.info_outline,
                        title: 'About ShopEasy',
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: 'ShopEasy',
                          applicationVersion: '1.0.0',
                          applicationIcon: const Icon(
                              Icons.shopping_bag_rounded,
                              size: 40,
                              color: AppColors.primary),
                          children: const [
                            SizedBox(height: 8),
                            Text('A Flutter e-commerce app built with '
                                'Provider, Hive and Clean Architecture.'),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      _MenuTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        color: Colors.red.shade400,
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('ShopEasy v1.0.0',
                    style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
      onTap: onTap,
    );
  }
}