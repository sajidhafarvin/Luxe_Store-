import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../../utils/cart_manager.dart';
import '../../utils/user_session.dart';
import '../../utils/wishlist_manager.dart';
import '../cart/cart_screen.dart';
import '../profile/notifications_screen.dart';
import '../../utils/theme_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBanner = 0;
  int _selectedCategory = 0;
  final _productRepository = ProductRepository();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  Widget _buildCategoryChip(String label, int index, String route, ThemeData theme) {
    bool isSelected = _selectedCategory == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = index);
        Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: theme.dividerColor),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product, int index, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context, 
        AppRoutes.productDetails,
        arguments: {
          'id': product.id,
          'name': product.name,
          'price': "\$${product.price.toStringAsFixed(2)}",
          'image': product.imageUrl,
          'brand': product.brand,
          'rating': product.rating.toStringAsFixed(1),
          'index': index % 10,
          'description': product.description,
          'materialTitle': product.materialTitle,
          'materialDescription': product.materialDescription,
        },
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 160,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "NEW",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      WishlistManager().toggleWishlist({
                        'id': product.id,
                        'name': product.name,
                        'price': "\$${product.price.toStringAsFixed(2)}",
                        'image': product.imageUrl,
                        'brand': product.brand,
                        'rating': product.rating.toStringAsFixed(1),
                        'index': index % 10,
                      });
                      setState(() {});
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        WishlistManager().isWishlisted(product.name)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: WishlistManager().isWishlisted(product.name)
                            ? AppColors.secondaryColor
                            : theme.colorScheme.onSurface.withOpacity(0.4),
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ATELIER LUXE",
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      color: theme.colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                      color: AppColors.secondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          if (index == 0) Navigator.pushNamed(context, AppRoutes.home);
          if (index == 1) Navigator.pushNamed(context, '/search');
          if (index == 2) Navigator.push(context, MaterialPageRoute(settings: const RouteSettings(name: '/cart'), builder: (context) => const CartScreen()));
          if (index == 3) Navigator.pushNamed(context, AppRoutes.profile);
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: theme.cardColor,
              padding: const EdgeInsets.only(left: 16, right: 16, top: 48, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("WELCOME BACK", style: GoogleFonts.poppins(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4), letterSpacing: 1.5)),
                      Text("Hello, ${UserSession().firstName} 👋", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    ],
                  ),
                  Row(
                    children: [
                      Stack(children: [
                        IconButton(icon: const Icon(Icons.notifications_outlined), color: theme.colorScheme.primary, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()))),
                        Positioned(top: 8, right: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondaryColor, shape: BoxShape.circle))),
                      ]),
                      Stack(children: [
                        IconButton(icon: const Icon(Icons.shopping_bag_outlined), color: theme.colorScheme.primary, onPressed: () => Navigator.push(context, MaterialPageRoute(settings: const RouteSettings(name: '/cart'), builder: (context) => const CartScreen()))),
                        Positioned(top: 8, right: 8, child: CartManager().itemCount > 0 ? Container(width: 18, height: 18, decoration: const BoxDecoration(color: AppColors.secondaryColor, shape: BoxShape.circle), child: Center(child: Text(CartManager().itemCount > 9 ? '9+' : '${CartManager().itemCount}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))) : const SizedBox.shrink()),
                      ]),
                    ],
                  ),
                ],
              ),
            ),

            Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                height: 48,
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.dividerColor)),
                child: TextField(
                    readOnly: true,
                    onTap: () => Navigator.pushNamed(context, '/search'),
                    decoration: InputDecoration(
                        hintText: "Search fashion...",
                        hintStyle: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                        suffixIcon: Icon(Icons.tune, color: theme.colorScheme.primary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12)))),

            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  itemCount: 3,
                  onPageChanged: (index) => setState(() => _currentBanner = index),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Image.asset('assets/images/banners/banner${index + 1}.png', fit: BoxFit.cover, width: double.infinity, height: 180),
                        Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black54]))),
                        Positioned(
                          bottom: 16, left: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("NEW ARRIVALS", style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, letterSpacing: 1.5)),
                              const SizedBox(height: 4),
                              Text("ELEVATE YOUR ESSENTIALS", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.productList),
                                child: Text("SHOP NOW", style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => Container(width: _currentBanner == index ? 20 : 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: _currentBanner == index ? AppColors.secondaryColor : Colors.grey))),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Categories", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: theme.colorScheme.primary)),
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.productList),
                    child: Text("View All", style: GoogleFonts.poppins(color: AppColors.secondaryColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip("Women", 0, AppRoutes.womenProducts, theme),
                  _buildCategoryChip("Men", 1, AppRoutes.menProducts, theme),
                  _buildCategoryChip("Kids", 2, AppRoutes.kidsProducts, theme),
                  _buildCategoryChip("Accessories", 3, AppRoutes.accessoriesProducts, theme),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Featured Looks", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16, color: theme.colorScheme.primary)),
                  Icon(Icons.filter_list, color: theme.colorScheme.primary),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<List<Product>>(
                stream: _productRepository.watchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final products = snapshot.data ?? [];
                  final count = products.length < 4 ? products.length : 4;
                  if (count == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Center(child: Text("No products found", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)))),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
                    itemCount: count,
                    itemBuilder: (context, index) => _buildProductCard(products[index], index, theme),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
