import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_search_bar.dart';
import '../../../../shared/widgets/glass/glass_section_header.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  IconData _serviceIcon(String icon) {
    switch (icon) {
      case 'briefcase':
        return Icons.business_center;
      case 'file-text':
        return Icons.description;
      case 'megaphone':
        return Icons.campaign;
      case 'credit-card':
        return Icons.payment;
      case 'heart':
        return Icons.favorite;
      default:
        return Icons.article;
    }
  }

  IconData _statIcon(String icon) {
    switch (icon) {
      case 'people':
        return Icons.people_outline;
      case 'requests':
        return Icons.assignment_outlined;
      case 'time':
        return Icons.schedule;
      default:
        return Icons.analytics_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = AppLayout.scrollBottomPadding(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFixedHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.secondaryColor,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    if (_loading)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const GlassSkeletonCard(),
                            const SizedBox(height: 16),
                            const GlassSkeletonCard(),
                          ]),
                        ),
                      )
                    else ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        sliver: SliverToBoxAdapter(child: _buildQuickActions(context)),
                      ),
                      _sectionSliver(
                        context,
                        title: 'Key Services',
                        actionLabel: 'View All',
                        child: _buildServicesGrid(context),
                      ),
                      _sectionSliver(
                        context,
                        title: 'Community Stats',
                        child: _buildCommunityStats(context),
                      ),
                      _sectionSliver(
                        context,
                        title: 'Featured Community News',
                        actionLabel: 'View All',
                        child: _buildFeaturedNews(),
                      ),
                      _sectionSliver(
                        context,
                        title: 'Upcoming Events',
                        actionLabel: 'View All',
                        child: _buildUpcomingEvents(context),
                      ),
                      _sectionSliver(
                        context,
                        title: 'Recent Transactions',
                        child: _buildRecentTransactions(context),
                      ),
                    ],
                    SliverPadding(padding: EdgeInsets.only(bottom: bottomPad)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionSliver(
    BuildContext context, {
    required String title,
    String? actionLabel,
    required Widget child,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassSectionHeader(title: title, actionLabel: actionLabel),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(GlassTokens.radiusGlassLg),
        bottomRight: Radius.circular(GlassTokens.radiusGlassLg),
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F3D26),
              Color(0xFF1B5E3C),
              Color(0xFF2D6A4F),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Warm greeting!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            SeedData.currentUser.name,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            SeedData.currentUser.barangay,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GlassSurface(
                      intensity: GlassIntensity.subtle,
                      borderRadius: BorderRadius.circular(999),
                      tint: Colors.white.withValues(alpha: 0.15),
                      boxShadow: const [],
                      padding: EdgeInsets.zero,
                      child: IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            GlassPageRoute(page: const NotificationsScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const GlassSearchBar(
                  floating: true,
                  margin: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (Icons.phone_in_talk, 'Call 911', const Color(0xFFB91C1C)),
      (Icons.payment, 'Pay Bills', AppTheme.secondaryColor),
      (Icons.track_changes, 'Track Request', AppTheme.primaryColor),
    ];

    return Row(
      children: List.generate(actions.length, (index) {
        final action = actions[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < actions.length - 1 ? 12 : 0),
            child: GlassCard(
              intensity: GlassIntensity.prominent,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              onTap: () {},
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: action.$3.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(action.$1, color: action.$3, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action.$2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: glassThemeOf(context).textOnGlass,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = SeedData.services.take(4).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.05,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return GlassCard(
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_serviceIcon(service.icon), size: 32, color: AppTheme.secondaryColor),
              const SizedBox(height: 12),
              Text(
                service.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: glassThemeOf(context).textOnGlass,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommunityStats(BuildContext context) {
    return Row(
      children: List.generate(SeedData.communityStats.length, (index) {
        final stat = SeedData.communityStats[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index < SeedData.communityStats.length - 1 ? 12 : 0,
            ),
            child: GlassCard(
              intensity: GlassIntensity.subtle,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_statIcon(stat.icon), color: AppTheme.secondaryColor, size: 20),
                  const SizedBox(height: 8),
                  Text(
                    stat.value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: glassThemeOf(context).textOnGlass,
                    ),
                  ),
                  Text(
                    stat.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: glassThemeOf(context).textOnGlassMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFeaturedNews() {
    final featured = SeedData.announcements.firstWhere((a) => a.isFeatured);

    return GlassCard(
      intensity: GlassIntensity.prominent,
      padding: EdgeInsets.zero,
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
        child: SizedBox(
          height: 200,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassBadge(label: featured.category, color: AppTheme.secondaryColor),
                    const Spacer(),
                    Text(
                      featured.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      featured.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: SeedData.upcomingEvents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final event = SeedData.upcomingEvents[index];
          return SizedBox(
            width: 200,
            child: GlassCard(
              onTap: () {},
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassBadge(label: event.category, compact: true),
                  const SizedBox(height: 8),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: glassThemeOf(context).textOnGlass,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: glassThemeOf(context).textOnGlassMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.date,
                          style: TextStyle(fontSize: 11, color: glassThemeOf(context).textOnGlassMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: glassThemeOf(context).textOnGlassMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: glassThemeOf(context).textOnGlassMuted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      children: SeedData.recentTransactions.map((tx) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            intensity: GlassIntensity.subtle,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.receipt_long, color: AppTheme.secondaryColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: glassThemeOf(context).textOnGlass,
                        ),
                      ),
                      Text(
                        tx.date,
                        style: TextStyle(fontSize: 12, color: glassThemeOf(context).textOnGlassMuted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tx.amount,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: glassThemeOf(context).textOnGlass,
                      ),
                    ),
                    GlassBadge(label: tx.status, color: AppTheme.secondaryColor, compact: true),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
