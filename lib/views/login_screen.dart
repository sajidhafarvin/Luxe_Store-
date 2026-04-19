import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';
import '../utils/routes.dart';
import '../utils/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final success = await authVM.login(_emailController.text, _passwordController.text);
    
    if (success) {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Fluttertoast.showToast(msg: authVM.errorMessage, backgroundColor: AppColors.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              InputField(
                controller: _emailController,
                hintText: 'Email address',
                prefixIcon: const Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              InputField(
                controller: _passwordController,
                hintText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                isPassword: true,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Login / Register',
                onPressed: _handleLogin,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
