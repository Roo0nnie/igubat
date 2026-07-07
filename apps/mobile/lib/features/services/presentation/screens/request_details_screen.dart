import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../service_requests/domain/entities/request_status_change.dart';
import '../../../service_requests/domain/entities/service_request.dart';
import '../../../service_requests/domain/entities/service_request_status.dart';
import '../../../service_requests/presentation/providers/service_requests_provider.dart';

/// Detail view for a single service request, loaded live by [requestId] from
/// `/me/requests/:id` (which includes attachments + status history).
class RequestDetailsScreen extends ConsumerWidget {
  const RequestDetailsScreen({super.key, required this.requestId});

  final int requestId;

  Color _statusColor(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.approved:
      case ServiceRequestStatus.completed:
        return AppTheme.primaryColor;
      case ServiceRequestStatus.forPickup:
        return const Color(0xFF2563EB);
      case ServiceRequestStatus.pending:
      case ServiceRequestStatus.inReview:
        return const Color(0xFFD97706);
      case ServiceRequestStatus.rejected:
        return const Color(0xFFB91C1C);
      case ServiceRequestStatus.unknown:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);
    final detailAsync = ref.watch(serviceRequestDetailProvider(requestId));

    return GlassScaffold(
      title: 'Request Details',
      bottomPadding: false,
      useShellBackground: false,
      onRefresh: () async {
        ref.invalidate(serviceRequestDetailProvider(requestId));
        await ref.read(serviceRequestDetailProvider(requestId).future);
      },
      body: detailAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              'Could not load this request. Pull down to retry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: glass.textOnGlassMuted),
            ),
          ),
        ),
        data: (request) => _buildContent(context, glass, request),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    GlassTheme glass,
    ServiceRequest request,
  ) {
    final statusColor = _statusColor(request.status);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        GlassCard(
          intensity: GlassIntensity.prominent,
          child: Column(
            children: [
              Text(
                request.trackingNumber,
                style: TextStyle(fontSize: 14, color: glass.textOnGlassMuted, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                request.serviceType,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: glass.textOnGlass),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GlassBadge(label: request.status.label.toUpperCase(), color: statusColor),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Application Progress', style: TextStyle(fontWeight: FontWeight.bold, color: glass.textOnGlass)),
              const SizedBox(height: 20),
              if (request.history.isNotEmpty)
                ..._buildHistoryTimeline(request.history, glass)
              else
                ..._buildDerivedTimeline(request.status),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request Information', style: TextStyle(fontWeight: FontWeight.bold, color: glass.textOnGlass)),
              const SizedBox(height: 16),
              _infoRow('Tracking Number', request.trackingNumber, glass),
              const SizedBox(height: 12),
              _infoRow('Service', request.serviceType, glass),
              if (request.barangay != null) ...[
                const SizedBox(height: 12),
                _infoRow('Barangay', request.barangay!, glass),
              ],
              const SizedBox(height: 12),
              _infoRow('Date Submitted', _formatDate(request.createdAt), glass),
              if (request.preferredDate != null) ...[
                const SizedBox(height: 12),
                _infoRow('Preferred Date', _formatDate(request.preferredDate), glass),
              ],
              const SizedBox(height: 12),
              _infoRow(
                'Description',
                request.description.isEmpty ? '—' : request.description,
                glass,
              ),
              if (request.publicRemarks != null && request.publicRemarks!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _infoRow('Remarks', request.publicRemarks!, glass),
              ],
            ],
          ),
        ),
        if (request.attachments.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uploaded Documents', style: TextStyle(fontWeight: FontWeight.bold, color: glass.textOnGlass)),
                const SizedBox(height: 16),
                for (final a in request.attachments) ...[
                  _docItem(a.fileName, glass),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Renders the real backend status history when available.
  List<Widget> _buildHistoryTimeline(
    List<RequestStatusChange> history,
    GlassTheme glass,
  ) {
    return [
      for (var i = 0; i < history.length; i++)
        _timelineRow(
          label: history[i].status.label,
          subtitle: history[i].remarks,
          isActive: true,
          showLine: i != history.length - 1,
        ),
    ];
  }

  /// Falls back to a derived four-step timeline when the backend returns no
  /// explicit history (e.g. list-derived navigation).
  List<Widget> _buildDerivedTimeline(ServiceRequestStatus status) {
    final reached = _reachedSteps(status);
    const labels = ['Submitted', 'In Review', 'Processing', 'Completed'];
    return [
      for (var i = 0; i < labels.length; i++)
        _timelineRow(
          label: labels[i],
          isActive: reached[i],
          showLine: i != labels.length - 1,
        ),
    ];
  }

  /// Maps a status to which of the four derived steps have been reached.
  List<bool> _reachedSteps(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return const [true, false, false, false];
      case ServiceRequestStatus.inReview:
        return const [true, true, false, false];
      case ServiceRequestStatus.approved:
      case ServiceRequestStatus.forPickup:
        return const [true, true, true, false];
      case ServiceRequestStatus.completed:
        return const [true, true, true, true];
      case ServiceRequestStatus.rejected:
        return const [true, true, false, false];
      case ServiceRequestStatus.unknown:
        return const [true, false, false, false];
    }
  }

  Widget _timelineRow({
    required String label,
    String? subtitle,
    required bool isActive,
    required bool showLine,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.secondaryColor : Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isActive
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : const Icon(Icons.circle, color: Colors.white, size: 8),
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 28,
                color: isActive ? AppTheme.secondaryColor : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? AppTheme.primaryColor : Colors.grey,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, bottom: 4),
                    child: Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final local = date.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Widget _infoRow(String label, String value, GlassTheme glass) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: TextStyle(color: glass.textOnGlassMuted, fontSize: 13)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: glass.textOnGlass, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _docItem(String filename, GlassTheme glass) {
    return GlassSurface(
      intensity: GlassIntensity.subtle,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [],
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Color(0xFFB91C1C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(filename, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: glass.textOnGlass)),
          ),
          Icon(Icons.remove_red_eye, color: AppTheme.secondaryColor, size: 20),
        ],
      ),
    );
  }
}
