import 'package:flutter/material.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key, required this.name, required this.email});

  final String name;
  final String email;

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  String _barangay = SeedData.currentUser.barangay;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return GlassScaffold(
      title: 'Edit Profile',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account Details', style: TextStyle(color: glass.textOnGlass, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full name', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _emailController, enabled: false, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _mobileController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile number', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _barangay,
                  decoration: const InputDecoration(labelText: 'Barangay', border: OutlineInputBorder()),
                  items: SeedData.barangays.map((barangay) => DropdownMenuItem(value: barangay, child: Text(barangay))).toList(),
                  onChanged: (value) => setState(() => _barangay = value ?? _barangay),
                ),
                const SizedBox(height: 12),
                TextField(controller: _addressController, minLines: 2, maxLines: 3, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassButton(
            label: 'Save Profile',
            icon: Icons.save_outlined,
            expanded: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile saved locally. API sync will replace this fallback.')),
              );
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
}
