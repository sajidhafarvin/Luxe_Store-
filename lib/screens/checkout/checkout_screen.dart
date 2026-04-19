import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Checkout Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Checkout Screen'),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.orderConfirmation),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
