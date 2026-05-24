import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<dynamic> _notifications = [
    {'title': 'Order Delivered!', 'body': 'Your order LX-PP28401 has been delivered.', 'time': '2 hours ago', 'icon': Icons.local_shipping_outlined, 'color': const Color(0xFF4CAF50), 'isRead': false},
    {'title': 'Flash Sale! 30% Off', 'body': 'Limited time offer on selected items.', 'time': '5 hours ago', 'icon': Icons.local_offer_outlined, 'color': const Color(0xFFE94560), 'isRead': false},
    {'title': 'Order Confirmed', 'body': 'Your order LX-PP28355 is confirmed.', 'time': '2 days ago', 'icon': Icons.check_circle_outline, 'color': const Color(0xFF6C63FF), 'isRead': true},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary), onPressed: () => Navigator.pop(context)),
        title: Text("Notifications", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
        centerTitle: true,
        actions: [
          TextButton(onPressed: () => setState(() { for (var n in _notifications) n['isRead'] = true; }), child: Text("Mark all read", style: GoogleFonts.poppins(color: AppColors.secondaryColor, fontWeight: FontWeight.w600))),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          final bool isRead = notif['isRead'];
          return GestureDetector(
            onTap: () { if (!isRead) setState(() => notif['isRead'] = true); },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: isRead ? theme.cardColor : AppColors.secondaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 48, height: 48, decoration: BoxDecoration(color: (notif['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(notif['icon'], color: notif['color'], size: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(child: Text(notif['title'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: theme.colorScheme.primary))),
                          if (!isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.secondaryColor, shape: BoxShape.circle)),
                        ]),
                        const SizedBox(height: 4),
                        Text(notif['body'], style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Text(notif['time'], style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
