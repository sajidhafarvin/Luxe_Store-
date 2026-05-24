import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      if (mounted) {
        Navigator.pushReplacementNamed(context, user == null ? AppRoutes.login : AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo/logo.png', width: 120, height: 120, errorBuilder: (ctx, _, __) => Icon(Icons.image_not_supported, size: 120, color: theme.colorScheme.onPrimary)),
            const SizedBox(height: 24),
            Text('LUXE', style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
            const SizedBox(height: 8),
            Text('Style is Everything', style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.onPrimary.withOpacity(0.7))),
            const SizedBox(height: 48),
            CircularProgressIndicator(color: theme.colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}
