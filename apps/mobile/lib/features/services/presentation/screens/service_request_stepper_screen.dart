import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mock/seed_data.dart' show Service;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/app_stepper.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../service_requests/domain/entities/service_request.dart';
import '../../../service_requests/domain/usecases/service_request_params.dart';
import '../../../service_requests/presentation/providers/service_requests_provider.dart';

class ServiceRequestStepperScreen extends ConsumerStatefulWidget {
  const ServiceRequestStepperScreen({
    super.key,
    required this.service,
    this.serviceTypeId,
  });

  final Service service;

  /// The live `ServiceType.id` this request targets. When null (e.g. from a
  /// seed-only entry point) submission is disabled and the receipt stays an
  /// offline sample.
  final int? serviceTypeId;

  @override
  ConsumerState<ServiceRequestStepperScreen> createState() =>
      _ServiceRequestStepperScreenState();
}

class _ServiceRequestStepperScreenState
    extends ConsumerState<ServiceRequestStepperScreen> {
  int _step = 0;
  bool _submitting = false;
  ServiceRequest? _createdRequest;
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

  /// Fallback tracking number shown only when no live request was created.
  String get _sampleTrackingNumber {
    final prefix = widget.service.title
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .join()
        .toUpperCase();
    return '${prefix.isEmpty ? 'SR' : prefix}-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
  }

  DateTime? _parsePreferredDate() {
    final raw = _dateController.text.trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  /// Submits the request to the backend and advances to the receipt step on
  /// success. Returns true when the caller may advance the stepper.
  Future<bool> _submitRequest() async {
    final typeId = widget.serviceTypeId;
    if (typeId == null) {
      // No live service id available — keep the existing offline sample flow.
      return true;
    }

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showError('Please describe your request before continuing.');
      return false;
    }

    setState(() => _submitting = true);
    final created = await ref
        .read(serviceRequestsControllerProvider.notifier)
        .submit(
          CreateServiceRequestParams(
            serviceTypeId: typeId,
            description: description,
            preferredDate: _parsePreferredDate(),
          ),
        );
    if (!mounted) return false;
    setState(() => _submitting = false);

    if (created == null) {
      _showError('We could not submit your request. Please try again.');
      return false;
    }
    setState(() => _createdRequest = created);
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFB91C1C)),
    );
  }

  Future<void> _onPrimaryPressed(List<String> steps) async {
    final lastIndex = steps.length - 1;

    // Final ("Done") step just closes.
    if (_step == lastIndex) {
      Navigator.of(context).maybePop();
      return;
    }

    // Transition from Upload -> Receipt is where we submit to the backend.
    if (_step == lastIndex - 1) {
      final ok = await _submitRequest();
      if (!ok) return;
    }

    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final steps = ['Review', 'Details', 'Upload', 'Receipt'];
    final lastIndex = steps.length - 1;

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
              if (_step > 0 && _step != lastIndex)
                Expanded(
                  child: GlassButton(
                    label: 'Back',
                    variant: GlassButtonVariant.outline,
                    onPressed: _submitting ? null : () => setState(() => _step--),
                  ),
                ),
              if (_step > 0 && _step != lastIndex) const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  label: _submitting
                      ? 'Submitting...'
                      : (_step == lastIndex ? 'Done' : 'Continue'),
                  icon: _step == lastIndex ? Icons.check : Icons.arrow_forward,
                  onPressed: _submitting ? null : () => _onPrimaryPressed(steps),
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
                decoration: const InputDecoration(
                  labelText: 'Preferred date (optional)',
                  hintText: 'YYYY-MM-DD',
                  border: OutlineInputBorder(),
                ),
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
        final created = _createdRequest;
        final trackingNumber = created?.trackingNumber ?? _sampleTrackingNumber;
        final isLive = created != null;
        return GlassCard(
          intensity: GlassIntensity.prominent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isLive ? Icons.check_circle : Icons.receipt_long,
                color: AppTheme.secondaryColor,
                size: 44,
              ),
              const SizedBox(height: 16),
              Text(
                isLive ? 'Request Submitted' : 'Request Prepared',
                style: TextStyle(color: glass.textOnGlass, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(trackingNumber, style: TextStyle(color: glass.textOnGlassMuted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              Text(
                isLive
                    ? 'Your request has been received. Track its status anytime under My Requests using the tracking number above.'
                    : 'This receipt is an offline sample. Once API submission is enabled for this service, this screen will show the backend tracking number and timeline.',
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
