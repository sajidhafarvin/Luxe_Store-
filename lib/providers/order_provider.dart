import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order.dart' as app_model;

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save to Firestore 'orders' collection.
  /// Returns [true] if successfully saved, [false] otherwise.
  Future<bool> createOrder(app_model.Order order) async {
    try {
      await _firestore.collection('orders').add(order.toFirestore());
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating order: $e');
      return false;
    }
  }

  /// Get user's orders from the top-level 'orders' collection.
  Future<List<app_model.Order>> getUserOrders(String userId) async {
    print('🔍 [OrderProvider] getUserOrders called');
    print('   - Query userId: $userId');
    print('   - Firestore collection: orders');

    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      print('   - Query completed');
      print('   - Documents found: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('   ⚠️ WARNING: No documents found in Firestore!');
        // Check if collection exists and show all docs for comparison
        final allDocs = await _firestore.collection('orders').get();
        print('   - Total documents in orders collection: ${allDocs.docs.length}');
        for (final doc in allDocs.docs) {
          final data = doc.data();
          print('   - Doc ${doc.id}: userId="${data['userId']}", status="${data['status']}"');
        }
      }

      final orders = snapshot.docs.map((doc) {
        print('   - Converting doc: ${doc.id}');
        return app_model.Order.fromFirestore(doc);
      }).toList();

      print('   - Converted ${orders.length} orders');
      return orders;
    } catch (e) {
      print('   ❌ ERROR in getUserOrders: $e');
      // Common cause: missing Firestore composite index for (userId + createdAt).
      // Fall back to simple where query (no orderBy), then sort in Dart.
      print('   🔄 Retrying WITHOUT orderBy (index may not exist yet)...');
      try {
        final fallback = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .get();
        print('   - Fallback found: ${fallback.docs.length} docs');
        final orders = fallback.docs.map((doc) => app_model.Order.fromFirestore(doc)).toList();
        // Sort by createdAt descending in memory
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return orders;
      } catch (e2) {
        print('   ❌ Fallback also failed: $e2');
        rethrow;
      }
    }

  }

  /// Update the status of an order.
  /// Also appends a timestamped entry to [statusHistory] and
  /// computes an [estimatedDelivery] date based on the new status.
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final now = Timestamp.now();

      // Compute estimated delivery offset from now
      Duration deliveryOffset;
      switch (newStatus.toLowerCase()) {
        case 'pending':
          deliveryOffset = const Duration(days: 7);
          break;
        case 'confirmed':
          deliveryOffset = const Duration(days: 5);
          break;
        case 'shipped':
          deliveryOffset = const Duration(days: 3);
          break;
        default:
          deliveryOffset = Duration.zero;
      }

      final estimatedDelivery = newStatus.toLowerCase() == 'delivered'
          ? now
          : Timestamp.fromDate(DateTime.now().add(deliveryOffset));

      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'estimatedDelivery': estimatedDelivery,
        // Firestore arrayUnion keeps history without overwriting
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': newStatus,
            'timestamp': now,
          }
        ]),
      });
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      return false;
    }
  }
}
