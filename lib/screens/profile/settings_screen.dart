import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';
import '../../utils/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;  
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NOTIFICATIONS SECTION
            Text(
              "Notifications",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text("Push Notifications", style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.primary)),
                    subtitle: Text("Receive order updates", style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Color(0xFF6C63FF), size: 20),
                    ),
                    value: _notificationsEnabled,
                    activeColor: AppColors.secondaryColor,
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  SwitchListTile(
                    title: Text("Email Notifications", style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.primary)),
                    subtitle: Text("Receive emails about orders", style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.email_outlined, color: Color(0xFF4CAF50), size: 20),
                    ),
                    value: _emailNotifications,
                    activeColor: AppColors.secondaryColor,
                    onChanged: (value) => setState(() => _emailNotifications = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // APPEARANCE SECTION
            Text(
              "Appearance",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      "Dark Mode",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    subtitle: Text(
                      isDarkModeNotifier.value ? "Dark theme is ON" : "Switch to dark theme",
                      style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    secondary: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDarkModeNotifier.value ? Icons.dark_mode : Icons.dark_mode_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    value: isDarkModeNotifier.value,
                    activeColor: AppColors.secondaryColor,
                    onChanged: (value) {
                      ThemeManager().toggleDarkMode(value);
                      setState(() {});
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5A623).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.language, color: Color(0xFFF5A623), size: 20),
                    ),
                    title: Text("Language", style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.primary)),
                    subtitle: Text(_language, style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                    trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            "Select Language",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: ['English', 'Tamil', 'Sinhala', 'French', 'Arabic'].map((lang) {
                              return RadioListTile(
                                title: Text(lang, style: GoogleFonts.poppins(color: theme.colorScheme.primary)),
                                value: lang,
                                groupValue: _language,
                                activeColor: AppColors.secondaryColor,
                                onChanged: (val) {
                                  setState(() => _language = val.toString());
                                  Navigator.pop(context);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ACCOUNT SECTION
            Text(
              "Account",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF2196F3), size: 20),
                    ),
                    title: Text("Privacy Policy", style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.primary)),
                    trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text("Opening privacy policy"), backgroundColor: theme.colorScheme.primary),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9E9E9E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.description_outlined, color: Color(0xFF9E9E9E), size: 20),
                    ),
                    title: Text("Terms of Service", style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.primary)),
                    trailing: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: const Text("Opening terms"), backgroundColor: theme.colorScheme.primary),
                      );
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16, height: 1),
                  ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE94560).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline, color: Color(0xFFE94560), size: 20),
                    ),
                    title: Text("Delete Account", style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFFE94560))),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            "Delete Account",
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary),
                          ),
                          content: Text(
                            "This action cannot be undone.",
                            style: GoogleFonts.poppins(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
                              child: const Text("Delete", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // APP INFO
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("App Version", style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                      Text("1.0.0", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Build Number", style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                      Text("2025.10.01", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: theme.colorScheme.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
