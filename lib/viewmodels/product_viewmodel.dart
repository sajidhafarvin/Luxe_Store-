import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductViewModel extends ChangeNotifier {
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;

  List<Product> get products => _filteredProducts;
  bool get isLoading => _isLoading;

  ProductViewModel() {
    fetchAllProducts();
  }

  void filterProducts(String category) {
    if (category == 'All') {
      _filteredProducts = _allProducts;
    } else {
      _filteredProducts = _allProducts.where((p) => p.category == category).toList();
    }
    notifyListeners();
  }

  Future<void> fetchAllProducts() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Mock delay
    
    _allProducts = [
      Product(
        id: 'p1',
        name: 'Classic White T-Shirt',
        description: '100% cotton classic white t-shirt.',
        price: 29,
        originalPrice: 39,
        imageUrl: 'https://via.placeholder.com/300x400/2563EB/FFFFFF?text=White+T-Shirt',
        category: 'Men',
        brand: 'BrandX',
        rating: 4.5,
        reviewsCount: 120,
        materialTitle: 'Cotton',
        materialDescription: '100% Cotton',
        sizes: ['S', 'M', 'L'],
        colors: ['White', 'Black', 'Grey'],
        inStock: true,
      ),
      Product(
        id: 'p2',
        name: 'Floral Summer Dress',
        description: 'Beautiful floral dress for summer.',
        price: 59,
        originalPrice: 79,
        imageUrl: 'https://picsum.photos/300/400?random=2',
        category: 'Women',
        brand: 'BrandY',
        rating: 4.8,
        reviewsCount: 85,
        materialTitle: 'Polyester',
        materialDescription: '100% Polyester',
        sizes: ['S', 'M'],
        colors: ['Floral Blue', 'Floral Pink', 'Floral Green'],
        inStock: true,
      ),
      Product(
        id: 'p3',
        name: 'Denim Jacket',
        description: 'Stylish blue denim jacket.',
        price: 89,
        originalPrice: 109,
        imageUrl: 'https://picsum.photos/300/400?random=3',
        category: 'Men',
        brand: 'BrandZ',
        rating: 4.2,
        reviewsCount: 45,
        materialTitle: 'Denim',
        materialDescription: '100% Denim',
        sizes: ['M', 'L', 'XL'],
        colors: ['Blue', 'Black', 'Grey'],
        inStock: true,
      ),
      Product(
        id: 'p4',
        name: 'Leather Handbag',
        description: 'Premium quality leather handbag.',
        price: 129,
        originalPrice: 159,
        imageUrl: 'https://via.placeholder.com/300x400/F59E0B/FFFFFF?text=Handbag',
        category: 'Accessories',
        brand: 'LuxuryBrand',
        rating: 4.9,
        reviewsCount: 200,
        materialTitle: 'Leather',
        materialDescription: 'Genuine Leather',
        sizes: ['One Size'],
        colors: ['Brown', 'Black', 'Tan'],
        inStock: true,
      ),
    ];
    _filteredProducts = _allProducts;

    _isLoading = false;
    notifyListeners();
  }
}
