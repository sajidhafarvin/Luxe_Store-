import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_routes.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Validation helpers
  bool _isValidEmail(String email) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);

  bool _isStrongPassword(String password) =>
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{8,}$')
          .hasMatch(password);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(children: [
          // ── Hero header ──────────────────────────────────────────────
          SizedBox(
            height: 280,
            child: Stack(children: [
              Image.asset(
                'assets/images/logo/splash_bg.png',
                width: double.infinity, height: 280, fit: BoxFit.cover,
                errorBuilder: (ctx, _, __) =>
                    Container(color: theme.colorScheme.primary),
              ),
              Container(color: Colors.black.withOpacity(0.45)),
              Positioned(
                bottom: 24, left: 24,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Create\nAccount',
                      style: GoogleFonts.poppins(
                          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Join LUXE today',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white.withOpacity(0.7))),
                ]),
              ),
            ]),
          ),

          // ── Form card ─────────────────────────────────────────────────
          Form(
            key: _formKey,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                _buildInput(controller: _nameController,    label: "Full Name",       icon: Icons.person_outlined,  theme: theme),
                const SizedBox(height: 16),
                _buildInput(controller: _emailController,   label: "Email Address",   icon: Icons.email_outlined,   theme: theme),
                const SizedBox(height: 16),
                _buildInput(controller: _phoneController,   label: "Phone Number",    icon: Icons.phone_outlined,   theme: theme),
                const SizedBox(height: 16),
                _buildInput(controller: _passwordController, label: "Password",       icon: Icons.lock_outlined,    isPassword: true,  theme: theme),
                const SizedBox(height: 16),
                _buildInput(controller: _confirmController, label: "Confirm Password", icon: Icons.lock_outlined,   isPassword: true, isConfirm: true, theme: theme),
                const SizedBox(height: 24),

                // Register button
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Register Now",
                            style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 16),
                _buildDivider(theme),
                const SizedBox(height: 16),
                _buildGoogleBtn(theme),
                const SizedBox(height: 24),
                _buildLoginRow(theme),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Reusable input field ─────────────────────────────────────────────
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isConfirm = false,
    required ThemeData theme,
  }) {
    final obscure = isPassword && (isConfirm ? _obscureConfirm : _obscurePassword);
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.4)),
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
        filled: true,
        fillColor: theme.scaffoldBackgroundColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.dividerColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.dividerColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.secondaryColor, width: 2)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (isConfirm ? _obscureConfirm : _obscurePassword)
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                onPressed: () => setState(() {
                  if (isConfirm) {
                    _obscureConfirm = !_obscureConfirm;
                  } else {
                    _obscurePassword = !_obscurePassword;
                  }
                }),
              )
            : null,
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(children: [
      Expanded(child: Divider(color: theme.dividerColor)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text("OR",
            style: GoogleFonts.poppins(
                color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 14)),
      ),
      Expanded(child: Divider(color: theme.dividerColor)),
    ]);
  }

  Widget _buildGoogleBtn(ThemeData theme) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: theme.cardColor,
          side: BorderSide(color: theme.dividerColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => _googleSignIn(theme),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.g_mobiledata, size: 24, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(width: 8),
          Text("Continue with Google",
              style: GoogleFonts.poppins(
                  color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
        ]),
      ),
    );
  }

  Widget _buildLoginRow(ThemeData theme) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Already have an account? ",
          style: GoogleFonts.poppins(
              color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 14)),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
        child: Text("Login",
            style: GoogleFonts.poppins(
                color: AppColors.secondaryColor, fontWeight: FontWeight.w600)),
      ),
    ]);
  }

  // ── Registration logic ───────────────────────────────────────────────
  Future<void> _handleRegister() async {
    final name     = _nameController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm  = _confirmController.text;

    // ── Field-level validation ──
    if (name.isEmpty) {
      _showSnackBar('Please enter your full name.');
      return;
    }

    if (email.isEmpty || !_isValidEmail(email)) {
      _showSnackBar('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter a password.');
      return;
    }

    if (!_isStrongPassword(password)) {
      _showSnackBar(
        'Password must be ≥ 8 characters and include uppercase, lowercase, number, and special character (!@#\$%^&*).',
      );
      return;
    }

    if (confirm.isEmpty || confirm != password) {
      _showSnackBar('Passwords do not match.');
      return;
    }

    // ── Firebase registration via AuthProvider ──
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.registerWithEmail(email, password, name);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showSnackBar('Welcome to LUXE! Account created successfully.', backgroundColor: Colors.green);
      // Small delay so the snackbar is visible before navigation
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      final errorMsg = authProvider.errorMessage ?? 'Registration failed. Please try again.';
      _showSnackBar(errorMsg);
    }
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _googleSignIn(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text("Choose an account",
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 16),
          ListTile(
            leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1), child: const Text("SV")),
            title: Text("Sajidha Vin", style: TextStyle(color: theme.colorScheme.primary)),
            subtitle: Text("sajidha.vin@gmail.com",
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text("Add another account",
                style: TextStyle(color: theme.colorScheme.primary)),
            onTap: () => Navigator.pop(context),
          ),
        ]),
      ),
    );
  }
}
