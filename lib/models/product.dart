import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String brand;
  final String category;
  final String name;
  final int price;
  final int originalPrice;
  final double rating;
  final int reviewsCount;
  final String description;
  final String imageUrl;
  final String materialTitle;
  final String materialDescription;
  final List<String> sizes;
  final List<String> colors;
  final bool inStock;
  final Timestamp? createdAt;

  Product({
    required this.id,
    required this.brand,
    required this.category,
    required this.name,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewsCount,
    required this.description,
    required this.imageUrl,
    required this.materialTitle,
    required this.materialDescription,
    required this.sizes,
    required this.colors, 
    required this.inStock,
    this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Safely parse numeric fields in case they were saved as double or string
    final priceRaw = data['price'];
    final price = priceRaw is num
        ? priceRaw.toInt()
        : int.tryParse(priceRaw?.toString() ?? '') ?? 0;

    final originalPriceRaw = data['originalPrice'];
    final originalPrice = originalPriceRaw is num
        ? originalPriceRaw.toInt()
        : int.tryParse(originalPriceRaw?.toString() ?? '') ?? 0;

    final ratingRaw = data['rating'];
    final rating = ratingRaw is num
        ? ratingRaw.toDouble()
        : double.tryParse(ratingRaw?.toString() ?? '') ?? 0.0;

    final reviewsCountRaw = data['reviewsCount'];
    final reviewsCount = reviewsCountRaw is num
        ? reviewsCountRaw.toInt()
        : int.tryParse(reviewsCountRaw?.toString() ?? '') ?? 0;

    return Product(
      id: doc.id,
      brand: data['brand']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      price: price,
      originalPrice: originalPrice,
      rating: rating,
      reviewsCount: reviewsCount,
      description: data['description']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
      materialTitle: data['materialTitle']?.toString() ?? '',
      materialDescription: data['materialDescription']?.toString() ?? '',
      sizes: List<String>.from(data['sizes'] ?? []),
      colors: List<String>.from(data['colors'] ?? ['Default']),
      inStock: data['inStock'] ?? true,
      createdAt: data['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'brand': brand,
      'category': category,
      'name': name,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'description': description,
      'imageUrl': imageUrl,
      'materialTitle': materialTitle,
      'materialDescription': materialDescription,
      'sizes': sizes,
      'colors': colors,
      'inStock': inStock,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Getters
  int get discountPercentage {
    if (originalPrice <= 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }

  bool get isOnSale => price < originalPrice;
}
