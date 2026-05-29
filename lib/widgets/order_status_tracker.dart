import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

// ─── Helper functions (exported for reuse) ────────────────────────────────────

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return const Color(0xFF2196F3);
    case 'shipped':
      return const Color(0xFF9C27B0);
    case 'delivered':
      return AppColors.successColor;
    case 'cancelled':
      return AppColors.errorColor;
    case 'pending':
    default:
      return const Color(0xFFFF9800);
  }
}

IconData getStatusIcon(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Icons.hourglass_empty_rounded;
    case 'confirmed':
      return Icons.check_circle_outline_rounded;
    case 'shipped':
      return Icons.local_shipping_outlined;
    case 'delivered':
      return Icons.done_all_rounded;
    case 'cancelled':
      return Icons.cancel_outlined;
    default:
      return Icons.help_outline_rounded;
  }
}

/// Returns estimated delivery label based on order creation date and status.
String formatEstimatedDelivery(Timestamp createdAt, String status) {
  final created = createdAt.toDate();
  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  switch (status.toLowerCase()) {
    case 'pending':
      final est = created.add(const Duration(days: 7));
      return '${months[est.month - 1]} ${est.day}, ${est.year}';
    case 'confirmed':
      final est = created.add(const Duration(days: 5));
      return '${months[est.month - 1]} ${est.day}, ${est.year}';
    case 'shipped':
      final est = created.add(const Duration(days: 3));
      return '${months[est.month - 1]} ${est.day}, ${est.year}';
    case 'delivered':
      return 'Delivered';
    default:
      return 'N/A';
  }
}

// ─── Status Steps Definition ──────────────────────────────────────────────────

const _steps = ['pending', 'confirmed', 'shipped', 'delivered'];

const _stepLabels = {
  'pending': 'Pending',
  'confirmed': 'Confirmed',
  'shipped': 'Shipped',
  'delivered': 'Delivered',
};

const _stepDescriptions = {
  'pending': 'Order received',
  'confirmed': 'Order confirmed',
  'shipped': 'On the way',
  'delivered': 'Delivered',
};

// ─── Widget ───────────────────────────────────────────────────────────────────

class OrderStatusTracker extends StatefulWidget {
  final String currentStatus;
  final List<Map<String, dynamic>> statusHistory;
  final Timestamp createdAt;

  const OrderStatusTracker({
    super.key,
    required this.currentStatus,
    required this.statusHistory,
    required this.createdAt,
  });

  @override
  State<OrderStatusTracker> createState() => _OrderStatusTrackerState();
}

class _OrderStatusTrackerState extends State<OrderStatusTracker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  int get _currentIndex {
    final idx = _steps.indexOf(widget.currentStatus.toLowerCase());
    return idx < 0 ? 0 : idx;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(OrderStatusTracker old) {
    super.didUpdateWidget(old);
    if (old.currentStatus != widget.currentStatus) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _timestampForStep(String step) {
    for (final entry in widget.statusHistory) {
      if ((entry['status']?.toString().toLowerCase() ?? '') == step) {
        final ts = entry['timestamp'];
        if (ts is Timestamp) {
          final d = ts.toDate();
          final months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          final h = d.hour > 12
              ? d.hour - 12
              : (d.hour == 0 ? 12 : d.hour);
          final amPm = d.hour >= 12 ? 'PM' : 'AM';
          final min = d.minute.toString().padLeft(2, '0');
          return '${months[d.month - 1]} ${d.day} · $h:$min $amPm';
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCancelled = widget.currentStatus.toLowerCase() == 'cancelled';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? AppColors.errorColor.withOpacity(0.12)
                      : AppColors.secondaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCancelled
                      ? Icons.cancel_outlined
                      : Icons.local_shipping_outlined,
                  color: isCancelled
                      ? AppColors.errorColor
                      : AppColors.secondaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Status',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    isCancelled
                        ? 'This order was cancelled'
                        : 'Est. delivery: ${formatEstimatedDelivery(widget.createdAt, widget.currentStatus)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          if (isCancelled)
            _buildCancelledBanner(theme)
          else
            _buildTimeline(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildCancelledBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel_outlined, color: AppColors.errorColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Cancelled',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.errorColor,
                  ),
                ),
                Text(
                  'This order has been cancelled.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(ThemeData theme, bool isDark) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, _) {
        return Column(
          children: List.generate(_steps.length, (i) {
            final step = _steps[i];
            final isCompleted = i < _currentIndex;
            final isActive = i == _currentIndex;
            final isUpcoming = i > _currentIndex;
            final isLast = i == _steps.length - 1;

            final stepColor = isCompleted
                ? AppColors.successColor
                : isActive
                    ? getStatusColor(step)
                    : theme.colorScheme.onSurface.withOpacity(0.25);

            final ts = _timestampForStep(step);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: icon + connector line
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      // Circle/Icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        width: isActive ? 38 : 32,
                        height: isActive ? 38 : 32,
                        decoration: BoxDecoration(
                          color: isUpcoming
                              ? theme.colorScheme.onSurface.withOpacity(0.06)
                              : stepColor.withOpacity(isActive ? 0.15 : 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isUpcoming
                                ? theme.colorScheme.onSurface.withOpacity(0.18)
                                : stepColor,
                            width: isActive ? 2.5 : 1.5,
                          ),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: stepColor.withOpacity(0.35),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(Icons.check_rounded,
                                  size: 16, color: AppColors.successColor)
                              : Icon(
                                  getStatusIcon(step),
                                  size: isActive ? 18 : 15,
                                  color: isUpcoming
                                      ? theme.colorScheme.onSurface
                                          .withOpacity(0.3)
                                      : stepColor,
                                ),
                        ),
                      ),
                      // Connector line
                      if (!isLast)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          width: 2.5,
                          height: ts != null ? 64 : 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: isCompleted
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.successColor,
                                      Color(0xFF66BB6A),
                                    ],
                                  )
                                : null,
                            color: isCompleted
                                ? null
                                : theme.colorScheme.onSurface.withOpacity(0.12),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Right column: label + timestamp
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: 6,
                      bottom: isLast ? 0 : (ts != null ? 36 : 24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _stepLabels[step] ?? step,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isUpcoming
                                    ? theme.colorScheme.onSurface
                                        .withOpacity(0.38)
                                    : isCompleted
                                        ? AppColors.successColor
                                        : stepColor,
                              ),
                            ),
                            if (isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: stepColor.withOpacity(0.13),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Current',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: stepColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _stepDescriptions[step] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: theme.colorScheme.onSurface
                                .withOpacity(isUpcoming ? 0.3 : 0.5),
                          ),
                        ),
                        if (ts != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.4),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ts,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.45),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
