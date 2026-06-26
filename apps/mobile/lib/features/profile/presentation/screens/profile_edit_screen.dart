import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../domain/usecases/update_profile.dart';
import '../providers/profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key, required this.name, required this.email});

  final String name;
  final String email;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final _nameController = TextEditingController(text: widget.name);
  late final _emailController = TextEditingController(text: widget.email);
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  String? _barangay;
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Populate mobile/barangay/address from the loaded profile, once.
  void _seedFrom(User user) {
    if (_seeded) return;
    _seeded = true;
    if (_nameController.text.isEmpty) _nameController.text = user.name;
    _mobileController.text = user.mobileNumber ?? '';
    _addressController.text = user.address ?? '';
    if (user.barangay != null && user.barangay!.isNotEmpty) {
      _barangay = user.barangay;
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await ref.read(profileControllerProvider.notifier).saveProfile(
      UpdateProfileParams(
        name: _nameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        barangay: _barangay,
        address: _addressController.text.trim(),
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Profile updated.' : 'Could not update profile.'),
      ),
    );
    if (ok) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    ref.watch(profileControllerProvider).whenData(_seedFrom);

    final barangayItems = <String>{
      ...SeedData.barangays,
      if (_barangay != null && _barangay!.isNotEmpty) _barangay!,
    }.toList();

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
                Text(
                  'Account Details',
                  style: TextStyle(
                    color: glass.textOnGlass,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _barangay,
                  decoration: const InputDecoration(
                    labelText: 'Barangay',
                    border: OutlineInputBorder(),
                  ),
                  items: barangayItems
                      .map(
                        (barangay) => DropdownMenuItem(
                          value: barangay,
                          child: Text(barangay),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _barangay = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _addressController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassButton(
            label: _saving ? 'Saving...' : 'Save Profile',
            icon: Icons.save_outlined,
            expanded: true,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
