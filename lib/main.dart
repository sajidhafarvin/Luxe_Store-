import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/product/product_list_screen.dart';
import 'screens/product/product_details_screen.dart';
import 'screens/product/women_product_list_screen.dart';
import 'screens/product/men_product_list_screen.dart';
import 'screens/product/kids_product_list_screen.dart';
import 'screens/product/accessories_product_list_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/checkout/order_confirmation_screen.dart';
import 'screens/orders/order_history_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/wishlist_screen.dart';
import 'screens/product/search_screen.dart';
import 'screens/profile/settings_screen.dart';
import 'screens/profile/notifications_screen.dart';
import 'screens/profile/addresses_screen.dart';
import 'utils/theme_manager.dart';
import 'services/firestore_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    await FirestoreSeeder().seedIfNeeded();
  } catch (_) {}
  runApp(const LuxeStoreApp());
}

class LuxeStoreApp extends StatelessWidget {
  const LuxeStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          title: 'Luxe Store',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.register: (context) => const RegisterScreen(),
            AppRoutes.home: (context) => const HomeScreen(),
            AppRoutes.productList: (context) => const ProductListScreen(),
            AppRoutes.productDetails: (context) => const ProductDetailsScreen(),
            AppRoutes.womenProducts: (context) =>
                const WomenProductListScreen(),
            AppRoutes.menProducts: (context) => const MenProductListScreen(),
            AppRoutes.kidsProducts: (context) => const KidsProductListScreen(),
            AppRoutes.accessoriesProducts: (context) =>
                const AccessoriesProductListScreen(),
            AppRoutes.cart: (context) => const CartScreen(),
            AppRoutes.checkout: (context) => const CheckoutScreen(),
            AppRoutes.orderConfirmation: (context) =>
                const OrderConfirmationScreen(),
            AppRoutes.orderHistory: (context) => const OrderHistoryScreen(),
            AppRoutes.profile: (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/addresses': (context) => const AddressesScreen(),
            '/search': (context) => const SearchScreen(),
            '/wishlist': (context) => const WishlistScreen(),
          },
        );
      },
    );
  }
}
