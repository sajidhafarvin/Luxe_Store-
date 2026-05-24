class CartManager {
  // Static list — persists for the entire app lifetime, never resets
  static final List<Map<String, dynamic>> _staticItems = [];

  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  List<Map<String, dynamic>> get items => List.from(_staticItems);

  void addItem(Map<String, dynamic> product) {
    final existingIndex = _staticItems.indexWhere((item) =>
        item['name'] == product['name'] && item['size'] == product['size']);

    if (existingIndex != -1) {
      _staticItems[existingIndex]['qty'] =
          (_staticItems[existingIndex]['qty'] as int) + 1;
    } else {
      _staticItems.add({...product, 'qty': product['qty'] ?? 1});
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _staticItems.length) {
      _staticItems.removeAt(index);
    }
  }

  void updateQty(int index, int qty) {
    if (index >= 0 && index < _staticItems.length && qty > 0) {
      _staticItems[index]['qty'] = qty;
    }
  }

  double get totalPrice {
    double total = 0;
    for (var item in _staticItems) {
      String price = item['price']
          .toString()
          .replaceAll('\$', '')
          .replaceAll(',', '');
      try {
        total += double.parse(price) * (item['qty'] as int);
      } catch (e) {
        total += 0;
      }
    }
    return total;
  }

  int get itemCount => _staticItems.length;

  void clear() => _staticItems.clear();
}
