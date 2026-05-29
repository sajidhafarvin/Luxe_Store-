import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class OrderItem {
  final Product product;
  int quantity;

  OrderItem({required this.product, required this.quantity});
  
  double get totalPrice => (product.price * quantity).toDouble();
}

class CartItem {
  final String name;
  final String price;
  final String image;
  final int qty;
  final String size;
  final dynamic color;
  final String brand;

  CartItem({
    required this.name,
    required this.price,
    required this.image,
    required this.qty,
    required this.size,
    required this.color,
    required this.brand,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      name: map['name']?.toString() ?? '',
      price: map['price']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      qty: map['qty'] is num ? (map['qty'] as num).toInt() : 1,
      size: map['size']?.toString() ?? '',
      color: map['color'],
      brand: map['brand']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'qty': qty,
      'size': size,
      'color': color?.toString(),
      'brand': brand,
    };
  }
}

class Order {
  final String? id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final List<Map<String, dynamic>> statusHistory;
  final Timestamp? estimatedDelivery;
  final String? deliveryAddress;
  final String paymentMethod;
  final Timestamp createdAt;

  Order({
    this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.statusHistory,
    this.estimatedDelivery,
    this.deliveryAddress,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final itemsList = data['items'] as List? ?? [];
    final items = itemsList
        .map((item) => CartItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();
    
    final historyList = data['statusHistory'] as List? ?? [];
    final statusHistory = historyList
        .map((item) => Map<String, dynamic>.from(item))
        .toList();

    return Order(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      items: items,
      totalAmount: (data['totalAmount'] is num) ? (data['totalAmount'] as num).toDouble() : 0.0,
      status: data['status']?.toString() ?? 'pending',
      statusHistory: statusHistory,
      estimatedDelivery: data['estimatedDelivery'] as Timestamp?,
      deliveryAddress: data['deliveryAddress']?.toString(),
      paymentMethod: data['paymentMethod']?.toString() ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'statusHistory': statusHistory,
      'estimatedDelivery': estimatedDelivery,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt,
    };
  }

  Order copyWith({
    String? status,
    List<Map<String, dynamic>>? statusHistory,
    Timestamp? estimatedDelivery,
  }) {
    return Order(
      id: id,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress,
      paymentMethod: paymentMethod,
      createdAt: createdAt,
      statusHistory: statusHistory ?? this.statusHistory,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }
}
