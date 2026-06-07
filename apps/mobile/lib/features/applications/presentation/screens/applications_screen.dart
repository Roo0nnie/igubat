import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../core/widgets/igubat_logo.dart';
import '../../../../core/mock/seed_data.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../../../shared/widgets/app_stepper.dart';
import '../../../../shared/widgets/glass/glass_background.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_list_tile.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../services/presentation/screens/request_details_screen.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final glass = glassThemeOf(context);

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
                          'Profile Summary',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Account Ordinary',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  GlassCard(
                    child: const AppStepper(
                      steps: ['Step 1', 'Progress', 'Step 2', 'Step 4'],
                      currentStep: 1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Active Applications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: glass.textOnGlass,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _applicationCard(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Business Permit',
                    status: 'Step 3 - Progressing',
                    date: 'Sep 2024',
                  ),
                  const SizedBox(height: 12),
                  _applicationCard(
                    context,
                    icon: Icons.workspace_premium_outlined,
                    title: 'Certificate of Residency',
                    status: 'Step 2 - Submitted',
                    date: 'Oct 2024',
                  ),
                  const SizedBox(height: 24),
                  GlassListTile(
                    title: 'Notifications',
                    leading: Icon(Icons.notifications_none, color: glass.textOnGlassMuted),
                    trailing: const GlassBadge(label: '3 new', compact: true),
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  GlassListTile(
                    title: 'Settings',
                    leading: Icon(Icons.settings_outlined, color: glass.textOnGlassMuted),
                    trailing: Icon(Icons.chevron_right, color: glass.textOnGlassMuted),
                    onTap: () {},
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _applicationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String status,
    required String date,
  }) {
    final glass = glassThemeOf(context);

    return GlassCard(
      onTap: () {
        final request = title.contains('Business')
            ? SeedData.activeRequests.first
            : SeedData.activeRequests.last;
        Navigator.push(
          context,
          GlassPageRoute(page: RequestDetailsScreen(request: request)),
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
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: glass.textOnGlass)),
                const SizedBox(height: 4),
                Text(status, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 12)),
                Text(date, style: TextStyle(color: glass.textOnGlassMuted, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: glass.textOnGlassMuted),
        ],
      ),
    );
  }
}
