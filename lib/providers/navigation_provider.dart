import 'package:flutter/material.dart';
import '../../providers/navigation_provider.dart';

class NavigationProvider extends ChangeNotifier {
  int _index = 0; // 0 Home, 1 Wishlist, 2 Cart, 3 Profile

  int get index => _index;

  void setIndex(int value) {
    if (value == _index) return;
    _index = value;
    notifyListeners();
  }
}