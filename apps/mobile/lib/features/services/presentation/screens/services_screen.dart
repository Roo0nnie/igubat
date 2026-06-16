import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
import 'service_request_stepper_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
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

  List<Service> get _filteredServices {
    return SeedData.services.where((s) {
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

    return GlassScaffold(
      title: 'Service Categories',
      onRefresh: () async => Future.delayed(const Duration(milliseconds: 600)),
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
              itemCount: SeedData.serviceCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = SeedData.serviceCategories[index];
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppLayout.gridGap,
              mainAxisSpacing: AppLayout.gridGap,
              childAspectRatio: 0.92,
            ),
            itemCount: _filteredServices.length,
            itemBuilder: (context, index) {
              final service = _filteredServices[index];
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
            },
          ),
        ],
      ),
    );
  }
}
