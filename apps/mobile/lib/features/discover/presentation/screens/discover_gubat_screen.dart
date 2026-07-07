import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/glass_page_route.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_section_header.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../data/models/discover_gubat_entry.dart';
import '../../data/repositories/discover_gubat_repository.dart';

class DiscoverGubatScreen extends ConsumerWidget {
  const DiscoverGubatScreen({super.key});

  static DiscoverGubatEntry? itemBySlug(String slug) =>
      DiscoverGubatRepository.seedBySlug(slug);

  static const _sections = [
    _DiscoverSectionConfig(
      type: DiscoverGubatType.touristSpot,
      title: 'Tourist Spots',
      subtitle: 'Beaches, eco-tourism, heritage, and landmarks',
      icon: Icons.beach_access,
      color: Color(0xFF0EA5E9),
    ),
    _DiscoverSectionConfig(
      type: DiscoverGubatType.festivalCulture,
      title: 'Festivals & Culture',
      subtitle: 'Town heritage, Ginubat Festival, and local traditions',
      icon: Icons.celebration_outlined,
      color: Color(0xFF7C3AED),
    ),
    _DiscoverSectionConfig(
      type: DiscoverGubatType.localProduct,
      title: 'Local Delicacies & Products',
      subtitle: 'Kakanin, pasalubong, OTOP goods, seafood, and pili',
      icon: Icons.storefront_outlined,
      color: Color(0xFFD97706),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);

    return GlassScaffold(
      title: 'Discover Gubat',
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.maybePop(context),
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          AppLayout.screenHorizontal,
          AppLayout.screenTop,
          AppLayout.screenHorizontal,
          AppLayout.scrollBottomPadding(context),
        ),
        itemCount: _sections.length + 1,
        separatorBuilder: (_, _) =>
            const SizedBox(height: AppLayout.sectionGap),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Text(
              'Explore Gubat tourism, culture, and local products through read-only public guides.',
              style: TextStyle(
                color: glass.textOnGlassMuted,
                fontSize: 14,
                height: 1.45,
              ),
            );
          }

          return _DiscoverSection(config: _sections[index - 1]);
        },
      ),
    );
  }
}

class DiscoverGubatItemDetailScreen extends ConsumerWidget {
  const DiscoverGubatItemDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(discoverGubatDetailProvider(slug));

    return entry.when(
      data: (item) {
        if (item == null) {
          return _UnavailableDiscoverItem(slug: slug);
        }
        final config = _configForType(item.type);
        return _DiscoverItemDetailScreen(
          item: item,
          icon: config.icon,
          color: config.color,
        );
      },
      loading: () => GlassScaffold(
        title: 'Discover Gubat',
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _UnavailableDiscoverItem(slug: slug),
    );
  }
}

class _DiscoverSection extends ConsumerWidget {
  const _DiscoverSection({required this.config});

  final _DiscoverSectionConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(discoverGubatListProvider(config.type));
    final repository = ref.watch(discoverGubatRepositoryProvider);
    final lastUpdated = repository.lastUpdatedFor(config.type);
    final isCached = repository.wasCachedFor(config.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassSectionHeader(title: config.title),
        const SizedBox(height: 4),
        Text(
          config.subtitle,
          style: TextStyle(
            color: glassThemeOf(context).textOnGlassMuted,
            fontSize: 13,
          ),
        ),
        if (lastUpdated != null) ...[
          const SizedBox(height: 4),
          Text(
            '${isCached ? 'Offline cache' : 'Last updated'}: ${_formatUpdated(lastUpdated)}',
            style: TextStyle(
              color: glassThemeOf(context).textOnGlassMuted,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: AppLayout.titleToContent),
        entries.when(
          data: (items) => Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppLayout.listItemGap,
                    ),
                    child: _DiscoverItemCard(
                      item: item,
                      icon: config.icon,
                      color: config.color,
                    ),
                  ),
                )
                .toList(),
          ),
          loading: () => GlassCard(
            intensity: GlassIntensity.subtle,
            child: Text(
              'Loading ${config.title.toLowerCase()}...',
              style: TextStyle(color: glassThemeOf(context).textOnGlassMuted),
            ),
          ),
          error: (_, _) => GlassCard(
            intensity: GlassIntensity.subtle,
            child: Text(
              '${config.title} could not be loaded.',
              style: TextStyle(color: glassThemeOf(context).textOnGlassMuted),
            ),
          ),
        ),
      ],
    );
  }
}

class _DiscoverItemCard extends StatelessWidget {
  const _DiscoverItemCard({
    required this.item,
    required this.icon,
    required this.color,
  });

  final DiscoverGubatEntry item;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      intensity: GlassIntensity.subtle,
      onTap: () {
        Navigator.push(
          context,
          GlassPageRoute(
            page: item.slug.isEmpty
                ? _DiscoverItemDetailScreen(
                    item: item,
                    icon: icon,
                    color: color,
                  )
                : DiscoverGubatItemDetailScreen(slug: item.slug),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassBadge(label: item.category, color: color, compact: true),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverItemDetailScreen extends StatelessWidget {
  const _DiscoverItemDetailScreen({
    required this.item,
    required this.icon,
    required this.color,
  });

  final DiscoverGubatEntry item;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final imageUrl = item.primaryImageUrl;

    return GlassScaffold(
      title: item.title,
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.maybePop(context),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppLayout.screenHorizontal,
          AppLayout.screenTop,
          AppLayout.screenHorizontal,
          AppLayout.scrollBottomPadding(context),
        ),
        children: [
          GlassCard(
            intensity: GlassIntensity.prominent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl == null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  )
                else
                  _DiscoverItemImage(imageUrl: imageUrl, title: item.title),
                const SizedBox(height: 14),
                if (imageUrl != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(height: 14),
                ],
                GlassBadge(label: item.category, color: color, compact: true),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: TextStyle(
                    color: glass.textOnGlass,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.detailDescription,
                  style: TextStyle(
                    color: glass.textOnGlassMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppLayout.blockGap),
          GlassCard(
            intensity: GlassIntensity.subtle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.detailLabel,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.detailValue,
                  style: TextStyle(
                    color: glass.textOnGlass,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverItemImage extends StatelessWidget {
  const _DiscoverItemImage({required this.imageUrl, required this.title});

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 190,
        fit: BoxFit.cover,
        semanticLabel: title,
        errorBuilder: (context, error, stackTrace) {
          return GlassSurface(
            intensity: GlassIntensity.subtle,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.image_not_supported_outlined),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Photo unavailable',
                    style: TextStyle(color: glassThemeOf(context).textOnGlass),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UnavailableDiscoverItem extends StatelessWidget {
  const _UnavailableDiscoverItem({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      title: 'Discover Gubat',
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.maybePop(context),
      ),
      body: const Center(
        child: Text('This Discover Gubat item is no longer available.'),
      ),
    );
  }
}

class _DiscoverSectionConfig {
  const _DiscoverSectionConfig({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final DiscoverGubatType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}

_DiscoverSectionConfig _configForType(DiscoverGubatType type) {
  return DiscoverGubatScreen._sections.firstWhere(
    (config) => config.type == type,
    orElse: () => DiscoverGubatScreen._sections.first,
  );
}

String _formatUpdated(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.month}/${value.day}/${value.year} $hour:$minute $period';
}
