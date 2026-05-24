import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSeeder {
  FirestoreSeeder({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> seedIfNeeded() async {
    final productsRef = _firestore.collection('products');
    final existing = await productsRef.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

    final categories = [
      {'name': 'Women', 'sortOrder': 1},
      {'name': 'Men', 'sortOrder': 2},
      {'name': 'Kids', 'sortOrder': 3},
      {'name': 'Accessories', 'sortOrder': 4},
    ];

    for (final cat in categories) {
      batch.set(_firestore.collection('categories').doc(cat['name'] as String), {
        ...cat,
        'createdAt': now,
      });
    }

    final products = [
      {
        'name': 'Cashmere Overcoat',
        'description': 'A timeless cashmere overcoat crafted for effortless elegance and warmth.',
        'price': 340.0,
        'originalPrice': 450.0,
        'imageUrl': 'assets/images/products/product1.png',
        'category': 'Women',
        'brand': 'ATELIER LUXE',
        'rating': 4.9,
        'reviewsCount': 128,
        'materialTitle': 'Cashmere Blend',
        'materialDescription': 'Soft-touch cashmere blend with premium lining for comfort.',
      },
      {
        'name': 'Satin Pleated Skirt',
        'description': 'Fluid satin skirt with refined pleats for a polished silhouette.',
        'price': 280.0,
        'originalPrice': 350.0,
        'imageUrl': 'assets/images/products/product2.png',
        'category': 'Women',
        'brand': 'ATELIER LUXE',
        'rating': 4.8,
        'reviewsCount': 76,
        'materialTitle': 'Satin',
        'materialDescription': 'High-shine satin with durable seams and smooth drape.',
      },
      {
        'name': 'Leather Tote',
        'description': 'Structured leather tote designed to fit your daily essentials.',
        'price': 320.0,
        'originalPrice': 400.0,
        'imageUrl': 'assets/images/products/product3.png',
        'category': 'Accessories',
        'brand': 'ATELIER LUXE',
        'rating': 4.7,
        'reviewsCount': 92,
        'materialTitle': 'Genuine Leather',
        'materialDescription': 'Full-grain leather with reinforced handles and metal hardware.',
      },
      {
        'name': 'Velvet Blazer',
        'description': 'Velvet blazer with tailored structure and a luxury finish.',
        'price': 890.0,
        'originalPrice': 1100.0,
        'imageUrl': 'assets/images/products/product4.png',
        'category': 'Men',
        'brand': 'ATELIER LUXE',
        'rating': 4.9,
        'reviewsCount': 54,
        'materialTitle': 'Velvet',
        'materialDescription': 'Premium velvet with soft nap and tailored inner lining.',
      },
      {
        'name': 'Silk Slip Dress',
        'description': 'Minimal silk slip dress made for day-to-night styling.',
        'price': 450.0,
        'originalPrice': 560.0,
        'imageUrl': 'assets/images/products/product5.png',
        'category': 'Women',
        'brand': 'ATELIER LUXE',
        'rating': 4.8,
        'reviewsCount': 63,
        'materialTitle': 'Silk',
        'materialDescription': 'Breathable silk fabric with a smooth, lightweight feel.',
      },
      {
        'name': 'Wrap Coat',
        'description': 'Statement wrap coat with belt closure and modern proportions.',
        'price': 1280.0,
        'originalPrice': 1500.0,
        'imageUrl': 'assets/images/products/product6.png',
        'category': 'Women',
        'brand': 'ATELIER LUXE',
        'rating': 4.9,
        'reviewsCount': 41,
        'materialTitle': 'Wool Blend',
        'materialDescription': 'Warm wool blend with structured shoulders and soft inner lining.',
      },
      {
        'name': 'Oxford Shirt',
        'description': 'Crisp oxford shirt with premium cotton weave.',
        'price': 115.0,
        'originalPrice': 145.0,
        'imageUrl': 'assets/images/products/product8.png',
        'category': 'Men',
        'brand': 'ATELIER LUXE',
        'rating': 4.6,
        'reviewsCount': 88,
        'materialTitle': 'Cotton Oxford',
        'materialDescription': 'Durable cotton fabric with breathable weave and clean finish.',
      },
      {
        'name': 'Kids Linen Set',
        'description': 'Comfortable linen set made for play and everyday wear.',
        'price': 89.0,
        'originalPrice': 120.0,
        'imageUrl': 'assets/images/products/kids/kids_product1.png',
        'category': 'Kids',
        'brand': 'LUXE KIDS',
        'rating': 4.7,
        'reviewsCount': 32,
        'materialTitle': 'Linen Blend',
        'materialDescription': 'Soft linen blend designed for comfort and easy movement.',
      },
      {
        'name': 'Gold Necklace',
        'description': 'Classic gold necklace for a refined finishing touch.',
        'price': 220.0,
        'originalPrice': 280.0,
        'imageUrl': 'assets/images/products/product10.png',
        'category': 'Accessories',
        'brand': 'ATELIER LUXE',
        'rating': 4.8,
        'reviewsCount': 119,
        'materialTitle': 'Gold Finish',
        'materialDescription': 'Polished finish with secure clasp and minimal design.',
      },
      {
        'name': 'Leather Sandals',
        'description': 'Premium leather sandals crafted for comfort and durability.',
        'price': 410.0,
        'originalPrice': 500.0,
        'imageUrl': 'assets/images/products/product9.png',
        'category': 'Accessories',
        'brand': 'ATELIER LUXE',
        'rating': 4.6,
        'reviewsCount': 47,
        'materialTitle': 'Leather',
        'materialDescription': 'Soft leather upper with supportive sole and premium stitching.',
      },
    ];

    for (final p in products) {
      batch.set(productsRef.doc(), {
        ...p,
        'createdAt': now,
      });
    }

    await batch.commit();
  }
}

