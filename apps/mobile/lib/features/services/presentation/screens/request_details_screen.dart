import 'package:flutter/material.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class RequestDetailsScreen extends StatelessWidget {
  const RequestDetailsScreen({super.key, required this.request});

  final ServiceRequest request;

  Color _statusColor(String status) {
    switch (status) {
      case 'Approved':
        return AppTheme.primaryColor;
      case 'Pending':
        return const Color(0xFFD97706);
      case 'Rejected':
        return const Color(0xFFB91C1C);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final statusColor = _statusColor(request.status);

    return GlassScaffold(
      title: 'Request Details',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GlassCard(
            intensity: GlassIntensity.prominent,
            child: Column(
              children: [
                Text(
                  request.id,
                  style: TextStyle(fontSize: 14, color: glass.textOnGlassMuted, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  request.serviceType,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: glass.textOnGlass),
                ),
                const SizedBox(height: 16),
                GlassBadge(label: request.status.toUpperCase(), color: statusColor),
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
                _buildStep('1', 'Submitted', true, true),
                _buildStep('2', 'In Review', request.status != 'Pending', request.status != 'Pending'),
                _buildStep('3', 'Processing', request.status == 'Approved', request.status == 'Approved'),
                _buildStep('4', 'Completed', request.status == 'Approved', false),
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
                _infoRow('Applicant Name', request.citizenName, glass),
                const SizedBox(height: 12),
                _infoRow('Barangay', request.barangay, glass),
                const SizedBox(height: 12),
                _infoRow('Date Submitted', request.dateSubmitted.substring(0, 10), glass),
                const SizedBox(height: 12),
                _infoRow('Remarks', request.remarks, glass),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uploaded Documents', style: TextStyle(fontWeight: FontWeight.bold, color: glass.textOnGlass)),
                const SizedBox(height: 16),
                _docItem('Valid ID.pdf', glass),
                const SizedBox(height: 8),
                _docItem('Barangay_Clearance.pdf', glass),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String step, String title, bool isActive, bool showLine) {
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
                    : Text(step, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.primaryColor : Colors.grey,
            ),
          ),
        ),
      ],
    );
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
