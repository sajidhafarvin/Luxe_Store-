import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderRepository {
  OrderRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Stream<List<Map<String, dynamic>>> watchMyOrders() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => _mapOrderDoc(d.id, d.data())).toList());
  }

  Future<String> placeOrder({
    required List<Map<String, dynamic>> items,
    required double total,
    required String paymentMethod,
    required Map<String, String> delivery,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Not logged in');
    }

    final now = DateTime.now();
    final orderNumber = 'LX-${now.millisecondsSinceEpoch.toString().substring(7)}';

    final ref = _firestore.collection('users').doc(user.uid).collection('orders').doc();
    await ref.set({
      'orderNumber': orderNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'Pending',
      'paymentMethod': paymentMethod,
      'total': total,
      'delivery': delivery,
      'items': items.map((item) {
        return {
          'name': item['name'],
          'price': item['price'],
          'image': item['image'],
          'qty': item['qty'],
          'size': item['size'],
          'color': item['color'],
          'brand': item['brand'],
        };
      }).toList(),
    });

    return orderNumber;
  }

  Map<String, dynamic> _mapOrderDoc(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    DateTime date;
    if (createdAt is Timestamp) {
      date = createdAt.toDate();
    } else {
      date = DateTime.now();
    }

    final status = (data['status'] ?? 'Pending').toString();
    final statusColor = _statusColor(status).value;
    final total = (data['total'] is num) ? (data['total'] as num).toDouble() : 0.0;
    final items = (data['items'] is List) ? List<Map<String, dynamic>>.from(data['items'] as List) : <Map<String, dynamic>>[];

    return {
      'id': id,
      'orderNumber': (data['orderNumber'] ?? '').toString(),
      'date': '${_getMonth(date.month)} ${date.day}, ${date.year}',
      'total': '\$${total.toStringAsFixed(2)}',
      'status': status,
      'statusColor': statusColor,
      'paymentMethod': (data['paymentMethod'] ?? 'Cash on Delivery').toString(),
      'items': items,
    };
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Delivered':
        return const Color(0xFF4CAF50);
      case 'Cancelled':
        return const Color(0xFFF44336);
      case 'Shipped':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFFF5A623);
    }
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
