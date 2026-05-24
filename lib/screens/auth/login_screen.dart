import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isValidEmail(String email) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);

  bool isStrongPassword(String password) => RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[@#$%&*!])(?=.{8,})').hasMatch(password);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 280,
            child: Stack(children: [
              Image.asset('assets/images/logo/splash_bg.png', width: double.infinity, height: 280, fit: BoxFit.cover, errorBuilder: (ctx, _, __) => Container(color: theme.colorScheme.primary)),
              Container(color: Colors.black.withOpacity(0.45)),
              Positioned(bottom: 24, left: 24, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Welcome\nBack', style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Login to your account', style: GoogleFonts.poppins(fontSize: 14, color: Colors.white.withOpacity(0.7))),
              ])),
            ]),
          ),
          Form(
            key: _formKey,
            child: Container(
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                _buildInput(controller: _emailController, label: "Email Address", icon: Icons.email_outlined, theme: theme),
                const SizedBox(height: 16),
                _buildInput(controller: _passwordController, label: "Password", icon: Icons.lock_outlined, isPassword: true, theme: theme),
                Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => _showForgotPassword(theme), child: Text("Forgot Password?", style: GoogleFonts.poppins(color: AppColors.secondaryColor, fontSize: 12)))),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: () => _handleLogin(theme),
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text("Login", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDivider(theme),
                const SizedBox(height: 16),
                _buildGoogleBtn(theme),
                const SizedBox(height: 24),
                _buildRegisterRow(theme),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, required ThemeData theme}) {
    return TextFormField(
      controller: controller, obscureText: isPassword && _obscurePassword,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.4)),
        labelText: label, labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
        filled: true, fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.secondaryColor, width: 2)),
        suffixIcon: isPassword ? IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: theme.colorScheme.onSurface.withOpacity(0.4)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)) : null,
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(children: [
      Expanded(child: Divider(color: theme.dividerColor)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text("OR", style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 14))),
      Expanded(child: Divider(color: theme.dividerColor)),
    ]);
  }

  Widget _buildGoogleBtn(ThemeData theme) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(backgroundColor: theme.cardColor, side: BorderSide(color: theme.dividerColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () => _googleSignIn(theme),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.g_mobiledata, size: 24, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 8),
          Text("Continue with Google", style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildRegisterRow(ThemeData theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Don't have an account? ", style: GoogleFonts.poppins(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
      TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.register), child: Text("Register", style: GoogleFonts.poppins(color: AppColors.secondaryColor, fontWeight: FontWeight.w600))),
    ]);
  }

  Future<void> _handleLogin(ThemeData theme) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!isStrongPassword(password.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters and include uppercase, lowercase, number, and special character.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final repo = AuthRepository();

    try {
      await repo.signInWithEmailPassword(email: email, password: password.trim());
      UserSession().login(email.split('@').first, email);
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(repo.friendlyError(e)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
}

  void _showForgotPassword(ThemeData theme) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text("Forgot Password?", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 8),
          Text("Enter your email address to reset password.", style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 24),
          _buildInput(controller: TextEditingController(), label: "Email Address", icon: Icons.email_outlined, theme: theme),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pop(context), child: Text("Send Reset Link", style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)))),
        ]),
      ),
    );
  }

  void _googleSignIn(ThemeData theme) {
    showModalBottomSheet(
      context: context, backgroundColor: theme.cardColor, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Choose an account", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 16),
          ListTile(leading: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.1), child: const Text("SV")), title: Text("Sajidha Vin", style: TextStyle(color: theme.colorScheme.primary)), subtitle: Text("sajidha.vin@gmail.com", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))), onTap: () => Navigator.pop(context)),
          const Divider(),
          ListTile(leading: const Icon(Icons.add_circle_outline), title: Text("Add another account", style: TextStyle(color: theme.colorScheme.primary)), onTap: () => Navigator.pop(context)),
        ]),
      ),
    );
  }
}
