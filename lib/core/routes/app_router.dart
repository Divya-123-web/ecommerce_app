import 'package:ecommerce_app/data/product.dart';
import 'package:ecommerce_app/models/product.dart';
import 'package:ecommerce_app/screen/cart_screen.dart';
import 'package:ecommerce_app/screen/checkout_screen.dart';
import 'package:ecommerce_app/screen/home_screen.dart';
import 'package:ecommerce_app/screen/login_screen.dart';
import 'package:ecommerce_app/screen/main_shell.dart';
import 'package:ecommerce_app/screen/order_history_screen.dart';
import 'package:ecommerce_app/screen/product_details_screen.dart';
import 'package:ecommerce_app/screen/product_list_screen.dart';
import 'package:ecommerce_app/screen/register_screen.dart';
import 'package:ecommerce_app/screen/splash_screen.dart';
import 'package:ecommerce_app/screen/wishlist_screen.dart';
import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/product/product_list_screen.dart';
import '../../presentation/screens/product/product_details_screen.dart';
import '../../presentation/screens/cart/cart_screen.dart';
import '../../presentation/screens/wishlist/wishlist_screen.dart';
import '../../presentation/screens/checkout/checkout_screen.dart';
import '../../presentation/screens/orders/order_history_screen.dart';
import '../../presentation/screens/main/main_shell.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const productList = '/products';
  static const productDetails = '/product-details';
  static const cart = '/cart';
  static const wishlist = '/wishlist';
  static const checkout = '/checkout';
  static const orders = '/orders';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Widget page;
    switch (settings.name) {
      case AppRoutes.login:
        page = const LoginScreen();
        break;
      case AppRoutes.register:
        page = const RegisterScreen();
        break;
      case AppRoutes.home:
        page = const MainShell();
        break;
      case AppRoutes.productList:
        page = ProductListScreen(focusSearch: settings.arguments == true);
        break;
      case AppRoutes.productDetails:
        page = ProductDetailsScreen(product: settings.arguments as Product);
        break;
      case AppRoutes.cart:
        page = const CartScreen();
        break;
      case AppRoutes.wishlist:
        page = const WishlistScreen();
        break;
      case AppRoutes.checkout:
        page = const CheckoutScreen();
        break;
      case AppRoutes.orders:
        page = const OrderHistoryScreen();
        break;
      default:
        page = const SplashScreen();
    }

    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }
}