import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../domain/entities/citizen_report_category.dart';
import '../../domain/usecases/citizen_report_params.dart';
import '../providers/citizen_report_controller.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  CitizenReportCategory _category = CitizenReportCategory.roadDamage;
  String _barangay = SeedData.currentUser.barangay;
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue.')),
      );
      return;
    }

    final location = _locationController.text.trim();
    setState(() => _submitting = true);

    final ok = await ref
        .read(citizenReportControllerProvider.notifier)
        .submit(
          CreateCitizenReportParams(
            category: _category.apiValue,
            description: description,
            barangay: _barangay,
            locationAddress: location.isEmpty ? null : location,
          ),
        );

    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Report submitted.' : 'Could not submit report. Please try again.',
        ),
      ),
    );
    if (ok) Navigator.of(context).maybePop();
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
                DropdownButtonFormField<CitizenReportCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: CitizenReportCategory.values
                      .map((category) => DropdownMenuItem(value: category, child: Text(category.apiValue)))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value ?? _category),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _barangay,
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
            loadingLabel: 'Submitting report...',
            isLoading: _submitting,
            icon: Icons.send_outlined,
            expanded: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
