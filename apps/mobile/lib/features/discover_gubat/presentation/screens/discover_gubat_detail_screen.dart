import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../../shared/widgets/states/app_state_views.dart';
import '../providers/discover_gubat_provider.dart';

class DiscoverGubatDetailScreen extends ConsumerWidget {
  const DiscoverGubatDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);
    final item = ref.watch(discoverGubatDetailProvider(slug));

    return GlassScaffold(
      title: 'Discover Gubat',
      onRefresh: () async => ref.refresh(discoverGubatDetailProvider(slug).future),
      body: item.when(
        loading: () => StateScrollView(
          padding: const EdgeInsets.all(24),
          child: LoadingStateView(
            message: 'Loading details...',
            skeleton: const GlassSkeletonDetail(showHero: false),
            onRetry: () => ref.invalidate(discoverGubatDetailProvider(slug)),
          ),
        ),
        error: (error, _) => StateScrollView(
          padding: const EdgeInsets.all(24),
          child: ErrorStateView(
            title: 'Unable to load this item',
            error: error,
            onRetry: () => ref.invalidate(discoverGubatDetailProvider(slug)),
          ),
        ),
        data: (value) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.title,
                    style: TextStyle(
                      color: glass.textOnGlass,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (value.locationName?.isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      value.locationName!,
                      style: TextStyle(color: glass.textOnGlassMuted),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    value.body.isNotEmpty ? value.body : value.summary ?? '',
                    style: TextStyle(
                      color: glass.textOnGlass,
                      height: 1.5,
                    ),
                  ),
                  if (value.whereToBuy?.isNotEmpty == true) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Where to buy: ${value.whereToBuy}',
                      style: TextStyle(
                        color: glass.textOnGlass,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
