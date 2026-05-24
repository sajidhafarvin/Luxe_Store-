import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../repositories/order_repository.dart';
import '../cart/cart_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  Color _getStatusColor(dynamic colorValue) {
    if (colorValue is int) return Color(colorValue);
    if (colorValue is Color) return colorValue;
    return Colors.grey;
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order, ThemeData theme) {
    final statusColor = _getStatusColor(order['statusColor']);
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text("Order Details", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            Text(order['orderNumber'], style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.4))),
            const SizedBox(height: 20),
            _detailRow("Order Date", order['date'], theme),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Status", style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(order['status'], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor))),
            ]),
            const SizedBox(height: 8),
            _detailRow("Payment", order['paymentMethod'] ?? 'Cash on Delivery', theme),
            const Divider(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("Total", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              Text(order['total'], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondaryColor)),
            ]),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pop(ctx), child: Text("Close", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)))),
          ],
        ),
      ),
    );
  }

  void _showTrackingSheet(BuildContext context, Map<String, dynamic> order, ThemeData theme) {
    final statusColor = _getStatusColor(order['statusColor']);
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Track Order", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                  Text(order['orderNumber'], style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                ]),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(order['status'], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor))),
              ]),
            ),
            Divider(color: theme.dividerColor),
            Expanded(child: Center(child: Text("Tracking Timeline", style: TextStyle(color: theme.colorScheme.onSurface)))),
            Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pop(ctx), child: Text("Close", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))))),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, ThemeData theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6))),
      Text(value, style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.primary)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: OrderRepository().watchMyOrders(),
      builder: (context, snapshot) {
        final orders = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary), onPressed: () => Navigator.pop(context)),
            title: Column(mainAxisSize: MainAxisSize.min, children: [
              Text("My Orders", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              Text("${orders.length} orders found", style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4))),
            ]),
            centerTitle: true,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 3,
            selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
            backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Cart'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
            ],
            onTap: (index) {
              if (index == 0) Navigator.pushNamed(context, '/home');
              else if (index == 1) Navigator.pushNamed(context, '/search');
              else if (index == 2) Navigator.push(context, MaterialPageRoute(settings: const RouteSettings(name: '/cart'), builder: (context) => const CartScreen()));
              else if (index == 3) Navigator.pushNamed(context, '/profile');
            },
          ),
          body: snapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : orders.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.receipt_long_outlined, size: 80, color: theme.dividerColor),
                      const SizedBox(height: 16),
                      Text("No orders yet", style: GoogleFonts.poppins(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                      const SizedBox(height: 24),
                      ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pushNamed(context, '/home'), child: Text("Start Shopping", style: GoogleFonts.poppins(color: Colors.white))),
                    ]))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final statusColor = _getStatusColor(order['statusColor']);
                        final items = order['items'] as List;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0,2))]),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text("Order Number", style: GoogleFonts.poppins(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                                  Text(order['orderNumber'], style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                ]),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(order['status'], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor))),
                              ]),
                              const SizedBox(height: 12),
                              Divider(color: theme.dividerColor),
                              const SizedBox(height: 12),
                              Row(children: [
                                ...items.take(2).map((item) => Container(margin: const EdgeInsets.only(right: 8), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(item['image'], width: 50, height: 50, fit: BoxFit.cover)))),
                                if (items.length > 2) Container(width: 50, height: 50, decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(8)), child: Center(child: Text("+${items.length - 2}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)))),
                              ]),
                              const SizedBox(height: 12),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Row(children: [
                                  Icon(Icons.calendar_today_outlined, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                                  const SizedBox(width: 4),
                                  Text(order['date'], style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                                ]),
                                Text(order['total'], style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                              ]),
                              const SizedBox(height: 12),
                              Row(children: [
                                Expanded(child: SizedBox(height: 40, child: OutlinedButton(style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => _showOrderDetails(context, order, theme), child: Text("View Details", style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.primary))))),
                                const SizedBox(width: 8),
                                Expanded(child: SizedBox(height: 40, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: order['status'] == 'Cancelled' ? Colors.grey : AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: order['status'] == 'Cancelled' ? null : () => _showTrackingSheet(context, order, theme), child: Text(order['status'] == 'Cancelled' ? "Cancelled" : "Track Package", style: GoogleFonts.poppins(fontSize: 13, color: Colors.white))))),
                              ]),
                            ],
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
