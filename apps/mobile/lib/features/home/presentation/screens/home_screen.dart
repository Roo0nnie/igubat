import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_section_header.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../../shared/widgets/main_scaffold.dart';
import '../widgets/home_collapsing_header.dart';
import '../../../news/presentation/screens/news_detail_screen.dart';
import '../../../news/presentation/providers/news_provider.dart';
import '../../../reports/presentation/screens/report_issue_screen.dart';
import '../../../services/presentation/mappers/service_card_mapper.dart';
import '../../../services/presentation/mappers/service_icon_mapper.dart';
import '../../../services/presentation/screens/service_request_stepper_screen.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../../../applications/presentation/screens/applications_screen.dart';
import '../../../emergency/presentation/screens/emergency_screen.dart';
import '../../../events/presentation/screens/event_detail_screen.dart';
import '../../../events/presentation/screens/events_screen.dart';
import '../../../events/presentation/providers/events_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../service_requests/presentation/providers/service_requests_provider.dart';
import '../../../service_requests/presentation/service_request_status_color.dart';
import '../../../services/presentation/screens/request_details_screen.dart';
import '../../../transparency/presentation/widgets/transparency_section.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/home_section_message.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Re-fetches every live Home section. Individual failures are swallowed
  /// here; each section renders its own error state with a Retry action.
  Future<void> _onRefresh() async {
    Future<void> quietly(Future<Object?> future) =>
        future.then<void>((_) {}, onError: (_) {});

    await Future.wait([
      quietly(ref.refresh(dashboardProvider.future)),
      quietly(ref.refresh(newsListProvider.future)),
      quietly(ref.refresh(eventsListProvider.future)),
      quietly(ref.refresh(serviceTypesProvider.future)),
      quietly(ref.refresh(serviceCategoriesProvider.future)),
      if (ref.read(isAuthenticatedProvider))
        ref.read(serviceRequestsControllerProvider.notifier).reload(),
    ]);
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: AppMotion.durationStandard,
      curve: Curves.easeOutCubic,
    );
  }

  /// 12345 -> "12,345".
  static String _formatCount(int value) => value.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  IconData _statIcon(String key) => switch (key) {
    'registered_citizens' => Icons.people_outline,
    'pending_requests' => Icons.pending_actions_outlined,
    'completed_requests' => Icons.task_alt,
    'active_services' => Icons.miscellaneous_services_outlined,
    'new_reports' => Icons.report_outlined,
    'published_news' => Icons.article_outlined,
    'upcoming_events' => Icons.event_outlined,
    _ => Icons.analytics_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final bottomPad = AppLayout.scrollBottomPadding(context);
    // Hide Community Stats entirely when the admin has disabled every stat.
    final hideStats =
        ref.watch(dashboardProvider).value?.communityStats.isEmpty ?? false;

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
              HomeCollapsingHeader(onLogoTap: _scrollToTop),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppLayout.screenHorizontal,
                  AppLayout.screenTop,
                  AppLayout.screenHorizontal,
                  0,
                ),
                sliver: SliverToBoxAdapter(child: _buildQuickActions(context)),
              ),
              _buildTransparencySliver(context),
              _sectionSliver(
                context,
                title: 'Key Services',
                actionLabel: 'View All',
                onAction: () =>
                    MainScaffold.switchTab(context, MainScaffold.servicesTab),
                child: _buildServicesGrid(context),
              ),
              if (!hideStats)
                _sectionSliver(
                  context,
                  title: 'Community Stats',
                  child: _buildCommunityStats(context),
                ),
              _sectionSliver(
                context,
                title: 'Featured Community News',
                actionLabel: 'View All',
                onAction: () =>
                    MainScaffold.switchTab(context, MainScaffold.newsTab),
                child: _buildFeaturedNews(context),
              ),
              _sectionSliver(
                context,
                title: 'Upcoming Events',
                actionLabel: 'View All',
                onAction: () => Navigator.push(
                  context,
                  GlassPageRoute(page: const EventsScreen()),
                ),
                child: _buildUpcomingEvents(context),
              ),
              _sectionSliver(
                context,
                title: 'My Recent Requests',
                actionLabel: ref.watch(isAuthenticatedProvider)
                    ? 'View All'
                    : null,
                onAction: () => Navigator.push(
                  context,
                  GlassPageRoute(page: const ApplicationsScreen()),
                ),
                child: _buildMyRecentRequests(context),
              ),
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
    VoidCallback? onAction,
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
            GlassSectionHeader(
              title: title,
              actionLabel: actionLabel,
              onAction: onAction,
            ),
            const SizedBox(height: AppLayout.titleToContent),
            child,
          ],
        ),
      ),
    );
  }

  void _showPayBillsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.payment,
                  size: 36,
                  color: AppTheme.secondaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'Online payment is coming soon',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bills can\'t be paid in the app yet. Meanwhile, you can start a '
                  'service request or check the status of your existing ones.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    MainScaffold.switchTab(context, MainScaffold.servicesTab);
                  },
                  icon: const Icon(Icons.grid_view),
                  label: const Text('Browse Services'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      GlassPageRoute(page: const ApplicationsScreen()),
                    );
                  },
                  icon: const Icon(Icons.track_changes),
                  label: const Text('Track My Requests'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = <(IconData, String, Color, VoidCallback)>[
      (
        Icons.phone_in_talk,
        'Call 911',
        const Color(0xFFB91C1C),
        () => Navigator.push(
          context,
          GlassPageRoute(page: const EmergencyScreen()),
        ),
      ),
      (
        Icons.report_problem_outlined,
        'Report Issue',
        const Color(0xFFD97706),
        () => Navigator.push(
          context,
          GlassPageRoute(page: const ReportIssueScreen()),
        ),
      ),
      (
        Icons.track_changes,
        'Track Request',
        AppTheme.primaryColor,
        () => Navigator.push(
          context,
          GlassPageRoute(page: const ApplicationsScreen()),
        ),
      ),
      (
        Icons.payment,
        'Pay Bills',
        AppTheme.secondaryColor,
        () => _showPayBillsSheet(context),
      ),
      (
        Icons.explore_outlined,
        'Discover Gubat',
        const Color(0xFF0891B2),
        () => context.push('/discover-gubat'),
      ),
      (
        Icons.apps,
        'All Services',
        const Color(0xFF2563EB),
        () => MainScaffold.switchTab(context, MainScaffold.servicesTab),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GlassCard(
          intensity: GlassIntensity.prominent,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          onTap: action.$4,
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
                  fontSize: 12,
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

  Widget _gridSkeleton({required int count, required double aspectRatio}) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppLayout.gridGap,
      mainAxisSpacing: AppLayout.gridGap,
      childAspectRatio: aspectRatio,
      children: List.generate(
        count,
        (_) => GlassSkeleton(
          borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final servicesAsync = ref.watch(serviceTypesProvider);
    final liveCategories =
        ref.watch(serviceCategoriesProvider).value ?? const [];
    final categoryNames = {for (final c in liveCategories) c.id: c.name};

    if (servicesAsync.isLoading && !servicesAsync.hasValue) {
      return _gridSkeleton(count: 4, aspectRatio: 1.25);
    }
    if (servicesAsync.hasError && !servicesAsync.hasValue) {
      return HomeSectionMessage.error(
        onAction: () => ref.invalidate(serviceTypesProvider),
      );
    }

    // Popular services first, topped up with other active services.
    final active = (servicesAsync.value ?? const []).where((s) => s.isActive);
    final cards = [
      ...active.where((s) => s.isPopular),
      ...active.where((s) => !s.isPopular),
    ].take(4).map((s) => s.toServiceCard(categoryNames)).toList();

    if (cards.isEmpty) {
      return const HomeSectionMessage(
        icon: Icons.miscellaneous_services_outlined,
        title: 'No services available yet',
        message: 'LGU services will appear here once they are published.',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppLayout.gridGap,
        mainAxisSpacing: AppLayout.gridGap,
        childAspectRatio: 1.25,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final service = card.service;
        return GlassCard(
          onTap: () {
            Navigator.push(
              context,
              GlassPageRoute(
                page: ServiceRequestStepperScreen(
                  service: service,
                  serviceTypeId: card.serviceTypeId,
                ),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                serviceIconFor(service.icon),
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

  /// Horizontal strip of skeleton cards for carousel-style sections.
  Widget _stripSkeleton({required double height, required double itemWidth}) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => GlassSkeleton(
          width: itemWidth,
          height: height,
          borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
        ),
      ),
    );
  }

  Widget _buildCommunityStats(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);
    if (dashboardAsync.isLoading && !dashboardAsync.hasValue) {
      return _stripSkeleton(height: 110, itemWidth: 150);
    }
    if (dashboardAsync.hasError && !dashboardAsync.hasValue) {
      return HomeSectionMessage.error(
        onAction: () => ref.invalidate(dashboardProvider),
      );
    }
    final stats = dashboardAsync.value?.communityStats ?? const [];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: stats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final stat = stats[index];
          return SizedBox(
            width: 150,
            child: GlassCard(
              intensity: GlassIntensity.subtle,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _statIcon(stat.key),
                    color: AppTheme.secondaryColor,
                    size: 20,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCount(stat.value),
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
    final newsAsync = ref.watch(newsListProvider);
    if (newsAsync.isLoading && !newsAsync.hasValue) {
      return const GlassSkeletonCard();
    }
    if (newsAsync.hasError && !newsAsync.hasValue) {
      return HomeSectionMessage.error(
        onAction: () => ref.invalidate(newsListProvider),
      );
    }
    final articles = newsAsync.value ?? const [];
    if (articles.isEmpty) {
      return const HomeSectionMessage(
        icon: Icons.article_outlined,
        title: 'No news yet',
        message: 'Municipal announcements will appear here.',
      );
    }

    // The admin-featured article wins; otherwise show the latest one.
    final article = articles.firstWhere(
      (a) => a.isFeatured,
      orElse: () => articles.first,
    );
    final category = article.category;
    final title = article.title;
    final summary = (article.excerpt?.isNotEmpty ?? false)
        ? article.excerpt!
        : article.body;
    final slug = article.slug;

    return GlassCard(
      intensity: GlassIntensity.prominent,
      padding: EdgeInsets.zero,
      onTap: () {
        if (slug != null && slug.isNotEmpty) {
          Navigator.push(
            context,
            GlassPageRoute(page: NewsDetailScreen(slug: slug)),
          );
        }
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
                    GlassBadge(label: category, color: AppTheme.secondaryColor),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary,
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

  static const List<String> _monthAbbr = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatEventDate(DateTime? date) {
    if (date == null) return 'To be announced';
    final local = date.toLocal();
    return '${_monthAbbr[local.month - 1]} ${local.day}, ${local.year}';
  }

  Widget _buildUpcomingEvents(BuildContext context) {
    final eventsAsync = ref.watch(eventsListProvider);
    if (eventsAsync.isLoading && !eventsAsync.hasValue) {
      return _stripSkeleton(height: 140, itemWidth: 200);
    }
    if (eventsAsync.hasError && !eventsAsync.hasValue) {
      return HomeSectionMessage.error(
        onAction: () => ref.invalidate(eventsListProvider),
      );
    }
    final events = eventsAsync.value ?? const [];
    if (events.isEmpty) {
      return const HomeSectionMessage(
        icon: Icons.event_busy_outlined,
        title: 'No upcoming events',
        message: 'Check back soon for community activities.',
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: events.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final event = events[index];
          final category = event.category ?? 'Event';
          final title = event.title;
          final dateStr = _formatEventDate(event.startsAt);
          final location = (event.location?.isNotEmpty ?? false)
              ? event.location!
              : 'To be announced';
          return SizedBox(
            width: 200,
            child: GlassCard(
              onTap: () => Navigator.push(
                context,
                GlassPageRoute(page: EventDetailScreen(slug: event.slug)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassBadge(label: category, compact: true),
                  const SizedBox(height: 8),
                  Text(
                    title,
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
                          dateStr,
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
                          location,
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

  /// Signed-in citizen's latest service requests (live `/me/requests`).
  Widget _buildMyRecentRequests(BuildContext context) {
    if (!ref.watch(isAuthenticatedProvider)) {
      return HomeSectionMessage(
        icon: Icons.lock_outline,
        title: 'Sign in to track your requests',
        message:
            'See the status of your permits, certificates and other requests.',
        actionLabel: 'Sign In',
        onAction: () => context.push(AppRoutes.login),
      );
    }

    final requestsAsync = ref.watch(serviceRequestsControllerProvider);
    if (requestsAsync.isLoading && !requestsAsync.hasValue) {
      return const Column(
        children: [
          GlassSkeleton(width: double.infinity, height: 72),
          SizedBox(height: 12),
          GlassSkeleton(width: double.infinity, height: 72),
        ],
      );
    }
    if (requestsAsync.hasError && !requestsAsync.hasValue) {
      return HomeSectionMessage.error(
        onAction: () =>
            ref.read(serviceRequestsControllerProvider.notifier).reload(),
      );
    }

    final requests = [...?requestsAsync.value]
      ..sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    if (requests.isEmpty) {
      return HomeSectionMessage(
        icon: Icons.assignment_outlined,
        title: 'You have no requests yet',
        message: 'Start a permit, certificate or assistance request.',
        actionLabel: 'Browse',
        onAction: () =>
            MainScaffold.switchTab(context, MainScaffold.servicesTab),
      );
    }

    final glass = glassThemeOf(context);
    return Column(
      children: requests.take(3).map((request) {
        final statusColor = request.status.color;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            intensity: GlassIntensity.subtle,
            padding: const EdgeInsets.all(16),
            onTap: () => Navigator.push(
              context,
              GlassPageRoute(page: RequestDetailsScreen(requestId: request.id)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.serviceType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: glass.textOnGlass,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${request.trackingNumber} · ${_formatEventDate(request.createdAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: glass.textOnGlassMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GlassBadge(
                  label: request.status.label,
                  color: statusColor,
                  compact: true,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
