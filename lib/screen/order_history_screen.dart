import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/core/formatters.dart';
import 'package:ecommerce_app/data/order_model.dart';
import 'package:ecommerce_app/presentation/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/app_network_image.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_in.dart';


class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: orders.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'Your placed orders will show up here.',
              actionLabel: 'Start shopping',
              onAction: () => Navigator.popUntil(context, (r) => r.isFirst),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => FadeSlideIn(
                    index: i,
                    child: _OrderCard(order: orders[i]),
                  ),
                ),
              ),
            ),
    );
  }
}

// ---------- One order (tap to expand) ----------
class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      // Removes the default divider lines of ExpansionTile
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Expanded(
                child: Text(order.id,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(order.status,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.green.shade700)),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${Formatters.date(order.date)}\n'
              '${order.itemCount} items • ${Formatters.price(order.total)}',
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ),
          children: [
            const Divider(),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 44,
                        width: 44,
                        child: AppNetworkImage(url: item.product.imageUrl),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${item.product.name} × ${item.quantity}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(Formatters.price(item.total),
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Delivery address',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(order.address,
                  style: const TextStyle(color: AppColors.textLight)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paid via ${order.paymentMethod}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textLight)),
                Text(Formatters.price(order.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}