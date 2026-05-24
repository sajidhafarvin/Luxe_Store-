class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String brand;
  final double? originalPrice;
  final double rating;
  final int reviewsCount;
  final String? materialTitle;
  final String? materialDescription;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.brand = 'ATELIER LUXE',
    this.originalPrice,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.materialTitle,
    this.materialDescription,
  });

  factory Product.fromFirestore(String id, Map<String, dynamic> data) {
    final priceRaw = data['price'];
    final originalRaw = data['originalPrice'];
    return Product(
      id: id,
      name: (data['name'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      price: priceRaw is num ? priceRaw.toDouble() : double.tryParse(priceRaw.toString()) ?? 0,
      imageUrl: (data['imageUrl'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      brand: (data['brand'] ?? 'ATELIER LUXE').toString(),
      originalPrice: originalRaw == null
          ? null
          : (originalRaw is num ? originalRaw.toDouble() : double.tryParse(originalRaw.toString())),
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0,
      reviewsCount: (data['reviewsCount'] is num) ? (data['reviewsCount'] as num).toInt() : 0,
      materialTitle: data['materialTitle']?.toString(),
      materialDescription: data['materialDescription']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'brand': brand,
      if (originalPrice != null) 'originalPrice': originalPrice,
      'rating': rating,
      'reviewsCount': reviewsCount,
      if (materialTitle != null) 'materialTitle': materialTitle,
      if (materialDescription != null) 'materialDescription': materialDescription,
    };
  }
}
