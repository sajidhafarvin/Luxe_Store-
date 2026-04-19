import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const InputField(
              hintText: 'Full Name',
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            const InputField(
              hintText: 'Address Line 1',
            ),
            const SizedBox(height: 16),
            const InputField(
              hintText: 'City',
            ),
            const SizedBox(height: 16),
            const InputField(
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            const Text(
              'Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Credit Card'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            text: 'Place Order',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order placed successfully!')),
              );
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      ),
    );
  }
}
