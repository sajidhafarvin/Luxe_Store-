import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/order_provider.dart';
import '../../models/order.dart' as app_model;
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<app_model.Order>> _ordersFuture;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only auto-fetch once, but allow manual refresh via _refreshOrders
    if (!_initialized) {
      _initialized = true;
      _fetchOrders();
    }
  }

  void _fetchOrders() {
    final authProvider = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    print('🧑‍💻 [OrderHistoryScreen] _fetchOrders called');
    print('   - authProvider.user: ${authProvider.user}');
    print('   - user uid: ${authProvider.user?.uid}');

    if (authProvider.user != null) {
      print('   - Calling orderProvider.getUserOrders(${authProvider.user!.uid})');
      _ordersFuture = orderProvider.getUserOrders(authProvider.user!.uid);
    } else {
      print('   ⚠️ WARNING: user is null! Auth may not have loaded yet.');
      // Wait for auth to restore and retry
      _ordersFuture = FirebaseAuth.instance.authStateChanges().firstWhere((u) => u != null).then((user) {
        print('   ✅ Auth restored. uid=${user!.uid} — re-fetching orders...');
        return orderProvider.getUserOrders(user.uid);
      }).catchError((e) {
        print('   ❌ Auth wait failed: $e');
        return <app_model.Order>[];
      });
    }
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _fetchOrders();
    });
    await _ordersFuture;
  }


  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'shipped':
        return Colors.purple;
      case 'confirmed':
        return Colors.blue;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _formatDate(app_model.Order order) {
    final date = order.createdAt.toDate();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  String _getShortOrderId(app_model.Order order) {
    if (order.id != null && order.id!.length >= 8) {
      return order.id!.substring(0, 8).toUpperCase();
    }
    return order.id?.toUpperCase() ?? 'UNKNOWN';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary), 
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Orders", 
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<app_model.Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text("Error loading orders", style: GoogleFonts.poppins(fontSize: 16, color: theme.colorScheme.primary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor),
                    onPressed: _refreshOrders,
                    child: const Text("Retry", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }
          
          final orders = snapshot.data ?? [];
          
          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 80, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        Text("No orders yet", style: GoogleFonts.poppins(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), 
                          onPressed: () => Navigator.pushNamed(context, '/home'), 
                          child: Text("Start Shopping", style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final statusColor = _getStatusColor(order.status);
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsScreen(order: order),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.cardColor, 
                      borderRadius: BorderRadius.circular(16), 
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0,2))
                      ]
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Text(
                                  "Order #LX-${_getShortOrderId(order)}", 
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(order), 
                                      style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                    ),
                                  ],
                                ),
                              ]
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), 
                              child: Text(
                                order.status.toUpperCase(), 
                                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                              ),
                            ),
                          ]
                        ),
                        const SizedBox(height: 16),
                        Divider(color: theme.dividerColor, height: 1),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${order.items.length} item${order.items.length > 1 ? 's' : ''}",
                              style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            ),
                            Text(
                              "\$${order.totalAmount.toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondaryColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
