import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import 'request_details_screen.dart';

/// Business Permit service detail (TOR Module 5).
///
/// Browsing the service is public, but the apply action and the citizen's
/// own application history are authenticated surfaces (Story 5.1): a guest who
/// tries to submit is sent to sign-in, and the "My Applications" list — which
/// exposes account-specific request details and citizen names — is hidden
/// until the user authenticates.
class BusinessPermitScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final user = ref.watch(currentUserProvider);
    // Scope the history to the signed-in citizen's own submissions: this is a
    // citizen-facing surface (Module 5), so other applicants' names and
    // statuses must never be rendered here. Guests resolve to no user and see
    // the sign-in prompt instead of any list.
    final requests = SeedData.activeRequests
        .where((r) => r.serviceType == 'Business Permit' && r.citizenName == user?.name)
        .toList();
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
                    label: isAuthenticated
                        ? 'Apply for Business Permit'
                        : 'Sign In to Apply',
                    expanded: true,
                    onPressed: () {
                      // Submitting a request is authenticated-only (Story 5.1).
                      // Guests are routed to sign-in; pushing (rather than
                      // replacing) keeps this service on the stack so they can
                      // return to it after authenticating.
                      if (!isAuthenticated) {
                        context.push(
                          AppRoutes.loginWithRedirect(AppRoutes.redirectBusinessPermit),
                        );
                        return;
                      }
                      // Authenticated submission flow.
                    },
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
                if (!isAuthenticated)
                  _buildSignInPrompt(context, glass)
                else if (requests.isEmpty)
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

  /// Shown in place of the application history when the viewer is a guest, so
  /// account-specific request details and citizen names are never exposed on
  /// this now-public surface (Story 5.1).
  Widget _buildSignInPrompt(BuildContext context, GlassTheme glass) {
    return GlassCard(
      child: Column(
        children: [
          Icon(Icons.lock_outline, color: glass.textOnGlassMuted, size: 32),
          const SizedBox(height: 12),
          Text(
            'Sign in to view your applications',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: glass.textOnGlass,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your submitted requests and their status are private to your account.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: glass.textOnGlassMuted),
          ),
          const SizedBox(height: 16),
          GlassButton(
            label: 'Sign In',
            expanded: true,
            onPressed: () => context.push(
              AppRoutes.loginWithRedirect(AppRoutes.redirectBusinessPermit),
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
