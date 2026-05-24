import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductRepository {
  ProductRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<Product>> watchProducts({String? category}) {
    Query<Map<String, dynamic>> query = _firestore.collection('products').orderBy('createdAt', descending: true);
    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc.id, doc.data())).toList();
    });
  }

  Future<List<Product>> fetchProducts({String? category}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('products').orderBy('createdAt', descending: true);
    if (category != null && category.isNotEmpty && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc.id, doc.data())).toList();
  }
}

