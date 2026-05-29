import 'package:flutter/material.dart';
import '../models/order.dart';
import '../utils/cart_manager.dart';

class CartProvider with ChangeNotifier {
  /// Returns the current items in the cart mapped to a List of CartItem models.
  List<CartItem> get cartItems {
    return CartManager().items.map((item) => CartItem.fromMap(item)).toList();
  }

  /// Returns the total price of the items in the cart.
  double get totalAmount => CartManager().totalPrice;

  /// Clears the items in the cart.
  void clearCart() {
    CartManager().clear();
    notifyListeners();
  }
}
