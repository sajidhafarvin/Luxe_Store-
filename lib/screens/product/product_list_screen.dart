import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../cart/cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int _selectedFilter = 0;
  late TextEditingController _searchController;
  String _filterQuery = '';
  final _productRepository = ProductRepository();

  final List<String> filters = ["All", "New", "Sale", "Suits", "Outerwear"];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String? searchQuery = args?['search'];
      if (searchQuery != null) setState(() { _filterQuery = searchQuery; _searchController.text = searchQuery; });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary), onPressed: () => Navigator.pop(context)),
        title: Text("NEW ARRIVALS", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: theme.colorScheme.primary), onPressed: () {}),
          IconButton(icon: Icon(Icons.tune, color: theme.colorScheme.primary), onPressed: () {}),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
      body: Column(
        children: [
          Container(
            height: 52, color: theme.cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(filters.length, (index) {
                  bool isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: isSelected ? theme.colorScheme.primary : theme.cardColor, borderRadius: BorderRadius.circular(20), border: isSelected ? null : Border.all(color: theme.dividerColor)),
                      child: Text(filters[index], style: GoogleFonts.poppins(fontSize: 13, color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6))),
                    ),
                  );
                }),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: theme.cardColor,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filterQuery = value),
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Search items...",
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
                prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                suffixIcon: _filterQuery.isNotEmpty ? IconButton(icon: Icon(Icons.clear, color: theme.colorScheme.primary), onPressed: () { _searchController.clear(); setState(() => _filterQuery = ''); }) : null,
                filled: true, fillColor: theme.scaffoldBackgroundColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.all(16), height: 160,
            child: Stack(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/images/banners/banner1.png', fit: BoxFit.cover, width: double.infinity, height: 160)),
                Container(decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(16))),
                Positioned(
                  bottom: 16, left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("THE SILK SERIES", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.productDetails),
                        child: Text("EXPLORE →", style: GoogleFonts.poppins(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productRepository.watchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Failed to load products", style: TextStyle(color: theme.colorScheme.onSurface)));
                }

                final allProducts = snapshot.data ?? [];
                final products = _filterQuery.isEmpty
                    ? allProducts
                    : allProducts.where((p) => p.name.toLowerCase().contains(_filterQuery.toLowerCase())).toList();

                if (products.isEmpty) {
                  return Center(child: Text("No products found", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))));
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final salePriceText = "\$${product.price.toStringAsFixed(0)}";
                    final originalPriceText = product.originalPrice == null ? null : "\$${product.originalPrice!.toStringAsFixed(0)}";
                    final detailsIndex = index % 10;
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
                          'index': detailsIndex,
                          'description': product.description,
                          'materialTitle': product.materialTitle,
                          'materialDescription': product.materialDescription,
                        },
                      ),
                      child: Container(
                        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(children: [
                              ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.asset(product.imageUrl, fit: BoxFit.cover, width: double.infinity, height: 160)),
                              Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(8)), child: Text("NEW", style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
                              Positioned(top: 8, right: 8, child: Container(width: 32, height: 32, decoration: BoxDecoration(color: theme.cardColor, shape: BoxShape.circle), child: Icon(Icons.favorite_border, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 16))),
                            ]),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.brand, style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 10, letterSpacing: 1)),
                                  const SizedBox(height: 4),
                                  Text(product.name, style: GoogleFonts.poppins(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Text(salePriceText, style: GoogleFonts.poppins(color: AppColors.secondaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                    if (originalPriceText != null) ...[
                                      const SizedBox(width: 4),
                                      Text(originalPriceText, style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 12, decoration: TextDecoration.lineThrough)),
                                    ],
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
