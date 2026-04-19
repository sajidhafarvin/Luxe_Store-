import 'product.dart';

class OrderItem {
  final Product product;
  int quantity;

  OrderItem({required this.product, required this.quantity});
  
  double get totalPrice => product.price * quantity;
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime date;
  final String status;
  final String deliveryAddress;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.date,
    required this.status,
    required this.deliveryAddress,
  });
}
