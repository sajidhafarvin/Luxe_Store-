import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  
  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: const Color(0xFFE94560),
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            if (currentIndex != 0) Navigator.pushReplacementNamed(context, AppRoutes.home);
            break;
          case 1:
            if (currentIndex != 1) Navigator.pushReplacementNamed(context, AppRoutes.productList);
            break;
          case 2:
            if (currentIndex != 2) Navigator.pushReplacementNamed(context, AppRoutes.cart);
            break;
          case 3:
            if (currentIndex != 3) Navigator.pushReplacementNamed(context, AppRoutes.profile);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
