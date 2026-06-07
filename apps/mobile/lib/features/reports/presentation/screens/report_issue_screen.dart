import 'package:flutter/material.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  String _category = 'Road Concern';
  String _barangay = SeedData.currentUser.barangay;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return GlassScaffold(
      title: 'Report an Issue',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Community Issue Details', style: TextStyle(color: glass.textOnGlass, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: const ['Road Concern', 'Waste Management', 'Streetlight', 'Drainage', 'Public Safety']
                      .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _barangay,
                  decoration: const InputDecoration(labelText: 'Barangay', border: OutlineInputBorder()),
                  items: SeedData.barangays.map((barangay) => DropdownMenuItem(value: barangay, child: Text(barangay))).toList(),
                  onChanged: (value) => setState(() => _barangay = value ?? _barangay),
                ),
                const SizedBox(height: 12),
                TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Location address', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _descriptionController, minLines: 5, maxLines: 7, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Attach photo placeholder'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassButton(
            label: 'Submit Report',
            icon: Icons.send_outlined,
            expanded: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Issue report prepared locally. API sync will replace this fallback.')),
              );
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
}
