import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../utils/wishlist_manager.dart';
import '../../utils/cart_manager.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    final wishlistItems = WishlistManager().items;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary), onPressed: () => Navigator.pop(context)),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("My Wishlist", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
            Text("${WishlistManager().itemCount} items", style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4))),
          ],
        ),
        centerTitle: true,
      ),
      body: wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline, size: 80, color: theme.dividerColor),
                  const SizedBox(height: 16),
                  Text("Your wishlist is empty", style: GoogleFonts.poppins(fontSize: 16, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 8),
                  Text("Save items you love!", style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: Text("Start Shopping", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.70),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return Container(
                  decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                            child: Image.asset(item['image'], height: 160, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(height: 160, color: theme.dividerColor, child: const Icon(Icons.image, color: Colors.grey))),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: GestureDetector(
                              onTap: () { WishlistManager().toggleWishlist(item); setState(() {}); },
                              child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]), child: const Icon(Icons.favorite, size: 16, color: AppColors.secondaryColor)),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['brand'] ?? 'ATELIER LUXE', style: GoogleFonts.poppins(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                            Text(item['name'], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: theme.colorScheme.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(item['price'], style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondaryColor)),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity, height: 36,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: EdgeInsets.zero),
                                onPressed: () {
                                  CartManager().addItem({'name': item['name'], 'price': item['price'], 'image': item['image'], 'brand': item['brand'] ?? 'ATELIER LUXE', 'size': 'M', 'color': theme.colorScheme.primary, 'qty': 1});
                                  WishlistManager().removeItem(index);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${item['name']} added to cart!"), backgroundColor: AppColors.secondaryColor));
                                },
                                child: Text("Add to Cart", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
