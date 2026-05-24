import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../utils/cart_manager.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _items = CartManager().items;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() => _items = CartManager().items);
  }

  void _reloadCart() => setState(() => _items = CartManager().items);

  @override
  Widget build(BuildContext context) {
    final itemCount = _items.length;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Column(
          children: [
            Text("MY CART", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
            Text("$itemCount items", style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.favorite_border), color: theme.colorScheme.primary, onPressed: () {}),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          else if (index == 1) Navigator.pushNamed(context, '/search');
          else if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
        },
      ),
      body: itemCount == 0 ? _buildEmptyCart(theme) : _buildCartContent(theme),
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: theme.dividerColor),
          const SizedBox(height: 16),
          Text("Your cart is empty", style: GoogleFonts.poppins(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: Text("Continue Shopping", style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(ThemeData theme) {
    return Column(
      children: [
        Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _items.length, itemBuilder: (context, index) => _buildCartItem(index, theme))),
        _buildOrderSummary(theme),
      ],
    );
  }

  Widget _buildCartItem(int index, ThemeData theme) {
    final item = _items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)]),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(item['image'] ?? '', width: 80, height: 80, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['brand'] ?? '', style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 10, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(item['name'] ?? '', style: GoogleFonts.poppins(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(item['price'] ?? '', style: GoogleFonts.poppins(color: AppColors.secondaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text("Size: ${item['size'] ?? '-'}", style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: item['color'] is Color ? item['color'] : theme.colorScheme.primary)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(icon: Icon(Icons.delete_outline, color: theme.colorScheme.onSurface.withOpacity(0.4)), onPressed: () { CartManager().removeItem(index); _reloadCart(); }),
              Row(
                children: [
                  GestureDetector(
                    onTap: () { if ((item['qty'] as int) > 1) { CartManager().updateQty(index, (item['qty'] as int) - 1); _reloadCart(); } },
                    child: Container(width: 30, height: 30, decoration: BoxDecoration(border: Border.all(color: theme.dividerColor), borderRadius: BorderRadius.circular(6)), child: Icon(Icons.remove, color: theme.colorScheme.primary, size: 16)),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${item['qty']}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.primary))),
                  GestureDetector(
                    onTap: () { CartManager().updateQty(index, (item['qty'] as int) + 1); _reloadCart(); },
                    child: Container(width: 30, height: 30, decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.add, color: Colors.white, size: 16)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    final total = CartManager().totalPrice;
    return Container(
      margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
              Text("\$${total.toStringAsFixed(2)}", style: GoogleFonts.poppins(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Delivery", style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
              Text("FREE", style: GoogleFonts.poppins(color: const Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total", style: GoogleFonts.poppins(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
              Text("\$${total.toStringAsFixed(2)}", style: GoogleFonts.poppins(color: AppColors.secondaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              child: Text("PROCEED TO CHECKOUT →", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
