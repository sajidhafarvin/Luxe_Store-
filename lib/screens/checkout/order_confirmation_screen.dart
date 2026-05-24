import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final theme = Theme.of(context);
    final String paymentMethod = args?['paymentMethod'] ?? 'Cash on Delivery';
    final String totalAmount = args?['total'] != null ? '\$${args!['total']}' : '\$1,090.00';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(width: 100, height: 100, decoration: BoxDecoration(color: const Color(0xFF4CAF50), shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.3), blurRadius: 20, spreadRadius: 5)]), child: const Icon(Icons.check_rounded, color: Colors.white, size: 55)),
              const SizedBox(height: 24),
              Text("Order Placed!", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 28, color: theme.colorScheme.primary), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text("Your order has been confirmed\nand will be delivered soon", style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow("Order Number", args?['orderNumber'] ?? "LX-PP28401", theme, isBold: true),
                    Divider(height: 32, color: theme.dividerColor),
                    _buildRow("Date", "Oct 24-26, 2025", theme),
                    const SizedBox(height: 8),
                    _buildRow("Payment", paymentMethod, theme),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("Status", style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 12)),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF4CAF50).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text("Confirmed", style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w600))),
                    ]),
                    Divider(height: 32, color: theme.dividerColor),
                    _buildRow("Total Amount", totalAmount, theme, isBold: true, valueColor: AppColors.secondaryColor, fontSize: 18),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16), width: double.infinity,
                decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1))),
                child: Row(children: [
                  Icon(Icons.local_shipping_outlined, color: theme.colorScheme.primary, size: 24),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("Estimated Delivery", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.primary)),
                    Text("Oct 24 - Oct 26, 2025", style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  ]),
                ]),
              ),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, height: 52, child: OutlinedButton(style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.primary, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pushNamed(context, '/order-history'), child: Text("View My Orders", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: theme.colorScheme.primary)))),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false), child: Text("Continue Shopping", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white)))),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, ThemeData theme, {bool isBold = false, Color? valueColor, double fontSize = 13}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 12)),
      Text(value, style: GoogleFonts.poppins(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize, color: valueColor ?? theme.colorScheme.primary)),
    ]);
  }
}
