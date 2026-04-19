import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Order Confirmation Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Order Confirmation Screen'),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
