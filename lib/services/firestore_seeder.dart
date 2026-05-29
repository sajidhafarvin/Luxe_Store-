// ============================================================================
// Firestore Product Seeder
// ============================================================================
//
// HOW TO USE:
//
//   1. Import this file wherever you want to trigger seeding:
//        import 'package:luxe_store/services/firestore_seeder.dart';
//
//   2. Call the seed function (e.g. from a button or from main.dart after
//      Firebase.initializeApp):
//        await seedProductsToFirestore();
//
//   3. The seeder now automatically checks if there are exactly 50 products.
//      If not, it clears the old data and re-seeds all 50 products.
//
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Uploads 50 sample products to the Firestore `products` collection.
///
/// Skips the upload if the collection already contains exactly 50 documents.
/// Otherwise, it wipes the collection and seeds fresh data.
Future<void> seedProductsToFirestore() async {
  final firestore = FirebaseFirestore.instance;
  final productsRef = firestore.collection('products');

  try {
    // ── 1. Check existing count ─────────────────────────────────────────
    final existing = await productsRef.limit(51).get();
    if (existing.docs.length == 50) {
      debugPrint(
        '[Seeder] Products collection already has exactly 50 items. Skipping seed.',
      );
      return;
    }

    debugPrint('[Seeder] Found ${existing.docs.length} existing products. Re-seeding...');

    // ── 2. Clear old data ───────────────────────────────────────────────
    await clearAllProducts();

    // ── 3. Product data ─────────────────────────────────────────────────
    final products = _buildProductList();

    // ── 4. Upload with progress ─────────────────────────────────────────
    final batch = firestore.batch();

    for (int i = 0; i < products.length; i++) {
      final docRef = productsRef.doc(); // auto-generated ID
      batch.set(docRef, products[i]);
      debugPrint('[Seeder] Queued product ${i + 1}/${products.length}: ${products[i]['name']}');
    }

    await batch.commit();

    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('[Seeder] ✅ Successfully uploaded ${products.length} products!');
    debugPrint('═══════════════════════════════════════════════════');
  } catch (e, stack) {
    debugPrint('[Seeder] ❌ Error seeding products: $e');
    debugPrint('$stack');
  }
}

