import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';

class WishlistButton extends StatelessWidget {
  final String productId;
  final double size;

  const WishlistButton({super.key, required this.productId, this.size = 34});

  @override
  Widget build(BuildContext context) {
    // select = rebuild only this heart when its own state changes
    final wished = context.select<WishlistProvider, bool>(
      (w) => w.isWishlisted(productId),
    );

    return Material(
      color: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          final added = context.read<WishlistProvider>().toggle(productId);
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 1),
                content:
                    Text(added ? 'Added to wishlist' : 'Removed from wishlist'),
              ),
            );
        },
        child: SizedBox(
          width: size,
          height: size,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              wished ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(wished),
              size: size * 0.55,
              color: wished ? Colors.red.shade400 : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}