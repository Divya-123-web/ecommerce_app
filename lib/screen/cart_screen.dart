import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/core/formatters.dart';
import 'package:ecommerce_app/data/cart_item.dart';
import 'package:ecommerce_app/presentation/empty_state.dart';
import 'package:ecommerce_app/presentation/quantity_selector.dart';
import 'package:ecommerce_app/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/quantity_selector.dart';
import '../../providers/navigation_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<CartProvider>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My cart'),
        actions: [
          IconButton(
            tooltip: 'My orders',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.orders),
          ),
          if (!cart.isEmpty)
            IconButton(
              tooltip: 'Clear cart',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              message: 'Add products you love and they will show up here.',
              actionLabel: 'Start shopping',
              onAction: () => context.read<NavigationProvider>().setIndex(0),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _CartTile(item: cart.items[i]),
                      ),
                    ),
                    _Summary(cart: cart),
                  ],
                ),
              ),
            ),
    );
  }
}

// ---------- One row in the cart ----------
class _CartTile extends StatelessWidget {
  final CartItem item;

  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final id = item.product.id;

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart, // swipe left to delete
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        cart.remove(id);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
              SnackBar(content: Text('${item.product.name} removed')));
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 84,
                width: 84,
                child: AppNetworkImage(url: item.product.imageUrl),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      InkWell(
                        onTap: () => cart.remove(id),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.textLight),
                      ),
                    ],
                  ),
                  Text(
                    '${Formatters.price(item.product.price)} each',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      QuantitySelector(
                        value: item.quantity,
                        onAdd: () => cart.increment(id),
                        onRemove: () => cart.decrement(id),
                      ),
                      Text(
                        Formatters.price(item.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Price summary + checkout button ----------
class _Summary extends StatelessWidget {
  final CartProvider cart;

  const _Summary({required this.cart});

  Widget _row(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 18 : 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ??
                  (bold ? AppColors.primary : AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('Subtotal', Formatters.price(cart.subtotal)),
              _row(
                'Shipping',
                cart.shipping == 0 ? 'Free' : Formatters.price(cart.shipping),
                valueColor: cart.shipping == 0 ? Colors.green.shade600 : null,
              ),
              if (cart.shipping > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 2, bottom: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Add ${Formatters.price(cart.amountForFreeShipping)} more for free shipping',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primary),
                    ),
                  ),
                ),
              const Divider(height: 20),
              _row('Total', Formatters.price(cart.total), bold: true),
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Checkout',
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.checkout),
              ),
            ],
          ),
        ),
      ),
    );
  }
}