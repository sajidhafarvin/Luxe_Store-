import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';
import '../cart/cart_screen.dart';

class WomenProductListScreen extends StatefulWidget {
  const WomenProductListScreen({Key? key}) : super(key: key);

  @override
  State<WomenProductListScreen> createState() => _WomenProductListScreenState();
}

class _WomenProductListScreenState extends State<WomenProductListScreen> {
  int _selectedFilter = 0;
  final List<String> filters = ["All", "Dresses", "Outerwear", "Casual", "Sale"];
  final _productRepository = ProductRepository();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary), onPressed: () => Navigator.pop(context)),
        title: Text("WOMEN'S COLLECTION", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
        actions: [IconButton(icon: Icon(Icons.search, color: theme.colorScheme.primary), onPressed: () => Navigator.pushNamed(context, '/search'))],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor, unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor, backgroundColor: theme.bottomNavigationBarTheme.backgroundColor, type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, AppRoutes.home);
          else if (index == 1) Navigator.pushNamed(context, '/search');
          else if (index == 2) Navigator.push(context, MaterialPageRoute(settings: const RouteSettings(name: '/cart'), builder: (context) => const CartScreen()));
          else if (index == 3) Navigator.pushReplacementNamed(context, AppRoutes.profile);
        },
      ),
      body: Column(
        children: [
          Container(
            height: 52, color: theme.cardColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filters.length,
              itemBuilder: (ctx, i) {
                bool isSelected = _selectedFilter == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: isSelected ? theme.colorScheme.primary : theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(20), border: isSelected ? null : Border.all(color: theme.dividerColor)),
                    child: Center(child: Text(filters[i], style: GoogleFonts.poppins(fontSize: 13, color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6)))),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [AppColors.primaryColor, Color(0xFF2D2D5E)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            width: double.infinity,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("SS24 EDITORIAL", style: GoogleFonts.poppins(fontSize: 11, color: Colors.white60, letterSpacing: 2)),
              const SizedBox(height: 8),
              Text("THE EDIT", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text("Timeless silhouettes and artisanal craftsmanship.", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[300])),
            ]),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productRepository.watchProducts(category: 'Women'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Failed to load products", style: TextStyle(color: theme.colorScheme.onSurface)));
                }

                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return Center(child: Text("No products found", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72),
                  itemCount: products.length,
                  itemBuilder: (ctx, i) {
                    final product = products[i];
                    final detailsIndex = i % 10;
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
                        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.asset(product.imageUrl, fit: BoxFit.cover))),
                          Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(product.brand, style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 10)),
                            Text(product.name, style: GoogleFonts.poppins(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text("\$${product.price.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: AppColors.secondaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
                          ])),
                        ]),
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
