import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/order.dart' as app_model;
import '../../providers/order_provider.dart';
import '../../widgets/order_status_tracker.dart';

class OrderDetailsScreen extends StatefulWidget {
  final app_model.Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  late app_model.Order _order;
  bool _isUpdating = false;
  late AnimationController _statusBannerController;
  late Animation<double> _statusBannerAnimation;

  // Status progression
  static const _statusFlow = ['pending', 'confirmed', 'shipped', 'delivered'];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _statusBannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _statusBannerAnimation = CurvedAnimation(
      parent: _statusBannerController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _statusBannerController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatDate(app_model.Order order) {
    final date = order.createdAt.toDate();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = date.hour > 12
        ? (date.hour - 12)
        : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final min = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$min $amPm';
  }

  String _getFullOrderId(app_model.Order order) =>
      order.id?.toUpperCase() ?? 'UNKNOWN';

  String? _nextStatus(String current) {
    final idx = _statusFlow.indexOf(current.toLowerCase());
    if (idx < 0 || idx >= _statusFlow.length - 1) return null;
    return _statusFlow[idx + 1];
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ── Status update ──────────────────────────────────────────────────────────

  Future<void> _changeStatus(String newStatus) async {
    if (_order.id == null || _isUpdating) return;
    setState(() => _isUpdating = true);

    final provider = Provider.of<OrderProvider>(context, listen: false);
    final success =
        await provider.updateOrderStatus(_order.id!, newStatus);

    if (!mounted) return;
    if (success) {
      // Locally update so the UI reflects immediately
      final newHistory = [
        ..._order.statusHistory,
        {'status': newStatus, 'timestamp': Timestamp.now()},
      ];
      _statusBannerController.forward(from: 0);
      setState(() {
        _order = _order.copyWith(
          status: newStatus,
          statusHistory: newHistory,
        );
        _isUpdating = false;
      });
      _showStatusSnackbar(newStatus);
    } else {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status',
              style: GoogleFonts.poppins(color: Colors.white)),
          backgroundColor: AppColors.errorColor,
        ),
      );
    }
  }

  void _showStatusSnackbar(String status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: getStatusColor(status),
        content: Row(
          children: [
            Icon(getStatusIcon(status), color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Status updated to ${_capitalize(status)}',
              style: GoogleFonts.poppins(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Pull-to-refresh ────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    if (_order.id == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('orders')
          .doc(_order.id)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _order = app_model.Order.fromFirestore(doc);
          _statusBannerController.forward(from: 0);
        });
      }
    } catch (e) {
      debugPrint('Refresh error: $e');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    double subtotal = 0.0;
    for (final item in _order.items) {
      final price =
          double.tryParse(item.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
      subtotal += price * item.qty;
    }
    double deliveryFee = _order.totalAmount - subtotal;
    if (deliveryFee < 0) deliveryFee = 0.0;

    final nextStatus = _nextStatus(_order.status);
    final isCancelled = _order.status.toLowerCase() == 'cancelled';
    final isDelivered = _order.status.toLowerCase() == 'delivered';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: RefreshIndicator(
        color: AppColors.secondaryColor,
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Order Info Card ────────────────────────────────────────────
              _buildOrderInfoCard(theme, isDark),

              const SizedBox(height: 20),

              // ── Status Tracker ─────────────────────────────────────────────
              FadeTransition(
                opacity: _statusBannerAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.08),
                    end: Offset.zero,
                  ).animate(_statusBannerAnimation),
                  child: OrderStatusTracker(
                    currentStatus: _order.status,
                    statusHistory: _order.statusHistory,
                    createdAt: _order.createdAt,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Status Change Buttons (for testing) ───────────────────────
              if (!isCancelled) _buildStatusChangeSection(theme, nextStatus, isDelivered),

              // ── Track Order Button ─────────────────────────────────────────
              if (!isDelivered && !isCancelled) ...[
                const SizedBox(height: 16),
                _buildTrackOrderButton(theme),
              ],

              const SizedBox(height: 24),

              // ── Items ──────────────────────────────────────────────────────
              Text(
                'Items',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              _buildItemsList(theme),

              const SizedBox(height: 8),

              // ── Order Summary ──────────────────────────────────────────────
              _buildOrderSummary(theme, subtotal, deliveryFee),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-builders ───────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Order Details',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
          onPressed: _refresh,
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard(ThemeData theme, bool isDark) {
    final statusColor = getStatusColor(_order.status);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ID',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              // Animated status badge
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Container(
                  key: ValueKey(_order.status),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(getStatusIcon(_order.status),
                          size: 13, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        _order.status.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'LX-${_getFullOrderId(_order)}',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 14),
          _infoRow('Order Date', _formatDate(_order), theme),
          const SizedBox(height: 10),
          _infoRow('Payment', _order.paymentMethod, theme),
          if (_order.deliveryAddress != null &&
              _order.deliveryAddress!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Address',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _order.deliveryAddress!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: theme.colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChangeSection(
      ThemeData theme, String? nextStatus, bool isDelivered) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(width: 6),
              Text(
                'Update Status  (Testing)',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusFlow.map((s) {
              final isActive = s == _order.status.toLowerCase();
              final color = getStatusColor(s);
              return AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.65,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: _isUpdating || isActive ? null : () => _changeStatus(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? color.withOpacity(0.15)
                          : theme.colorScheme.onSurface.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isActive
                            ? color
                            : theme.colorScheme.onSurface.withOpacity(0.15),
                        width: isActive ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isUpdating && isActive)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: color,
                            ),
                          )
                        else
                          Icon(getStatusIcon(s),
                              size: 14,
                              color: isActive
                                  ? color
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.4)),
                        const SizedBox(width: 6),
                        Text(
                          _capitalize(s),
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? color
                                : theme.colorScheme.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackOrderButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        icon: const Icon(Icons.local_shipping_outlined,
            color: Colors.white, size: 20),
        label: Text(
          'Track Order',
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _TrackingBottomSheet(order: _order),
          );
        },
      ),
    );
  }

  Widget _buildItemsList(ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _order.items.length,
      itemBuilder: (context, index) {
        final item = _order.items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
              )
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.image.startsWith('http')
                    ? Image.network(
                        item.image,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPlaceholder(),
                      )
                    : Image.asset(
                        item.image,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imgPlaceholder(),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Size: ${item.size} · Qty: ${item.qty}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${item.price}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey.withOpacity(0.15),
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }

  Widget _buildOrderSummary(
      ThemeData theme, double subtotal, double deliveryFee) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _summaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', theme),
          const SizedBox(height: 12),
          _summaryRow(
              'Delivery', '\$${deliveryFee.toStringAsFixed(2)}', theme),
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '\$${_order.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: theme.colorScheme.onSurface.withOpacity(0.55),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

// ─── Track Order Bottom Sheet ──────────────────────────────────────────────────

class _TrackingBottomSheet extends StatelessWidget {
  final app_model.Order order;

  const _TrackingBottomSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Track Your Order',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'LX-${order.id?.toUpperCase() ?? ""}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          OrderStatusTracker(
            currentStatus: order.status,
            statusHistory: order.statusHistory,
            createdAt: order.createdAt,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
