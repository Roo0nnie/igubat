import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/glass_page_route.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_search_bar.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../../shared/widgets/states/app_state_views.dart';
import '../../domain/entities/service_category.dart';
import '../mappers/service_card_mapper.dart';
import '../mappers/service_icon_mapper.dart';
import '../providers/services_provider.dart';
import 'service_request_stepper_screen.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<ServiceCard> _filterServices(List<ServiceCard> cards) {
    return cards.where((card) {
      final service = card.service;
      final matchesCategory = _selectedCategory == 'All' || service.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          service.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _retry() {
    ref.invalidate(serviceTypesProvider);
    ref.invalidate(serviceCategoriesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final servicesAsync = ref.watch(serviceTypesProvider);
    final categoriesAsync = ref.watch(serviceCategoriesProvider);

    // Live category id -> name lookup for adapting service types, and the chip
    // labels ('All' + active category names). Falls back to empty while loading.
    final categories = categoriesAsync.maybeWhen(
      data: (list) => list,
      orElse: () => const <ServiceCategory>[],
    );
    final categoryNames = {for (final c in categories) c.id: c.name};
    final categoryLabels = <String>[
      'All',
      for (final c in categories) c.name,
    ];

    return GlassScaffold(
      title: 'Service Categories',
      onRefresh: () async {
        ref.invalidate(serviceTypesProvider);
        ref.invalidate(serviceCategoriesProvider);
        await ref.read(serviceTypesProvider.future);
      },
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.screenHorizontal,
          AppLayout.screenTop,
          AppLayout.screenHorizontal,
          AppLayout.scrollBottomPadding(context),
        ),
        children: [
          Text(
            'Explore LGU Services',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: glass.textOnGlass),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a category to view available services and submit requests.',
            style: TextStyle(color: glass.textOnGlassMuted, fontSize: 14),
          ),
          const SizedBox(height: AppLayout.blockGap),
          GlassSearchBar(
            hintText: 'Search services...',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: AppSpacing.s16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categoryLabels.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categoryLabels[index];
                final selected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  backgroundColor: glass.surfaceMedium,
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : glass.textOnGlass,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  side: BorderSide(
                    color: selected
                        ? glass.brandOnGlass
                        : glass.textOnGlassMuted.withValues(alpha: 0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          servicesAsync.buildStates(
            loadingMessage: 'Loading available services...',
            skeleton: const GlassSkeletonGrid(),
            errorTitle: 'Unable to load services',
            onRetry: _retry,
            data: (types) {
              final cards = _filterServices(
                types.map((t) => t.toServiceCard(categoryNames)).toList(),
              );
              if (cards.isEmpty) {
                final filtered = _searchQuery.isNotEmpty || _selectedCategory != 'All';
                return EmptyStateView(
                  icon: filtered ? Icons.search_off_rounded : Icons.grid_view_rounded,
                  title: filtered ? 'No matching services' : 'No services yet',
                  message: filtered
                      ? 'Try a different keyword or choose another category.'
                      : 'LGU services will appear here once they are published.',
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppLayout.gridGap,
                  mainAxisSpacing: AppLayout.gridGap,
                  mainAxisExtent: 196 * MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4),
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) =>
                    _buildServiceCard(cards[index], index, glass),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceCard card, int index, GlassTheme glass) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlassSurface(
                intensity: GlassIntensity.subtle,
                borderRadius: BorderRadius.circular(999),
                tint: AppTheme.secondaryColor.withValues(alpha: 0.12),
                boxShadow: const [],
                padding: const EdgeInsets.all(12),
                child: Icon(serviceIconFor(service.icon), color: AppTheme.secondaryColor, size: 24),
              ),
              if (service.isPopular)
                const GlassBadge(label: 'Popular', compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            service.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: glass.textOnGlass,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.5, height: 1.35, color: glass.textOnGlassMuted),
            ),
          ),
          Divider(height: 16, color: glass.textOnGlassMuted.withValues(alpha: 0.2)),
          Row(
            children: [
              Icon(
                service.isAvailable ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                size: 14,
                color: service.isAvailable ? glass.brandOnGlass : glass.textOnGlassMuted,
              ),
              const SizedBox(width: 4),
              Text(
                service.isAvailable ? 'Available' : 'Unavailable',
                style: TextStyle(fontSize: 11.5, color: glass.textOnGlassMuted),
              ),
              const Spacer(),
              Icon(Icons.schedule_rounded, size: 13, color: glass.textOnGlassMuted),
              const SizedBox(width: 3),
              Text(
                _processingLabel(service.processingDays),
                style: TextStyle(fontSize: 11.5, color: glass.textOnGlassMuted),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: (index * 40).ms);
  }

  String _processingLabel(int days) {
    if (days <= 0) return 'Same day';
    return days == 1 ? '1 day' : '$days days';
  }
}
