class WishlistManager {
  static final WishlistManager _instance = WishlistManager._internal();
  factory WishlistManager() => _instance;
  WishlistManager._internal();

  static final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => List.from(_items);

  bool isWishlisted(String productName) {
    return _items.any((item) => item['name'] == productName);
  }

  void toggleWishlist(Map<String, dynamic> product) {
    final index = _items.indexWhere((item) => item['name'] == product['name']);
    if (index != -1) {
      _items.removeAt(index);
    } else {
      _items.add(product);
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  int get itemCount => _items.length;
}
