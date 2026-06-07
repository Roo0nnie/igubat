import 'package:flutter/material.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/app_stepper.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class ServiceRequestStepperScreen extends StatefulWidget {
  const ServiceRequestStepperScreen({super.key, required this.service});

  final Service service;

  @override
  State<ServiceRequestStepperScreen> createState() => _ServiceRequestStepperScreenState();
}

class _ServiceRequestStepperScreenState extends State<ServiceRequestStepperScreen> {
  int _step = 0;
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  List<String> get _requirements {
    final title = widget.service.title.toLowerCase();
    if (title.contains('business')) {
      return ['Valid ID', 'Barangay clearance', 'DTI/SEC registration', 'Lease or ownership proof'];
    }
    if (title.contains('certificate')) {
      return ['Valid ID', 'Proof of residency', 'Purpose of request'];
    }
    if (title.contains('health')) {
      return ['Valid ID', 'Medical abstract or prescription', 'Contact number'];
    }
    return ['Valid ID', 'Request details', 'Supporting document if applicable'];
  }

  String get _trackingNumber {
    final prefix = widget.service.title
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    return '${prefix.isEmpty ? 'SR' : prefix}-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final steps = ['Review', 'Details', 'Upload', 'Receipt'];

    return GlassScaffold(
      title: widget.service.title,
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GlassCard(
            child: AppStepper(steps: steps, currentStep: _step, activeColor: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          _stepContent(glass),
          const SizedBox(height: 16),
          Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: GlassButton(
                    label: 'Back',
                    variant: GlassButtonVariant.outline,
                    onPressed: () => setState(() => _step--),
                  ),
                ),
              if (_step > 0) const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  label: _step == steps.length - 1 ? 'Done' : 'Continue',
                  icon: _step == steps.length - 1 ? Icons.check : Icons.arrow_forward,
                  onPressed: () {
                    if (_step == steps.length - 1) {
                      Navigator.of(context).maybePop();
                      return;
                    }
                    setState(() => _step++);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepContent(GlassTheme glass) {
    switch (_step) {
      case 0:
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Requirements', style: TextStyle(color: glass.textOnGlass, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._requirements.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppTheme.secondaryColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text(item, style: TextStyle(color: glass.textOnGlass))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Estimated processing: ${widget.service.processingDays} working days', style: TextStyle(color: glass.textOnGlassMuted)),
            ],
          ),
        );
      case 1:
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request Details', style: TextStyle(color: glass.textOnGlass, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Purpose or details', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Preferred date (optional)', border: OutlineInputBorder()),
              ),
            ],
          ),
        );
      case 2:
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Attachments', style: TextStyle(color: glass.textOnGlass, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _uploadStub('Valid_ID.pdf', glass),
              const SizedBox(height: 8),
              _uploadStub('Supporting_Document.pdf', glass),
              const SizedBox(height: 12),
              Text('Local upload stubs are shown until real storage credentials are configured.', style: TextStyle(color: glass.textOnGlassMuted, fontSize: 12)),
            ],
          ),
        );
      default:
        return GlassCard(
          intensity: GlassIntensity.prominent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.receipt_long, color: AppTheme.secondaryColor, size: 44),
              const SizedBox(height: 16),
              Text('Request Prepared', style: TextStyle(color: glass.textOnGlass, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_trackingNumber, style: TextStyle(color: glass.textOnGlassMuted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Text(
                'This receipt is an offline sample. Once API submission is enabled on mobile, this screen will show the backend tracking number and timeline.',
                style: TextStyle(color: glass.textOnGlassMuted, height: 1.5),
              ),
            ],
          ),
        );
    }
  }

  Widget _uploadStub(String fileName, GlassTheme glass) {
    return GlassSurface(
      intensity: GlassIntensity.subtle,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [],
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.attach_file, color: AppTheme.secondaryColor),
          const SizedBox(width: 10),
          Expanded(child: Text(fileName, style: TextStyle(color: glass.textOnGlass))),
          Icon(Icons.check_circle, color: AppTheme.secondaryColor, size: 18),
        ],
      ),
    );
  }
}
