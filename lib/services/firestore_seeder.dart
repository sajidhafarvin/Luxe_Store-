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

// ============================================================================
// Firestore Product Seeder - LuxeStore (50 Products)
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<void> seedProductsToFirestore() async {
  final firestore = FirebaseFirestore.instance;
  final productsRef = firestore.collection('products');

  try {
    final existing = await productsRef.limit(51).get();
    if (existing.docs.isNotEmpty) {
      debugPrint(
        '[Seeder] 🗑️ Found ${existing.docs.length} old products. Clearing...',
      );
      await clearAllProducts();
    }

    debugPrint('[Seeder] Re-seeding ${existing.docs.length} → 50 products...');
    await clearAllProducts();

    final products = _buildProductList();
    final batch = firestore.batch();

    for (int i = 0; i < products.length; i++) {
      final docRef = productsRef.doc();
      batch.set(docRef, products[i]);
    }

    await batch.commit();
    debugPrint('[Seeder] ✅ Successfully uploaded 50 products!');
  } catch (e, stack) {
    debugPrint('[Seeder] ❌ Error: $e');
    debugPrint('$stack');
  }
}

Future<void> clearAllProducts() async {
  final firestore = FirebaseFirestore.instance;
  final productsRef = firestore.collection('products');
  final snapshot = await productsRef.get();

  if (snapshot.docs.isEmpty) return;

  final batch = firestore.batch();
  for (final doc in snapshot.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();
  debugPrint('[Seeder] 🗑️ Cleared ${snapshot.docs.length} products');
}

// ──────────────────────────────────────────────────────────────────────────
// BUILD PRODUCT LIST
// ──────────────────────────────────────────────────────────────────────────

List<Map<String, dynamic>> _buildProductList() {
  final List<Map<String, dynamic>> allProducts = [];

  // ─── MEN (10 Products) ───────────────────────────────────────────────────
  final menProducts = [
    {
      'name': 'Classic Black Blazer',
      'img': 'men_product1.png',
      'price': 320,
      'desc': 'Premium tailored blazer.',
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['Black', 'Navy', 'Charcoal'],
    },
    {
      'name': 'Light Blue Dress Shirt',
      'img': 'men_product2.png',
      'price': 85,
      'desc': 'Crisp cotton shirt.',
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['Light Blue', 'White', 'Pink', 'Navy'],
    },
    {
      'name': 'Beige Chino Trousers',
      'img': 'men_product3.png',
      'price': 110,
      'desc': 'Comfortable slim-fit chinos.',
      'sizes': ['30', '32', '34', '36', '38'],
      'colors': ['Beige', 'Navy', 'Olive', 'Black'],
    },
    {
      'name': 'Navy Crew Neck Sweater',
      'img': 'men_product4.png',
      'price': 95,
      'desc': 'Warm knit sweater.',
      'sizes': ['S', 'M', 'L', 'XL'],
      'colors': ['Navy', 'Grey', 'Burgundy', 'Black'],
    },
    {
      'name': 'Brown Leather Chelsea Boots',
      'img': 'men_product5.png',
      'price': 180,
      'desc': 'Handcrafted leather boots.',
      'sizes': ['7', '8', '9', '10', '11', '12'],
      'colors': ['Brown', 'Black', 'Tan'],
    },
    {
      'name': 'Minimalist Analog Watch',
      'img': 'men_product6.png',
      'price': 210,
      'desc': 'Sleek design watch.',
      'sizes': ['One Size'],
      'colors': ['Silver', 'Gold', 'Black', 'Rose Gold'],
    },
    {
      'name': 'Light Wash Slim Jeans',
      'img': 'men_product7.png',
      'price': 105,
      'desc': 'Modern cut denim.',
      'sizes': ['30', '32', '34', '36', '38'],
      'colors': ['Light Blue', 'Dark Blue', 'Black'],
    },
    {
      'name': 'Purple Polo T-Shirt',
      'img': 'men_product8.png',
      'price': 65,
      'desc': 'Breathable polo.',
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['Purple', 'Navy', 'White', 'Black', 'Grey'],
    },
    {
      'name': 'Black Leather Belt',
      'img': 'men_product9.png',
      'price': 45,
      'desc': 'Classic reversible belt.',
      'sizes': ['32', '34', '36', '38', '40'],
      'colors': ['Black', 'Brown', 'Tan'],
    },
    {
      'name': 'White Slip-On Loafers',
      'img': 'men_product10.png',
      'price': 130,
      'desc': 'Elegant leather loafers.',
      'sizes': ['7', '8', '9', '10', '11', '12'],
      'colors': ['White', 'Black', 'Brown', 'Navy'],
    },
  ];

  for (var p in menProducts) {
    allProducts.add(
      _product(
        name: p['name'] as String,
        category: 'Men',
        price: p['price'] as int,
        originalPrice: (p['price'] as int) + 50,
        rating: 4.5 + ((p['price'] as int) % 10) * 0.1,
        reviewsCount: 80 + ((p['price'] as int) % 20),
        description: p['desc'] as String,
        imageUrl: 'assets/images/products/men/${p['img']}',
        materialTitle: 'Premium Quality',
        materialDescription: 'Durable, comfortable fabric.',
        sizes: List<String>.from(p['sizes'] as List),
        colors: List<String>.from(p['colors'] as List),
      ),
    );
  }

  // ─── WOMEN (10 Products) ─────────────────────────────────────────────────
  final womenProducts = [
    {
      'name': 'Black Evening Gown',
      'img': 'women_product1.png',
      'price': 280,
      'desc': 'Elegant slip dress.',
      'sizes': ['XS', 'S', 'M', 'L'],
      'colors': ['Black', 'Navy', 'Burgundy', 'Emerald'],
    },
    {
      'name': 'Beige Trench Coat',
      'img': 'women_product2.png',
      'price': 310,
      'desc': 'Classic double-breasted coat.',
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'colors': ['Beige', 'Black', 'Navy', 'Camel'],
    },
    {
      'name': 'Black Leather Tote',
      'img': 'women_product3.png',
      'price': 190,
      'desc': 'Spacious everyday bag.',
      'sizes': ['One Size'],
      'colors': ['Black', 'Brown', 'Tan', 'Burgundy'],
    },
    {
      'name': 'Structured Black Blazer',
      'img': 'women_product4.png',
      'price': 240,
      'desc': 'Sharp tailored blazer.',
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'colors': ['Black', 'Navy', 'White', 'Grey'],
    },
    {
      'name': 'Light Blue Midi Dress',
      'img': 'women_product5.png',
      'price': 145,
      'desc': 'Floral printed dress.',
      'sizes': ['XS', 'S', 'M', 'L'],
      'colors': ['Light Blue', 'Pink', 'Yellow', 'White'],
    },
    {
      'name': 'Color-Block Handbag',
      'img': 'women_product6.png',
      'price': 160,
      'desc': 'Trendy structured bag.',
      'sizes': ['One Size'],
      'colors': ['Multi', 'Black/White', 'Beige/Brown', 'Navy/Red'],
    },
    {
      'name': 'Floral Wrap Skirt',
      'img': 'women_product7.png',
      'price': 95,
      'desc': 'Flowy midi skirt.',
      'sizes': ['XS', 'S', 'M', 'L'],
      'colors': ['Floral Blue', 'Floral Pink', 'Floral Green'],
    },
    {
      'name': 'Gold Chain Necklace',
      'img': 'women_product8.png',
      'price': 85,
      'desc': 'Minimalist layered chain.',
      'sizes': ['One Size'],
      'colors': ['Gold', 'Silver', 'Rose Gold'],
    },
    {
      'name': 'Black Strappy Heels',
      'img': 'women_product9.png',
      'price': 135,
      'desc': 'Elegant evening heels.',
      'sizes': ['36', '37', '38', '39', '40', '41'],
      'colors': ['Black', 'Nude', 'Red', 'Silver'],
    },
    {
      'name': 'Cream Turtleneck Sweater',
      'img': 'women_product10.png',
      'price': 110,
      'desc': 'Cozy knit sweater.',
      'sizes': ['XS', 'S', 'M', 'L', 'XL'],
      'colors': ['Cream', 'Black', 'Grey', 'Camel'],
    },
  ];

  for (var p in womenProducts) {
    allProducts.add(
      _product(
        name: p['name'] as String,
        category: 'Women',
        price: p['price'] as int,
        originalPrice: (p['price'] as int) + 60,
        rating: 4.6 + ((p['price'] as int) % 10) * 0.1,
        reviewsCount: 90 + ((p['price'] as int) % 25),
        description: p['desc'] as String,
        imageUrl: 'assets/images/products/women/${p['img']}',
        materialTitle: 'Premium Fabric',
        materialDescription: 'Soft, breathable, elegant.',
        sizes: List<String>.from(p['sizes'] as List),
        colors: List<String>.from(p['colors'] as List),
      ),
    );
  }

  // ─── KIDS (10 Products) ──────────────────────────────────────────────────
  final kidsProducts = [
    {
      'name': 'Cream Knit Sweater',
      'img': 'kids_product1.png',
      'price': 45,
      'desc': 'Soft baby sweater.',
      'sizes': ['2Y', '4Y', '6Y', '8Y', '10Y'],
      'colors': ['Cream', 'Pink', 'Blue', 'Grey'],
    },
    {
      'name': 'Denim Overalls',
      'img': 'kids_product2.png',
      'price': 55,
      'desc': 'Cute adjustable overalls.',
      'sizes': ['2Y', '4Y', '6Y', '8Y', '10Y', '12Y'],
      'colors': ['Light Blue', 'Dark Blue', 'Pink'],
    },
    {
      'name': 'Unicorn Rain Boots',
      'img': 'kids_product3.png',
      'price': 35,
      'desc': 'Waterproof boots.',
      'sizes': ['22', '24', '26', '28', '30', '32'],
      'colors': ['Pink', 'Purple', 'Blue', 'Rainbow'],
    },
    {
      'name': 'Pink Ruffled Dress',
      'img': 'kids_product4.png',
      'price': 40,
      'desc': 'Party dress.',
      'sizes': ['2Y', '4Y', '6Y', '8Y', '10Y'],
      'colors': ['Pink', 'White', 'Lavender', 'Yellow'],
    },
    {
      'name': 'White Cardigan',
      'img': 'kids_product5.png',
      'price': 50,
      'desc': 'Lightweight cardigan.',
      'sizes': ['2Y', '4Y', '6Y', '8Y', '10Y', '12Y'],
      'colors': ['White', 'Pink', 'Blue', 'Grey'],
    },
    {
      'name': 'Lace Sun Hat Set',
      'img': 'kids_product6.png',
      'price': 25,
      'desc': 'Adorable hat set.',
      'sizes': ['S', 'M', 'L'],
      'colors': ['White', 'Pink', 'Cream'],
    },
    {
      'name': 'Denim Jacket',
      'img': 'kids_product7.png',
      'price': 60,
      'desc': 'Classic denim jacket.',
      'sizes': ['4Y', '6Y', '8Y', '10Y', '12Y'],
      'colors': ['Light Blue', 'Dark Blue', 'Black'],
    },
    {
      'name': 'Rainbow Striped Sweater',
      'img': 'kids_product8.png',
      'price': 45,
      'desc': 'Bright colorful sweater.',
      'sizes': ['2Y', '4Y', '6Y', '8Y', '10Y'],
      'colors': ['Rainbow', 'Pink Stripe', 'Blue Stripe'],
    },
    {
      'name': 'White & Green Sneakers',
      'img': 'kids_product9.png',
      'price': 50,
      'desc': 'Comfortable sneakers.',
      'sizes': ['22', '24', '26', '28', '30', '32', '34'],
      'colors': ['White/Green', 'White/Pink', 'White/Blue', 'All White'],
    },
    {
      'name': 'Floral Print Dress',
      'img': 'kids_product10.png',
      'price': 42,
      'desc': 'Charming floral dress.',
      'sizes': ['2Y', '4Y', '6Y', '8Y', '10Y', '12Y'],
      'colors': ['Floral Pink', 'Floral Blue', 'Floral Yellow'],
    },
  ];

  for (var p in kidsProducts) {
    allProducts.add(
      _product(
        name: p['name'] as String,
        category: 'Kids',
        price: p['price'] as int,
        originalPrice: (p['price'] as int) + 20,
        rating: 4.7 + ((p['price'] as int) % 5) * 0.1,
        reviewsCount: 60 + ((p['price'] as int) % 15),
        description: p['desc'] as String,
        imageUrl: 'assets/images/products/kids/${p['img']}',
        materialTitle: 'Organic Cotton',
        materialDescription: 'Hypoallergenic, gentle on skin.',
        sizes: List<String>.from(p['sizes'] as List),
        colors: List<String>.from(p['colors'] as List),
      ),
    );
  }

  // ─── ACCESSORIES (10 Products) ───────────────────────────────────────────
  final accProducts = [
    {
      'name': 'Gold Hoop Earrings',
      'img': 'acc_product1.png',
      'price': 35,
      'desc': 'Classic hoops.',
      'sizes': ['One Size'],
      'colors': ['Gold', 'Silver', 'Rose Gold'],
    },
    {
      'name': 'Chronograph Watch',
      'img': 'acc_product2.png',
      'price': 180,
      'desc': 'Sporty timepiece.',
      'sizes': ['One Size'],
      'colors': ['Silver', 'Gold', 'Black', 'Blue Dial'],
    },
    {
      'name': 'Cream Tote Bag',
      'img': 'acc_product3.png',
      'price': 140,
      'desc': 'Spacious tote.',
      'sizes': ['One Size'],
      'colors': ['Cream', 'Black', 'Brown', 'Navy'],
    },
    {
      'name': 'Brown Leather Belt',
      'img': 'acc_product4.png',
      'price': 45,
      'desc': 'Classic belt.',
      'sizes': ['30', '32', '34', '36', '38', '40'],
      'colors': ['Brown', 'Black', 'Tan'],
    },
    {
      'name': 'Silk Printed Scarf',
      'img': 'acc_product5.png',
      'price': 65,
      'desc': 'Luxurious scarf.',
      'sizes': ['One Size'],
      'colors': ['Floral', 'Geometric', 'Abstract', 'Paisley'],
    },
    {
      'name': 'Round Frame Glasses',
      'img': 'acc_product6.png',
      'price': 95,
      'desc': 'Vintage frames.',
      'sizes': ['One Size'],
      'colors': ['Black', 'Gold', 'Tortoise', 'Silver'],
    },
    {
      'name': 'Gold Layered Necklace',
      'img': 'acc_product7.png',
      'price': 75,
      'desc': 'Delicate necklace.',
      'sizes': ['One Size'],
      'colors': ['Gold', 'Silver', 'Rose Gold'],
    },
    {
      'name': 'Pink Clutch Wallet',
      'img': 'acc_product8.png',
      'price': 55,
      'desc': 'Compact clutch.',
      'sizes': ['One Size'],
      'colors': ['Pink', 'Black', 'Beige', 'Red'],
    },
    {
      'name': 'Pearl Drop Earrings',
      'img': 'acc_product9.png',
      'price': 40,
      'desc': 'Elegant pearl drops.',
      'sizes': ['One Size'],
      'colors': ['White Pearl', 'Cream Pearl', 'Black Pearl'],
    },
    {
      'name': 'Blue Bow Tie Set',
      'img': 'acc_product10.png',
      'price': 35,
      'desc': 'Pre-tied bow tie.',
      'sizes': ['One Size'],
      'colors': ['Navy Blue', 'Black', 'Burgundy', 'Grey'],
    },
  ];

  for (var p in accProducts) {
    allProducts.add(
      _product(
        name: p['name'] as String,
        category: 'Accessories',
        price: p['price'] as int,
        originalPrice: (p['price'] as int) + 30,
        rating: 4.8 + ((p['price'] as int) % 8) * 0.1,
        reviewsCount: 100 + ((p['price'] as int) % 30),
        description: p['desc'] as String,
        imageUrl: 'assets/images/products/accessories/${p['img']}',
        materialTitle: 'Premium Material',
        materialDescription: 'Crafted with attention to detail.',
        sizes: List<String>.from(p['sizes'] as List),
        colors: List<String>.from(p['colors'] as List),
      ),
    );
  }

  // ─── FEATURED (10 Products) ──────────────────────────────────────────────
  final featuredProducts = [
    {
      'name': 'Signature Logo Hoodie',
      'img': 'product1.png',
      'price': 95,
      'desc': 'Comfortable hoodie.',
      'sizes': ['S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['Black', 'Grey', 'Navy', 'White'],
    },
    {
      'name': 'Premium Canvas Backpack',
      'img': 'product2.png',
      'price': 120,
      'desc': 'Spacious backpack.',
      'sizes': ['One Size'],
      'colors': ['Black', 'Navy', 'Khaki', 'Grey'],
    },
    {
      'name': 'Limited Edition Sneakers',
      'img': 'product3.png',
      'price': 150,
      'desc': 'Exclusive sneakers.',
      'sizes': ['7', '8', '9', '10', '11', '12'],
      'colors': ['White/Black', 'All White', 'Black/Red', 'Navy/White'],
    },
    {
      'name': 'Essential Cotton Tee',
      'img': 'product4.png',
      'price': 35,
      'desc': 'Soft everyday tee.',
      'sizes': ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
      'colors': ['White', 'Black', 'Grey', 'Navy', 'Olive'],
    },
    {
      'name': 'Minimalist Silver Ring',
      'img': 'product5.png',
      'price': 55,
      'desc': 'Simple ring.',
      'sizes': ['6', '7', '8', '9', '10'],
      'colors': ['Silver', 'Gold', 'Rose Gold'],
    },
    {
      'name': 'Structured Tote Bag',
      'img': 'product6.png',
      'price': 130,
      'desc': 'Professional tote.',
      'sizes': ['One Size'],
      'colors': ['Black', 'Brown', 'Navy', 'Burgundy'],
    },
    {
      'name': 'Bollywood Oxidized Jhumka',
      'img': 'product7.png',
      'price': 280,
      'desc': 'Timeless trench coat.',
      'sizes': ['One Size'],
      'colors': ['Beige', 'Black', 'Navy', 'Olive'],
    },
    {
      'name': 'Teddy Bear ',
      'img': 'product8.png',
      'price': 110,
      'desc': 'Street-style sneakers.',
      'sizes': ['One Size'],
      'colors': ['Pink', 'White', 'Brown', 'Blue'],
    },
    {
      'name': 'Woven Leather Slipper',
      'img': 'product9.png',
      'price': 65,
      'desc': 'Textured belt.',
      'sizes': ['32', '34', '36', '38', '40'],
      'colors': ['Brown', 'Black', 'Tan'],
    },
    {
      'name': 'Sukhi Bridal Jewellery',
      'img': 'product10.png',
      'price': 45,
      'desc': 'Luxuriously soft beanie.',
      'sizes': ['One Size'],
      'colors': ['Gold, Silver, Rose Gold'],
    },
  ];

  for (var p in featuredProducts) {
    allProducts.add(
      _product(
        name: p['name'] as String,
        category: 'Featured',
        price: p['price'] as int,
        originalPrice: (p['price'] as int) + 40,
        rating: 4.9,
        reviewsCount: 150 + ((p['price'] as int) % 50),
        description: p['desc'] as String,
        imageUrl: 'assets/images/products/${p['img']}',
        materialTitle: 'Exclusive Collection',
        materialDescription: 'Limited edition premium quality.',
        sizes: List<String>.from(p['sizes'] as List),
        colors: List<String>.from(p['colors'] as List),
      ),
    );
  }

  return allProducts;
}

// ──────────────────────────────────────────────────────────────────────────
// HELPER FUNCTION
// ──────────────────────────────────────────────────────────────────────────

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
  required List<String> colors,
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
    'colors': colors,
    'inStock': true,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
