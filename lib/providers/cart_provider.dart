import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  final String storeId; // المتغير الجديد لحفظ معرف المتجر

  CartItem({required this.id, required this.title, required this.quantity, required this.price, required this.storeId});
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;
  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) => total += cartItem.price * cartItem.quantity);
    return total;
  }

  void addItem(String productId, String title, double price, String storeId) {
    if (_items.containsKey(productId)) {
      _items.update(productId, (existing) => CartItem(
        id: existing.id, title: existing.title, quantity: existing.quantity + 1, price: existing.price, storeId: existing.storeId
      ));
    } else {
      _items.putIfAbsent(productId, () => CartItem(
        id: DateTime.now().toString(), title: title, quantity: 1, price: price, storeId: storeId
      ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
