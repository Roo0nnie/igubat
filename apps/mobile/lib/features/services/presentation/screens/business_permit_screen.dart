import 'package:flutter/material.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import 'request_details_screen.dart';

class BusinessPermitScreen extends StatelessWidget {
  const BusinessPermitScreen({super.key});

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
    final requests = SeedData.activeRequests.where((r) => r.serviceType == 'Business Permit').toList();
    final glass = glassThemeOf(context);

    return GlassScaffold(
      title: 'Business Permits',
      bottomPadding: false,
      useShellBackground: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: GlassCard(
              intensity: GlassIntensity.prominent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply for a new permit or renew an existing one.',
                    style: TextStyle(color: glass.textOnGlassMuted),
                  ),
                  const SizedBox(height: 16),
                  GlassButton(
                    label: 'Apply for Business Permit',
                    expanded: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'My Applications',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: glass.textOnGlass),
                ),
                const SizedBox(height: 16),
                if (requests.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('No active applications found.', style: TextStyle(color: glass.textOnGlassMuted)),
                    ),
                  )
                else
                  ...requests.map((request) => _buildApplicationCard(context, request, glass)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, ServiceRequest request, GlassTheme glass) {
    final statusColor = _statusColor(request.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () {
          Navigator.push(
            context,
            GlassPageRoute(page: RequestDetailsScreen(request: request)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.id,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: glass.textOnGlass),
                ),
                GlassBadge(label: request.status, color: statusColor, compact: true),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.business, size: 16, color: glass.textOnGlassMuted),
                const SizedBox(width: 8),
                Text('Applicant: ${request.citizenName}', style: TextStyle(color: glass.textOnGlassMuted, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: glass.textOnGlassMuted),
                const SizedBox(width: 8),
                Text(
                  'Submitted: ${request.dateSubmitted.substring(0, 10)}',
                  style: TextStyle(color: glass.textOnGlassMuted, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: glass.border),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'View Details',
                style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
