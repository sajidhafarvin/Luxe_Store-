import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../utils/cart_manager.dart';
import '../../utils/wishlist_manager.dart';
import '../../utils/review_manager.dart';
import '../../utils/user_session.dart';
import '../cart/cart_screen.dart';
import '../../utils/theme_manager.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedSize = -1; // -1 = nothing selected yet
  int _selectedColor = 0;
  int _quantity = 1;
  bool _showAllReviews = false;

  // ── Colors / colour names ─────────────────────────────────────────────
  final List<Color> _colors = [
    const Color(0xFF1A1A2E), // Navy
    const Color(0xFFF5A623), // Gold
    const Color(0xFF9E9E9E), // Grey
  ];

  final List<List<String>> _colorOptions = [
    ['Navy', 'Gold', 'Grey'],
    ['Black', 'White', 'Nude'],
    ['Tan', 'Black', 'Brown'],
    ['Navy', 'Black', 'Brown'],
    ['Gold', 'Silver', 'Rose'],
    ['Camel', 'Black', 'Grey'],
    ['Indigo', 'Black', 'Grey'],
    ['White', 'Blue', 'Pink'],
    ['Tan', 'Black', 'White'],
    ['Gold', 'Silver', 'Rose'],
  ];

  // ── Size selector: driven by product category ─────────────────────────
  List<String> _getSizesForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'women':
        return ['XS', 'S', 'M', 'L', 'XL'];
      case 'men':
        return ['S', 'M', 'L', 'XL', 'XXL'];
      case 'kids':
        return ['2Y', '4Y', '6Y', '8Y', '10Y', '12Y'];
      case 'accessories':
        return ['One Size'];
      default:
        return ['S', 'M', 'L', 'XL'];
    }
  }

  bool get _isFavorite {
    final product =
        ModalRoute.of(context)?.settings.arguments as Product?;
    return WishlistManager().isWishlisted(product?.name ?? '');
  }

  // ── Snack bar helper ──────────────────────────────────────────────────
  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Add to Cart logic ─────────────────────────────────────────────────
  void _handleAddToCart(
    Product product,
    List<String> sizes,
    BuildContext context,
  ) {
    // 1. Auth check
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      _showSnackBar('Please login first to add items to cart.');
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) Navigator.pushNamed(context, AppRoutes.login);
      });
      return;
    }

    // 2. Size check (skip for "One Size" products — auto-selected)
    final isOneSize = sizes.length == 1 && sizes.first == 'One Size';
    if (!isOneSize && _selectedSize == -1) {
      _showSnackBar('Please select a size before adding to cart.');
      return;
    }

    // 3. Add to cart
    final chosenSize = isOneSize
        ? 'One Size'
        : sizes[_selectedSize < sizes.length ? _selectedSize : 0];

    CartManager().addItem({
      'name': product.name,
      'price': '\$${product.price.toStringAsFixed(2)}',
      'image': product.imageUrl,
      'brand': product.brand,
      'size': chosenSize,
      'color': _colors[_selectedColor % _colors.length],
      'qty': _quantity,
    });

    _showSnackBar('Item added to cart! 🛍️', backgroundColor: Colors.green);
    setState(() {}); // refresh cart badge
  }

  @override
  Widget build(BuildContext context) {
    // ── Receive Product from navigation ──────────────────────────────────
    final product =
        ModalRoute.of(context)!.settings.arguments as Product;

    final currentSizes = _getSizesForCategory(product.category);
    final showSizes = currentSizes.isNotEmpty;

    // Auto-select when there is only "One Size"
    if (currentSizes.length == 1 && currentSizes.first == 'One Size' && _selectedSize == -1) {
      _selectedSize = 0;
    }

    // Colour options fallback by index (clamped)
    final colorIndex =
        product.reviewsCount % _colorOptions.length;
    final currentColorOptions = _colorOptions[colorIndex];

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Full-bleed hero image ────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              product.imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) =>
                  Container(color: theme.colorScheme.primary),
            ),
          ),

          // ── Scrollable content card ──────────────────────────────────
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 320),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + rating row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Color(0xFFF5A623), size: 18),
                              const SizedBox(width: 4),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${product.reviewsCount})',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Brand
                      Text(
                        product.brand.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          letterSpacing: 1.5,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Price row (with original price if on sale)
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                          if (product.isOnSale) ...[
                            const SizedBox(width: 12),
                            Text(
                              '\$${product.originalPrice.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${product.discountPercentage}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Description
                      Text(
                        product.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color:
                              theme.colorScheme.onSurface.withOpacity(0.6),
                          height: 1.5,
                        ),
                        maxLines: 4,
                      ),

                      // ── Size selector ──────────────────────────────
                      if (showSizes) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SELECT SIZE',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: theme.colorScheme.primary,
                                letterSpacing: 1,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap),
                              onPressed: () {},
                              child: Text('Size Guide',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.secondaryColor,
                                      fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            currentSizes.length,
                            (index) => GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedSize = index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedSize == index
                                      ? AppColors.primaryColor
                                      : theme.cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _selectedSize == index
                                        ? AppColors.primaryColor
                                        : theme.dividerColor,
                                  ),
                                ),
                                child: Text(
                                  currentSizes[index],
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedSize == index
                                        ? Colors.white
                                        : theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],

                      // ── Colour + Quantity row ──────────────────────
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'COLORWAY',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 1),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(
                                    currentColorOptions.length, (index) {
                                  bool isSelected = _selectedColor == index;
                                  return GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedColor = index),
                                    child: Container(
                                      margin:
                                          const EdgeInsets.only(right: 8),
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _colors[
                                            index % _colors.length],
                                        shape: BoxShape.circle,
                                        border: isSelected
                                            ? Border.all(
                                                color:
                                                    AppColors.secondaryColor,
                                                width: 2)
                                            : null,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'QUANTITY',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: theme.colorScheme.primary,
                                    letterSpacing: 1),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_quantity > 1) {
                                        setState(() => _quantity--);
                                      }
                                    },
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: theme.dividerColor),
                                          color: theme.cardColor),
                                      child: Icon(Icons.remove,
                                          color: theme.colorScheme.primary,
                                          size: 18),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text('$_quantity',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color:
                                                theme.colorScheme.primary)),
                                  ),
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _quantity++),
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: theme.colorScheme.primary),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      // ── Material info ──────────────────────────────
                      const SizedBox(height: 24),
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: 12),
                      Text(
                        product.materialTitle.toUpperCase(),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.materialDescription,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.6)),
                      ),

                      // ── Reviews section ───────────────────────────
                      const SizedBox(height: 24),
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                ReviewManager()
                                    .getAverageRating(product.name)
                                    .toStringAsFixed(1),
                                style: GoogleFonts.poppins(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary),
                              ),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i <
                                            ReviewManager()
                                                .getAverageRating(
                                                    product.name)
                                                .round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: const Color(0xFFF5A623),
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${ReviewManager().getRatingCount(product.name)} reviews',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6)),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: ['5', '4', '3', '2', '1'].map((star) {
                                final count = ReviewManager()
                                        .getRatingBreakdown(product.name)[
                                    star] ??
                                    0;
                                final total = ReviewManager()
                                    .getRatingCount(product.name);
                                final percent =
                                    total > 0 ? count / total : 0.0;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(children: [
                                    Text(star,
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6))),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.star,
                                        size: 12,
                                        color: Color(0xFFF5A623)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: percent,
                                          backgroundColor: theme.dividerColor,
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                  Color(0xFFF5A623)),
                                          minHeight: 8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(count.toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.6))),
                                  ]),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Customer Reviews',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary)),
                          TextButton(
                            onPressed: () =>
                                _showAddReviewSheet(context, product.name),
                            child: Row(children: [
                              const Icon(Icons.edit_outlined,
                                  size: 16, color: AppColors.secondaryColor),
                              const SizedBox(width: 4),
                              Text('Write Review',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.secondaryColor)),
                            ]),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Builder(builder: (context) {
                        final reviews =
                            ReviewManager().getReviews(product.name);
                        final displayReviews = _showAllReviews
                            ? reviews
                            : reviews.take(2).toList();
                        return Column(
                          children: [
                            ...displayReviews
                                .map((r) => _buildReviewCard(r, theme)),
                            if (reviews.length > 2)
                              TextButton(
                                onPressed: () => setState(
                                    () => _showAllReviews = !_showAllReviews),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _showAllReviews
                                          ? 'Show Less'
                                          : 'See All ${reviews.length} Reviews',
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: AppColors.secondaryColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Icon(
                                      _showAllReviews
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }),

                      // Space for the sticky bottom bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Back button ──────────────────────────────────────────────
          Positioned(
            top: 48,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Icon(Icons.arrow_back,
                    color: theme.colorScheme.primary, size: 20),
              ),
            ),
          ),

          // ── Wishlist button ──────────────────────────────────────────
          Positioned(
            top: 48,
            right: 16,
            child: GestureDetector(
              onTap: () {
                WishlistManager().toggleWishlist({
                  'name': product.name,
                  'price': '\$${product.price.toStringAsFixed(2)}',
                  'image': product.imageUrl,
                  'brand': product.brand,
                });
                setState(() {});
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color:
                      _isFavorite ? AppColors.secondaryColor : Colors.grey,
                  size: 20,
                ),
              ),
            ),
          ),

          // ── Cart button (top-right, secondary) ──────────────────────
          Positioned(
            top: 48,
            right: 68,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: '/cart'),
                  builder: (_) => const CartScreen(),
                ),
              ),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.shopping_bag_outlined,
                          color: theme.colorScheme.primary, size: 20),
                    ),
                    if (CartManager().itemCount > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                              color: AppColors.secondaryColor,
                              shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              CartManager().itemCount > 9
                                  ? '9+'
                                  : '${CartManager().itemCount}',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Sticky "Add to Cart" bar ─────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: theme.cardColor,
              padding: const EdgeInsets.only(
                  left: 16, top: 12, right: 16, bottom: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () =>
                      _handleAddToCart(product, currentSizes, context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Review card widget ────────────────────────────────────────────────
  Widget _buildReviewCard(Map<String, dynamic> review, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkModeNotifier.value
            ? const Color(0xFF2D2D2D)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: Color(review['color'] as int),
                shape: BoxShape.circle),
            child: Center(
              child: Text(
                review['initials'],
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(review['name'],
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary)),
                Text(review['date'],
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < (review['rating'] as int)
                    ? Icons.star
                    : Icons.star_border,
                color: const Color(0xFFF5A623),
                size: 14,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Text(review['comment'],
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                height: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text('Helpful (${review['helpful']})',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        ]),
      ]),
    );
  }

  // ── Add review bottom sheet ───────────────────────────────────────────
  void _showAddReviewSheet(BuildContext context, String productName) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Write a Review',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 4),
                Text(productName,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6))),
                const SizedBox(height: 20),
                Text('Your Rating',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () =>
                          setModalState(() => selectedRating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: const Color(0xFFF5A623),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    ['', 'Terrible', 'Poor', 'Good', 'Great', 'Excellent!'][
                        selectedRating],
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFFF5A623),
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Your Review',
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: commentController,
                  maxLines: 4,
                  maxLength: 300,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Share your experience...',
                    hintStyle:
                        GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                    filled: true,
                    fillColor: isDarkModeNotifier.value
                        ? const Color(0xFF2D2D2D)
                        : Colors.grey[50],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Theme.of(context).dividerColor)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: Theme.of(context).dividerColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.secondaryColor, width: 2)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (commentController.text.isEmpty) return;
                      final initials = UserSession()
                              .userName
                              .isNotEmpty
                          ? UserSession()
                              .userName
                              .split(' ')
                              .map((w) => w.isNotEmpty ? w[0] : '')
                              .join('')
                              .toUpperCase()
                          : 'U';
                      ReviewManager().addReview(productName, {
                        'name': UserSession().userName.isNotEmpty
                            ? UserSession().userName
                            : 'Anonymous User',
                        'rating': selectedRating,
                        'date': 'Just now',
                        'comment': commentController.text,
                        'initials': initials,
                        'color': 0xFF1A1A2E,
                        'helpful': 0,
                      });
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                    child: Text('Submit Review',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
