import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_colors.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<dynamic> _addresses = [
    {'name': 'Home', 'address': '123 Luxury Lane, Beverly Hills', 'city': 'Los Angeles', 'postal': '90210', 'phone': '+1 234 567 8900', 'isDefault': true, 'icon': Icons.home_outlined},
    {'name': 'Office', 'address': '456 Fashion Ave, Suite 100', 'city': 'New York', 'postal': '10001', 'phone': '+1 234 567 8901', 'isDefault': false, 'icon': Icons.business_outlined},
  ];

  void _showAddAddressSheet(ThemeData theme) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text("Add New Address", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary)),
              const SizedBox(height: 24),
              _buildInput("Address Name (Home/Office)", theme),
              const SizedBox(height: 12),
              _buildInput("Street Address", theme),
              const SizedBox(height: 12),
              _buildInput("City", theme),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _buildInput("Postal Code", theme)),
                const SizedBox(width: 12),
                Expanded(child: _buildInput("Phone", theme)),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    setState(() => _addresses.add({'name': 'New Address', 'address': '789 Custom Street Blvd', 'city': 'San Francisco', 'postal': '94105', 'phone': '+1 987 654 3210', 'isDefault': false, 'icon': Icons.location_on_outlined}));
                    Navigator.pop(context);
                  },
                  child: Text("Save Address", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String label, ThemeData theme) {
    return TextFormField(
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label, labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.dividerColor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary), onPressed: () => Navigator.pop(context)),
        title: Text("Saved Addresses", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary)),
        centerTitle: true,
        actions: [IconButton(icon: Icon(Icons.add, color: theme.colorScheme.primary), onPressed: () => _showAddAddressSheet(theme))],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
                final bool isDefault = address['isDefault'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(address['icon'], color: theme.colorScheme.primary, size: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(address['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: theme.colorScheme.primary)),
                              if (isDefault) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.secondaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text("Default", style: GoogleFonts.poppins(fontSize: 11, color: AppColors.secondaryColor))),
                            ]),
                            const SizedBox(height: 4),
                            Text(address['address'], style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            Text("${address['city']}, ${address['postal']}", style: GoogleFonts.poppins(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                            Text(address['phone'], style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                            const SizedBox(height: 12),
                            Row(children: [
                              if (!isDefault) ...[
                                SizedBox(height: 36, child: OutlinedButton(style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => setState(() { for (var a in _addresses) a['isDefault'] = false; address['isDefault'] = true; }), child: Text("Set Default", style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.primary)))),
                                const SizedBox(width: 8),
                              ],
                              SizedBox(height: 36, child: OutlinedButton(style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.2)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () {}, child: Text("Edit", style: GoogleFonts.poppins(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))))),
                              const SizedBox(width: 8),
                              SizedBox(height: 36, child: OutlinedButton(style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => setState(() => _addresses.removeAt(index)), child: Text("Delete", style: GoogleFonts.poppins(fontSize: 12, color: Colors.red)))),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => _showAddAddressSheet(theme),
                child: Text("Add New Address", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
