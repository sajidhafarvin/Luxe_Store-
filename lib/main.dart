import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_routes.dart';
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

void main() {
  runApp(const LuxeStoreApp());
}

class LuxeStoreApp extends StatelessWidget {
  const LuxeStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luxe Store',
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.productList: (context) => const ProductListScreen(),
        AppRoutes.productDetails: (context) => const ProductDetailsScreen(),
        AppRoutes.womenProducts: (context) => const WomenProductListScreen(),
        AppRoutes.menProducts: (context) => const MenProductListScreen(),
        AppRoutes.kidsProducts: (context) => const KidsProductListScreen(),
        AppRoutes.accessoriesProducts: (context) => const AccessoriesProductListScreen(),
        AppRoutes.cart: (context) => const CartScreen(),
        AppRoutes.checkout: (context) => const CheckoutScreen(),
        AppRoutes.orderConfirmation: (context) => const OrderConfirmationScreen(),
        AppRoutes.orderHistory: (context) => const OrderHistoryScreen(),
        AppRoutes.profile: (context) => const ProfileScreen(),
      },
    );
  }
}
