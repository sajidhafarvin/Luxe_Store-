import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../utils/cart_manager.dart';
import '../../repositories/order_repository.dart';
import '../../constants/app_routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPayment = 0;
  bool _isPlacingOrder = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose(); _phoneController.dispose(); _address1Controller.dispose();
    _address2Controller.dispose(); _cityController.dispose(); _postalController.dispose();
    _cardNumberController.dispose(); _cardNameController.dispose(); _expiryController.dispose(); _cvvController.dispose();
    super.dispose();
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType? keyboard, required ThemeData theme}) {
    return TextFormField(
      controller: controller, keyboardType: keyboard ?? TextInputType.text,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.4)),
        filled: true, fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.secondaryColor, width: 2)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartManager = CartManager();
    final items = cartManager.items;
    final isCartEmpty = items.isEmpty;

    final List<Map<String, dynamic>> displayItems = items;

    double totalValue = cartManager.totalPrice;
    final totalPriceText = "\$${totalValue.toStringAsFixed(2)}";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary), onPressed: () => Navigator.pop(context)),
        title: Text("Checkout", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Delivery Details", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTextField(controller: _nameController, label: "Full Name", icon: Icons.person_outlined, theme: theme),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _phoneController, label: "Phone Number", icon: Icons.phone_outlined, keyboard: TextInputType.phone, theme: theme),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _address1Controller, label: "Address Line 1", icon: Icons.location_on_outlined, theme: theme),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildTextField(controller: _cityController, label: "City", icon: Icons.location_city_outlined, theme: theme)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(controller: _postalController, label: "Postal Code", icon: Icons.pin_outlined, keyboard: TextInputType.number, theme: theme)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text("Order Summary", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayItems.length,
                    itemBuilder: (context, index) {
                      final item = displayItems[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(children: [
                          ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset(item['image'], width: 40, height: 40, fit: BoxFit.cover)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item['name'], style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.primary))),
                          Text(item['price'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.secondaryColor)),
                        ]),
                      );
                    },
                  ),
                  Divider(color: theme.dividerColor),
                  _buildSummaryRow("Subtotal", totalPriceText, theme, isBold: true),
                  _buildSummaryRow("Delivery", "FREE", theme, valueColor: Colors.green),
                  Divider(color: theme.dividerColor),
                  _buildSummaryRow("Total", totalPriceText, theme, isBold: true, valueColor: AppColors.secondaryColor, fontSize: 16),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text("Payment Method", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  RadioListTile<int>(
                    title: Text("Cash on Delivery", style: GoogleFonts.poppins(color: theme.colorScheme.primary, fontSize: 14)),
                    secondary: Icon(Icons.money, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    value: 0, groupValue: _selectedPayment, activeColor: AppColors.secondaryColor,
                    onChanged: (value) => setState(() => _selectedPayment = value!),
                  ),
                  Divider(indent: 16, endIndent: 16, height: 1, color: theme.dividerColor),
                  RadioListTile<int>(
                    title: Text("Credit Card", style: GoogleFonts.poppins(color: theme.colorScheme.primary, fontSize: 14)),
                    secondary: Icon(Icons.credit_card, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    value: 1, groupValue: _selectedPayment, activeColor: AppColors.secondaryColor,
                    onChanged: (value) => setState(() => _selectedPayment = value!),
                  ),
                  if (_selectedPayment == 1) Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTextField(controller: _cardNumberController, label: "Card Number", icon: Icons.credit_card, theme: theme),
                        const SizedBox(height: 12),
                        Row(children: [
                          Expanded(child: _buildTextField(controller: _expiryController, label: "MM/YY", icon: Icons.calendar_today_outlined, theme: theme)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildTextField(controller: _cvvController, label: "CVV", icon: Icons.lock_outlined, theme: theme)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isPlacingOrder
                    ? null
                    : () async {
                        if (FirebaseAuth.instance.currentUser == null) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to continue"), backgroundColor: Colors.red));
                          Navigator.pushNamed(context, AppRoutes.login);
                          return;
                        }

                        if (isCartEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Your cart is empty"), backgroundColor: Colors.red));
                          return;
                        }

                        if (_nameController.text.isEmpty || _phoneController.text.isEmpty || _address1Controller.text.isEmpty || _cityController.text.isEmpty || _postalController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields"), backgroundColor: Colors.red));
                          return;
                        }

                        setState(() => _isPlacingOrder = true);
                        final currentItems = List<Map<String, dynamic>>.from(cartManager.items);
                        final currentTotal = cartManager.totalPrice;
                        final paymentMethod = _selectedPayment == 0 ? 'Cash on Delivery' : 'Credit Card';

                        try {
                          final orderNumber = await OrderRepository().placeOrder(
                            items: currentItems,
                            total: currentTotal,
                            paymentMethod: paymentMethod,
                            delivery: {
                              'name': _nameController.text.trim(),
                              'phone': _phoneController.text.trim(),
                              'address1': _address1Controller.text.trim(),
                              'address2': _address2Controller.text.trim(),
                              'city': _cityController.text.trim(),
                              'postalCode': _postalController.text.trim(),
                            },
                          );
                          CartManager().clear();
                          if (!mounted) return;
                          Navigator.pushNamed(
                            context,
                            AppRoutes.orderConfirmation,
                            arguments: {'paymentMethod': paymentMethod, 'total': currentTotal.toStringAsFixed(2), 'orderNumber': orderNumber},
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to place order. Please try again."), backgroundColor: Colors.red));
                        } finally {
                          if (mounted) setState(() => _isPlacingOrder = false);
                        }
                      },
                child: _isPlacingOrder
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Place Order →", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme, {bool isBold = false, Color? valueColor, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: fontSize)),
          Text(value, style: GoogleFonts.poppins(color: valueColor ?? theme.colorScheme.primary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: fontSize)),
        ],
      ),
    );
  }
}
