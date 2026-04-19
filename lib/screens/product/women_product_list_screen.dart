import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';

class WomenProductListScreen extends StatelessWidget {
  const WomenProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: const Text('Women Products Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Women Products Screen'),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.productDetails),
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
