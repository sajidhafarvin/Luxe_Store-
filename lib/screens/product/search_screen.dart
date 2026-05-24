import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../models/product.dart';
import '../../repositories/product_repository.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _productRepository = ProductRepository();
  bool _isLoading = true;
  bool _hasError = false;

  List<Map<String, dynamic>> _allProducts = [];

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> results = _allProducts;
    if (_selectedCategory != 'All') results = results.where((p) => p['category'] == _selectedCategory).toList();
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      results = results.where((p) => p['name'].toString().toLowerCase().contains(query) || p['category'].toString().toLowerCase().contains(query) || p['brand'].toString().toLowerCase().contains(query)).toList();
    }
    return results;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _focusNode.requestFocus());
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final products = await _productRepository.fetchProducts();
      if (!mounted) return;
      setState(() {
        _allProducts = products.asMap().entries.map((entry) {
          final i = entry.key;
          final Product p = entry.value;
          return {
            'id': p.id,
            'name': p.name,
            'price': '\$${p.price.toStringAsFixed(0)}',
            'image': p.imageUrl,
            'brand': p.brand,
            'category': p.category,
            'index': i % 10,
            'description': p.description,
            'materialTitle': p.materialTitle,
            'materialDescription': p.materialDescription,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
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
        title: TextField(
          controller: _searchController, focusNode: _focusNode,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(hintText: "Search fashion...", hintStyle: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)), border: InputBorder.none),
          style: GoogleFonts.poppins(fontSize: 15, color: theme.colorScheme.primary),
        ),
        actions: [if (_searchQuery.isNotEmpty) IconButton(icon: Icon(Icons.clear, color: theme.colorScheme.onSurface.withOpacity(0.4)), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 50, color: theme.cardColor,
            child: ListView(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
              children: ['All', 'Women', 'Men', 'Kids', 'Accessories'].map((c) => _buildCategoryChip(c, theme)).toList(),
            ),
          ),
          Expanded(child: _buildBody(theme)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, ThemeData theme) {
    bool isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? AppColors.primaryColor : theme.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? AppColors.primaryColor : theme.dividerColor)),
        child: Center(child: Text(category, style: GoogleFonts.poppins(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.6)))),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_hasError) return Center(child: Text("Failed to load products", style: TextStyle(color: theme.colorScheme.onSurface)));
    if (_searchQuery.isEmpty && _selectedCategory == 'All') return _buildInitialState(theme);
    if (_filteredProducts.isEmpty) return _buildNoResultsState(theme);
    return _buildResultsState(theme);
  }

  Widget _buildInitialState(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Popular Searches", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.primary)),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: ['Silk Dress', 'Cashmere Coat', 'Leather Bag', 'Gold Jewelry'].map((tag) => _buildPopularSearchTag(tag, theme)).toList()),
        const SizedBox(height: 32),
        Text("Trending Now", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.primary)),
        const SizedBox(height: 16),
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75), itemCount: 4.clamp(0, _allProducts.length), itemBuilder: (ctx, i) => _buildProductCard(_allProducts[i], theme)),
      ]),
    );
  }

  Widget _buildPopularSearchTag(String tag, ThemeData theme) {
    return GestureDetector(
      onTap: () { _searchController.text = tag; setState(() => _searchQuery = tag); },
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: theme.dividerColor)), child: Text(tag, style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.primary))),
    );
  }

  Widget _buildNoResultsState(ThemeData theme) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.search_off, size: 80, color: theme.dividerColor),
      const SizedBox(height: 16),
      Text("No results found for", style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
      Text('"$_searchQuery"', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
    ]));
  }

  Widget _buildResultsState(ThemeData theme) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.all(16), child: Text("${_filteredProducts.length} results found", style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.4)))),
      Expanded(child: GridView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75), itemCount: _filteredProducts.length, itemBuilder: (ctx, i) => _buildProductCard(_filteredProducts[i], theme))),
    ]);
  }

  Widget _buildProductCard(Map<String, dynamic> product, ThemeData theme) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/product-details',
        arguments: {
          'id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'image': product['image'],
          'brand': product['brand'],
          'rating': '4.9',
          'index': product['index'],
          'description': product['description'],
          'materialTitle': product['materialTitle'],
          'materialDescription': product['materialDescription'],
        },
      ),
      child: Container(
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.asset(product['image'], width: double.infinity, fit: BoxFit.cover))),
          Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product['brand'], style: GoogleFonts.poppins(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.4))),
            Text(product['name'], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(product['price'], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryColor)),
          ])),
        ]),
      ),
    );
  }
}
