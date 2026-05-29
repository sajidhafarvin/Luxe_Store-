import 'package:flutter/material.dart';
import '../models/product.dart';

class HomeViewModel extends ChangeNotifier {
  final List<String> _categories = ['All', 'Men', 'Women', 'Kids', 'Accessories'];
  String _selectedCategory = 'All';
  List<Product> _featuredProducts = [];
  bool _isLoading = false;

  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  List<Product> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;

  HomeViewModel() {
    fetchHomeData();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> fetchHomeData() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Mock delay

    _featuredProducts = [
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
        inStock: true,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
