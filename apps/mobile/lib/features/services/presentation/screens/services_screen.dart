import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/navigation/glass_page_route.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_search_bar.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/service_type.dart';
import '../providers/services_provider.dart';
import 'service_request_stepper_screen.dart';

/// Adapts a live [ServiceType] to the existing [Service] view-model the grid
/// cards (and the request stepper) already consume, so the catalog UI is
/// unchanged while the data is now live. The category name is resolved from the
/// live categories so the filter chips keep matching.
Service _asService(ServiceType type, Map<int, String> categoryNames) => Service(
  title: type.name,
  description: type.description ?? '',
  icon: type.icon ?? '',
  category: categoryNames[type.categoryId] ?? 'All',
  processingDays: type.processingDays ?? 0,
  isPopular: type.isPopular,
  isAvailable: type.isActive,
);

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

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

  List<Service> _filterServices(List<Service> services) {
    return services.where((s) {
      final matchesCategory = _selectedCategory == 'All' || s.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
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
                return FilterChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  backgroundColor: glass.surfaceLight,
                  selectedColor: AppTheme.secondaryColor.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: selected ? AppTheme.primaryColor : glass.textOnGlassMuted,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(color: glass.border),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          servicesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: Text(
                  'Could not load services. Pull down to retry.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: glass.textOnGlassMuted),
                ),
              ),
            ),
            data: (types) {
              final services = _filterServices(
                types.map((t) => _asService(t, categoryNames)).toList(),
              );
              if (services.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      'No services match your filters.',
                      style: TextStyle(color: glass.textOnGlassMuted),
                    ),
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppLayout.gridGap,
                  mainAxisSpacing: AppLayout.gridGap,
                  childAspectRatio: 0.92,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) =>
                    _buildServiceCard(services[index], index, glass),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Service service, int index, GlassTheme glass) {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          GlassPageRoute(page: ServiceRequestStepperScreen(service: service)),
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
                child: Icon(_serviceIcon(service.icon), color: AppTheme.secondaryColor, size: 24),
              ),
              if (service.isPopular)
                const GlassBadge(label: 'Popular', compact: true),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            service.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: glass.textOnGlass,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              service.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: glass.textOnGlassMuted),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: service.isAvailable ? AppTheme.secondaryColor : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                service.isAvailable ? 'Available' : 'Unavailable',
                style: TextStyle(fontSize: 11, color: glass.textOnGlassMuted),
              ),
              const Spacer(),
              Icon(Icons.schedule, size: 12, color: glass.textOnGlassMuted),
              const SizedBox(width: 4),
              Text(
                '${service.processingDays}d',
                style: TextStyle(fontSize: 11, color: glass.textOnGlassMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.secondaryColor),
          ),
        ],
      ),
    ).animate(delay: (index * 40).ms);
  }
}
