import 'package:ecommerce_app/core/app_colors.dart';
import 'package:ecommerce_app/core/formatters.dart';
import 'package:ecommerce_app/data/cart_item.dart';
import 'package:ecommerce_app/data/order_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../providers/navigation_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Map<String, IconData> _methods = {
    'Cash on delivery': Icons.payments_outlined,
    'UPI': Icons.qr_code_2,
    'Credit / Debit card': Icons.credit_card,
  };

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  // A snapshot of the cart, so this screen doesn't change
  // when the cart is cleared after the order is placed.
  late final List<CartItem> _items;
  late final double _subtotal;
  late final double _shipping;
  late final double _total;

  String _payment = 'Cash on delivery';
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    final cart = context.read<CartProvider>();
    _items = List<CartItem>.of(cart.items);
    _subtotal = cart.subtotal;
    _shipping = cart.shipping;
    _total = cart.total;
    _name.text = context.read<AuthProvider>().user?.name ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);

    // Pretend we are processing the payment
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final cart = context.read<CartProvider>();
    final order = context.read<OrderProvider>().placeOrder(
          items: _items,
          total: _total,
          address:
              '${_name.text.trim()}, ${_phone.text.trim()}\n${_address.text.trim()}',
          paymentMethod: _payment,
        );
    cart.clear();

    _showSuccess(order);
  }

  void _showSuccess(OrderModel order) {
    final navigator = Navigator.of(context);
    final tabs = context.read<NavigationProvider>();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false, // blocks the Back button while the dialog is open
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded,
                      size: 48, color: Colors.green.shade600),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Order placed!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Order ID: ${order.id}',
                  style: const TextStyle(color: AppColors.textLight)),
              const SizedBox(height: 4),
              const Text('Thank you for shopping with us.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textLight)),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                tabs.setIndex(0);
                navigator.popUntil((r) => r.isFirst);
              },
              child: const Text('Continue shopping'),
            ),
            FilledButton(
              onPressed: () {
                tabs.setIndex(0);
                navigator.popUntil((r) => r.isFirst);
                navigator.pushNamed(AppRoutes.orders);
              },
              child: const Text('View orders'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      );

  Widget _summaryRow(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: bold ? 16 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: bold ? AppColors.textDark : AppColors.textLight,
              )),
          Text(value,
              style: TextStyle(
                fontSize: bold ? 18 : 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor ??
                    (bold ? AppColors.primary : AppColors.textDark),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------- Delivery address ----------
                  _title('Delivery address'),
                  CustomTextField(
                    controller: _name,
                    label: 'Full name',
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter your name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _phone,
                    label: 'Phone number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        RegExp(r'^\d{10}$').hasMatch((v ?? '').trim())
                            ? null
                            : 'Enter a 10-digit phone number',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _address,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                    keyboardType: TextInputType.streetAddress,
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? 'Enter your full address'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // ---------- Payment method ----------
                  _title('Payment method'),
                  ..._methods.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PaymentTile(
                        label: e.key,
                        icon: e.value,
                        selected: _payment == e.key,
                        onTap: () => setState(() => _payment = e.key),
                      ),
                    ),
                  ),
                  const Text(
                    'Demo app: no real payment is processed.',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 24),

                  // ---------- Order summary ----------
                  _title('Order summary'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ..._items.map(
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${i.product.name} × ${i.quantity}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(Formatters.price(i.total)),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 24),
                        _summaryRow('Subtotal', Formatters.price(_subtotal)),
                        _summaryRow(
                          'Shipping',
                          _shipping == 0 ? 'Free' : Formatters.price(_shipping),
                          valueColor:
                              _shipping == 0 ? Colors.green.shade600 : null,
                        ),
                        const Divider(height: 24),
                        _summaryRow('Total', Formatters.price(_total),
                            bold: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    text: 'Place order • ${Formatters.price(_total)}',
                    isLoading: _placing,
                    onPressed: _placeOrder,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- One payment option ----------
class _PaymentTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE6E6EE),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.primary : AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}