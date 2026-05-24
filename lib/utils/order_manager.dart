class OrderManager {
  static final OrderManager _instance =
    OrderManager._internal();
  factory OrderManager() => _instance;
  OrderManager._internal();

  static final List<Map<String, dynamic>> 
    _orders = [];

  List<Map<String, dynamic>> get orders =>
    List.from(_orders);

  void addOrder({
    required List<Map<String, dynamic>> items,
    required double total,
    required String paymentMethod,
  }) {
    final now = DateTime.now();
    final orderNumber = 
      'LX-${now.millisecondsSinceEpoch
        .toString().substring(7)}';
    
    _orders.insert(0, {
      'orderNumber': orderNumber,
      'date': '${_getMonth(now.month)} '
        '${now.day}, ${now.year}',
      'total': '\$${total.toStringAsFixed(2)}',
      'status': 'Pending',
      'statusColor': 0xFFF5A623,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => {
        'name': item['name'],
        'price': item['price'],
        'image': item['image'],
        'qty': item['qty'],
        'size': item['size'],
      }).toList(),
    });
  }

  void cancelOrder(int index) {
    if (index >= 0 && 
        index < _orders.length) {
      _orders[index]['status'] = 'Cancelled';
      _orders[index]['statusColor'] = 
        0xFFF44336;
    }
  }

  String _getMonth(int month) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[month - 1];
  }

  int get orderCount => _orders.length;
}
