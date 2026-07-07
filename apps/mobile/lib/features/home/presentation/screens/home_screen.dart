import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_section_header.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../widgets/home_collapsing_header.dart';
import '../../../discover/presentation/screens/discover_gubat_screen.dart';
import '../../../news/presentation/screens/news_detail_screen.dart';
import '../../../reports/presentation/screens/report_issue_screen.dart';
import '../../../services/presentation/screens/request_details_screen.dart';
import '../../../services/presentation/screens/service_request_stepper_screen.dart';
import '../../../emergency/presentation/screens/emergency_screen.dart';
import '../../../transparency/presentation/widgets/transparency_section.dart';
import 'event_detail_screen.dart';
import 'transaction_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.secondaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              const HomeCollapsingHeader(),
              if (_loading)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.screenHorizontal,
                    AppLayout.screenTop,
                    AppLayout.screenHorizontal,
                    0,
                  ),
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
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.screenHorizontal,
                    AppLayout.screenTop,
                    AppLayout.screenHorizontal,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _buildQuickActions(context),
                  ),
                ),
                _buildTransparencySliver(context),
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
                  child: _buildFeaturedNews(context),
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
    );
  }

  /// Transparency & Good Governance section: a titled header with the
  /// "Know where your taxes go" subtitle above the 2x3 tile grid. Slotted
  /// between Quick Actions and the rest of the Home feed.
  Widget _buildTransparencySliver(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenHorizontal,
        AppLayout.sectionGap,
        AppLayout.screenHorizontal,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Transparency & Good Governance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: glassThemeOf(context).textOnGlass,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Know where your taxes go',
              style: TextStyle(
                fontSize: 13,
                color: glassThemeOf(context).textOnGlassMuted,
              ),
            ),
            const SizedBox(height: AppLayout.titleToContent),
            const TransparencySection(),
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
      padding: const EdgeInsets.fromLTRB(
        AppLayout.screenHorizontal,
        AppLayout.sectionGap,
        AppLayout.screenHorizontal,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassSectionHeader(title: title, actionLabel: actionLabel),
            const SizedBox(height: AppLayout.titleToContent),
            child,
          ],
        ),
      ),
    );
  }

  void _onQuickActionTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.push(context, GlassPageRoute(page: const EmergencyScreen()));
        break;
      case 1:
        Navigator.push(
          context,
          GlassPageRoute(page: const ReportIssueScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          GlassPageRoute(
            page: RequestDetailsScreen(request: SeedData.activeRequests.first),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          GlassPageRoute(page: const DiscoverGubatScreen()),
        );
        break;
      default:
        Navigator.push(
          context,
          GlassPageRoute(
            page: TransactionDetailScreen(
              transaction: SeedData.recentTransactions.first,
            ),
          ),
        );
    }
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (Icons.phone_in_talk, 'Call 911', const Color(0xFFB91C1C)),
      (Icons.report_problem_outlined, 'Report Issue', const Color(0xFFD97706)),
      (Icons.track_changes, 'Track Request', AppTheme.primaryColor),
      (Icons.travel_explore, 'Discover Gubat', const Color(0xFF0EA5E9)),
      (Icons.payment, 'Pay Bills', AppTheme.secondaryColor),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GlassCard(
          intensity: GlassIntensity.prominent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          onTap: () => _onQuickActionTap(context, index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: glassThemeOf(context).textOnGlass,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final services = SeedData.services.take(4).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppLayout.gridGap,
        mainAxisSpacing: AppLayout.gridGap,
        childAspectRatio: 1.25,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return GlassCard(
          onTap: () {
            Navigator.push(
              context,
              GlassPageRoute(
                page: ServiceRequestStepperScreen(service: service),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _serviceIcon(service.icon),
                size: 32,
                color: AppTheme.secondaryColor,
              ),
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
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: SeedData.communityStats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stat = SeedData.communityStats[index];
          return SizedBox(
            width: 150,
            child: GlassCard(
              intensity: GlassIntensity.subtle,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _statIcon(stat.icon),
                    color: AppTheme.secondaryColor,
                    size: 20,
                  ),
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
          );
        },
      ),
    );
  }

  Widget _buildFeaturedNews(BuildContext context) {
    final featured = SeedData.announcements.firstWhere((a) => a.isFeatured);

    return GlassCard(
      intensity: GlassIntensity.prominent,
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          GlassPageRoute(page: NewsDetailScreen(announcement: featured)),
        );
      },
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
                    GlassBadge(
                      label: featured.category,
                      color: AppTheme.secondaryColor,
                    ),
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
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final event = SeedData.upcomingEvents[index];
          return SizedBox(
            width: 200,
            child: GlassCard(
              onTap: () {
                Navigator.push(
                  context,
                  GlassPageRoute(page: EventDetailScreen(event: event)),
                );
              },
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
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: glassThemeOf(context).textOnGlassMuted,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.date,
                          style: TextStyle(
                            fontSize: 11,
                            color: glassThemeOf(context).textOnGlassMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: glassThemeOf(context).textOnGlassMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: glassThemeOf(context).textOnGlassMuted,
                          ),
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
            onTap: () {
              Navigator.push(
                context,
                GlassPageRoute(page: TransactionDetailScreen(transaction: tx)),
              );
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppTheme.secondaryColor,
                    size: 20,
                  ),
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
                        style: TextStyle(
                          fontSize: 12,
                          color: glassThemeOf(context).textOnGlassMuted,
                        ),
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
                    GlassBadge(
                      label: tx.status,
                      color: AppTheme.secondaryColor,
                      compact: true,
                    ),
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