/// Deletes **every** document in the `products` collection.
Future<void> clearAllProducts() async {
  final firestore = FirebaseFirestore.instance;
  final productsRef = firestore.collection('products');

  try {
    final snapshot = await productsRef.get();

    if (snapshot.docs.isEmpty) {
      debugPrint('[Seeder] Products collection is already empty.');
      return;
    }

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    debugPrint(
      '[Seeder] 🗑️  Deleted ${snapshot.docs.length} old products from Firestore.',
    );
  } catch (e) {
    debugPrint('[Seeder] ❌ Error clearing products: $e');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────

List<Map<String, dynamic>> _buildProductList() {
  final List<Map<String, dynamic>> allProducts = [];

  // 1. Women (10 products)
  final womenNames = [
    'Silk Midi Wrap Dress', 'Cashmere Off-Shoulder Top', 'Tailored Wide-Leg Trousers',
    'Velvet Blazer Jacket', 'Embroidered Maxi Skirt', 'Floral Summer Dress',
    'High-Waisted Pencil Skirt', 'Ribbed Knit Turtleneck', 'Pleated Chiffon Blouse',
    'Satin Slip Dress'
  ];
  for (int i = 0; i < 10; i++) {
    allProducts.add(_product(
      name: womenNames[i],
      category: 'Women',
      price: 150 + (i * 15),
      originalPrice: 190 + (i * 20),
      rating: 4.5 + (i % 5) * 0.1,
      reviewsCount: 80 + (i * 12),
      description: 'Elegant and sophisticated ${womenNames[i].toLowerCase()} tailored for the modern woman. Perfect for formal occasions or elevate your daily wardrobe with this premium piece.',
      imageUrl: 'assets/images/products/women/women_product${i + 1}.png',
      materialTitle: 'Premium Fabric Blend',
      materialDescription: 'High-quality sustainable materials. Dry clean recommended.',
      sizes: ['XS', 'S', 'M', 'L', 'XL'],
    ));
  }

  // 2. Men (10 products)
  final menNames = [
    'Classic Charcoal Suit', 'French Cuff Dress Shirt', 'Merino Crew Neck Sweater',
    'Leather Bomber Jacket', 'Linen Relaxed-Fit Chinos', 'Slim-Fit Oxford Shirt',
    'Wool Blend Overcoat', 'Pinstripe Suit Trousers', 'Quilted Vest',
    'Cable Knit Cardigan'
  ];
  for (int i = 0; i < 10; i++) {
    allProducts.add(_product(
      name: menNames[i],
      category: 'Men',
      price: 120 + (i * 25),
      originalPrice: 160 + (i * 30),
      rating: 4.4 + (i % 6) * 0.1,
      reviewsCount: 65 + (i * 15),
      description: 'A timeless ${menNames[i].toLowerCase()} designed with impeccable tailoring. Durable, comfortable, and versatile enough for any smart-casual or formal setting.',
      imageUrl: 'assets/images/products/men/men_product${i + 1}.png',
      materialTitle: 'Refined Wool & Cotton',
      materialDescription: 'Expertly woven for breathability and structure. Professional care.',
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
    ));
  }

  // 3. Kids (10 products)
  final kidsNames = [
    'Boys Polo Shirt Set', 'Girls Tulle Party Dress', 'Denim Dungaree Overalls',
    'Hooded Puffer Jacket', 'Printed Jogger Set', 'Graphic Print T-Shirt',
    'Corduroy Pinafore', 'Knit Bobble Hat', 'Waterproof Raincoat',
    'Classic Canvas Sneakers'
  ];
  for (int i = 0; i < 10; i++) {
    allProducts.add(_product(
      name: kidsNames[i],
      category: 'Kids',
      price: 45 + (i * 8),
      originalPrice: 60 + (i * 10),
      rating: 4.6 + (i % 4) * 0.1,
      reviewsCount: 110 + (i * 5),
      description: 'Comfortable and playful ${kidsNames[i].toLowerCase()}. Made with soft, skin-friendly fabrics to ensure maximum comfort during active play and adventures.',
      imageUrl: 'assets/images/products/kids/kids_product${i + 1}.png',
      materialTitle: 'Organic Cotton',
      materialDescription: '100% organic materials. Machine washable at 40°C.',
      sizes: ['2Y', '4Y', '6Y', '8Y', '10Y', '12Y'],
    ));
  }

  // 4. Accessories (10 products)
  final accNames = [
    'Quilted Leather Tote Bag', 'Reversible Leather Belt', 'Chronograph Wrist Watch',
    'Pearl Drop Earrings', 'Silk Pocket Square Set', 'Aviator Sunglasses',
    'Cashmere Fringed Scarf', 'Suede Crossbody Bag', 'Classic Fedora Hat',
    'Leather Zip Wallet'
  ];
  for (int i = 0; i < 10; i++) {
    allProducts.add(_product(
      name: accNames[i],
      category: 'Accessories',
      price: 85 + (i * 35),
      originalPrice: 110 + (i * 45),
      rating: 4.7 + (i % 3) * 0.1,
      reviewsCount: 200 + (i * 8),
      description: 'Complete your look with this luxurious ${accNames[i].toLowerCase()}. Crafted with exquisite attention to detail, making it the perfect statement piece.',
      imageUrl: 'assets/images/products/accessories/acc_product${i + 1}.png',
      materialTitle: 'Genuine Leather & Metals',
      materialDescription: 'Premium hardware and ethically sourced leather. Wipe clean.',
      sizes: ['One Size'],
    ));
  }

  // 5. Featured (10 products)
  final featuredNames = [
    'Signature Logo Hoodie', 'Premium Canvas Backpack', 'Limited Edition Sneakers',
    'Essential Cotton Tee', 'Minimalist Silver Ring', 'Structured Tote Bag',
    'Double-Breasted Trench', 'High-Top Trainers', 'Woven Leather Belt',
    'Cashmere Beanie'
  ];
  for (int i = 0; i < 10; i++) {
    allProducts.add(_product(
      name: featuredNames[i],
      category: 'Featured',
      price: 95 + (i * 20),
      originalPrice: 130 + (i * 25),
      rating: 4.8 + (i % 2) * 0.1,
      reviewsCount: 310 + (i * 22),
      description: 'Our highly sought-after ${featuredNames[i].toLowerCase()}. Part of the exclusive Featured collection showcasing the absolute best of our seasonal designs.',
      imageUrl: 'assets/images/products/product${i + 1}.png',
      materialTitle: 'Atelier Luxe Exclusive',
      materialDescription: 'Special edition materials. Limited run.',
      sizes: ['S', 'M', 'L', 'XL'], // generic sizes for featured items
    ));
  }

  return allProducts;
}

/// Helper to build a single product map with consistent field names.
Map<String, dynamic> _product({
  required String name,
  required String category,
  required int price,
  required int originalPrice,
  required double rating,
  required int reviewsCount,
  required String description,
  required String imageUrl,
  required String materialTitle,
  required String materialDescription,
  required List<String> sizes,
}) {
  return {
    'brand': 'ATELIER LUXE',
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
    'inStock': true,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
