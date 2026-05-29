import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;

  /// Returns products filtered by the currently selected category.
  List<Product> get filteredProducts => getProductsByCategory(_selectedCategory);

  /// Update the selected category and notify listeners.
  void setCategory(String category) {
    if (_selectedCategory == category) return; // no-op if unchanged
    _selectedCategory = category;
    notifyListeners();
  }

  /// Fetch all products from Firestore.
  /// Safe to call multiple times — skips if already loading.
  Future<void> fetchProducts() async {
    if (_isLoading) return; // prevent double-fetch

    print('📥 Fetching products...');
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      final fetched = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();

      _products = fetched;

      print('📄 Found ${snapshot.docs.length} documents');
      print('✅ Converted to ${_products.length} products');

      // Log unique categories so you can spot mismatches
      final cats = _products.map((p) => p.category).toSet();
      debugPrint('[ProductProvider] Categories in Firestore: $cats');
    } catch (e, stack) {
      // Keep existing _products so the UI doesn't go blank on error
      debugPrint('[ProductProvider] Error fetching products: $e');
      debugPrint('$stack');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filter products by category name (case-insensitive).
  List<Product> getProductsByCategory(String category) {
    if (category.isEmpty || category.toLowerCase() == 'all') {
      return List.unmodifiable(_products);
    }

    final result = _products
        .where((product) =>
            product.category.toLowerCase() == category.toLowerCase())
        .toList();

    debugPrint(
      '[ProductProvider] getProductsByCategory("$category") → ${result.length} matches '
      '(out of ${_products.length} total)',
    );

    return result;
  }

  Product? getProductById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }
}
