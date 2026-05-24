import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../cart/cart_screen.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/user_session.dart';
import '../../utils/cart_manager.dart';
import '../../utils/wishlist_manager.dart';
import '../../utils/theme_manager.dart';
import 'wishlist_screen.dart';
import 'settings_screen.dart';
import 'notifications_screen.dart';
import 'addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+1 234 567 8900');

  @override
  void initState() {
    super.initState();
    _nameController.text = UserSession().userName.isNotEmpty ? UserSession().userName : 'Eleanor Sterling';
    _emailController.text = UserSession().userEmail.isNotEmpty ? UserSession().userEmail : 'e.sterling@luxe.com';
  }

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 80);
      if (image != null) setState(() => _selectedImage = image);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not pick image"), backgroundColor: Colors.red));
    }
  }

  void _showLogoutDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Logout", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary)),
        content: Text("Are you sure you want to logout?", style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor),
            onPressed: () async {
              try {
                await AuthRepository().signOut();
              } catch (_) {}
              UserSession().logout();
              CartManager().clear();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePassword(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text("Change Password", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary)),
            const SizedBox(height: 24),
            _buildDialogField("Current Password", true, theme),
            const SizedBox(height: 12),
            _buildDialogField("New Password", true, theme),
            const SizedBox(height: 12),
            _buildDialogField("Confirm Password", true, theme),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(context),
                child: Text("Update Password", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(String label, bool obscure, ThemeData theme) {
    return TextFormField(
      obscureText: obscure,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        prefixIcon: Icon(Icons.lock_outline, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        filled: true, fillColor: isDarkModeNotifier.value ? const Color(0xFF2D2D2D) : Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor)),
      ),
    );
  }

  Widget _buildStat(String value, String label, ThemeData theme, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: color ?? theme.colorScheme.primary)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, IconData icon, ThemeData theme) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        filled: true, fillColor: isDarkModeNotifier.value ? const Color(0xFF2D2D2D) : Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          else if (index == 1) Navigator.pushNamed(context, '/search');
          else if (index == 2) Navigator.push(context, MaterialPageRoute(settings: const RouteSettings(name: '/cart'), builder: (context) => const CartScreen()));
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32))),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.white70), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()))),
                  ]),
                  Stack(alignment: Alignment.center, children: [
                    CircleAvatar(radius: 50, backgroundColor: Colors.white24, backgroundImage: _selectedImage != null ? (kIsWeb ? NetworkImage(_selectedImage!.path) : FileImage(File(_selectedImage!.path))) as ImageProvider : const AssetImage('assets/images/user/user_avatar.png')),
                    Positioned(bottom: 0, right: 0, child: GestureDetector(onTap: _pickImage, child: Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.secondaryColor, shape: BoxShape.circle), child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14)))),
                  ]),
                  const SizedBox(height: 16),
                  Text(_nameController.text, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(_emailController.text, style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_isEditing ? Icons.check : Icons.edit_outlined, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(_isEditing ? "Save Profile" : "Edit Profile", style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
                    ]),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)]),
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat("12", "Orders", theme),
                  Container(height: 40, width: 1, color: theme.dividerColor),
                  _buildStat("\$3,240", "Spent", theme, color: AppColors.secondaryColor),
                  Container(height: 40, width: 1, color: theme.dividerColor),
                  _buildStat("${WishlistManager().itemCount}", "Wishlist", theme),
                ],
              ),
            ),

            const SizedBox(height: 20),
            if (_isEditing) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Personal Information", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.primary)),
                    const SizedBox(height: 16),
                    _buildEditField("Full Name", _nameController, Icons.person_outlined, theme),
                    const SizedBox(height: 12),
                    _buildEditField("Email Address", _emailController, Icons.email_outlined, theme),
                    const SizedBox(height: 12),
                    _buildEditField("Phone Number", _phoneController, Icons.phone_outlined, theme),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
              child: Column(
                children: [
                  _buildMenuItem(Icons.shopping_bag_outlined, "My Orders", const Color(0xFF6C63FF), theme, () => Navigator.pushNamed(context, '/order-history')),
                  _buildDivider(theme),
                  _buildMenuItem(Icons.favorite_outline, "Wishlist", const Color(0xFFE94560), theme, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()))),
                  _buildDivider(theme),
                  _buildMenuItem(Icons.location_on_outlined, "Saved Addresses", const Color(0xFF4CAF50), theme, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressesScreen()))),
                  _buildDivider(theme),
                  _buildMenuItem(Icons.lock_outlined, "Change Password", const Color(0xFF2196F3), theme, () => _showChangePassword(context, theme)),
                  _buildDivider(theme),
                  _buildMenuItem(Icons.logout, "Logout", const Color(0xFFF44336), theme, () => _showLogoutDialog(context, theme)),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color, ThemeData theme, VoidCallback onTap) {
    return ListTile(
      leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.primary)),
      trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4)),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeData theme) => Divider(indent: 16, endIndent: 16, color: theme.dividerColor, height: 1);
}
