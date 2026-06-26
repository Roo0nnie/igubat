import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../core/widgets/igubat_logo.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../../../shared/widgets/glass/glass_background.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../service_requests/domain/entities/service_request.dart';
import '../../../service_requests/domain/entities/service_request_status.dart';
import '../../../service_requests/presentation/providers/service_requests_provider.dart';
import '../../../services/presentation/screens/request_details_screen.dart';

/// The citizen's "My Requests" list, backed by live `/me/requests` data.
class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

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

  IconData _serviceIcon(String serviceType) {
    final t = serviceType.toLowerCase();
    if (t.contains('business') || t.contains('permit')) {
      return Icons.business_center_outlined;
    }
    if (t.contains('certificate') || t.contains('residency')) {
      return Icons.workspace_premium_outlined;
    }
    if (t.contains('health') || t.contains('medical')) {
      return Icons.favorite_outline;
    }
    return Icons.description_outlined;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final local = date.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final glass = glassThemeOf(context);
    final requestsAsync = ref.watch(serviceRequestsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const IgubatLogo(height: 24, darkText: false),
        centerTitle: true,
      ),
      body: GlassBackground(
        child: RefreshIndicator(
          color: GlassTokens.secondaryGreen,
          backgroundColor: Colors.white,
          onRefresh: () =>
              ref.read(serviceRequestsControllerProvider.notifier).reload(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: GlassSurface(
                  intensity: GlassIntensity.prominent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(GlassTokens.radiusGlassLg),
                    bottomRight: Radius.circular(GlassTokens.radiusGlassLg),
                  ),
                  tint: GlassTokens.primaryGreen.withValues(alpha: 0.85),
                  padding: const EdgeInsets.fromLTRB(20, 100, 20, 32),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.secondaryColor,
                        backgroundImage: user?.image != null ? NetworkImage(user!.image!) : null,
                        child: user?.image == null
                            ? Text(
                                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                                style: const TextStyle(color: Colors.white, fontSize: 24),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Requests',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Track your submitted LGU service requests',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: requestsAsync.when(
                  loading: () => const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  error: (_, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 64),
                      child: Center(
                        child: Text(
                          'Could not load your requests.\nPull down to retry.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: glass.textOnGlassMuted),
                        ),
                      ),
                    ),
                  ),
                  data: (requests) {
                    if (requests.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _emptyState(glass),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                'Active Requests',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: glass.textOnGlass,
                                    ),
                              ),
                            );
                          }
                          final request = requests[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _requestCard(context, request, glass),
                          );
                        },
                        childCount: requests.length + 1,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(GlassTheme glass) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: glass.textOnGlassMuted),
          const SizedBox(height: 16),
          Text(
            'No requests yet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: glass.textOnGlass,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Submit a service request from the Services tab and it will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: glass.textOnGlassMuted),
          ),
        ],
      ),
    );
  }

  Widget _requestCard(
    BuildContext context,
    ServiceRequest request,
    GlassTheme glass,
  ) {
    final statusColor = _statusColor(request.status);

    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          GlassPageRoute(page: RequestDetailsScreen(requestId: request.id)),
        );
      },
      child: Row(
        children: [
          GlassSurface(
            intensity: GlassIntensity.subtle,
            borderRadius: BorderRadius.circular(12),
            tint: AppTheme.secondaryColor.withValues(alpha: 0.12),
            boxShadow: const [],
            padding: const EdgeInsets.all(10),
            child: Icon(_serviceIcon(request.serviceType), color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.serviceType.isEmpty ? 'Service Request' : request.serviceType,
                        style: TextStyle(fontWeight: FontWeight.bold, color: glass.textOnGlass),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlassBadge(label: request.status.label, color: statusColor, compact: true),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  request.trackingNumber,
                  style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 12),
                ),
                if (request.createdAt != null)
                  Text(
                    _formatDate(request.createdAt),
                    style: TextStyle(color: glass.textOnGlassMuted, fontSize: 12),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: glass.textOnGlassMuted),
        ],
      ),
    );
  }
}
