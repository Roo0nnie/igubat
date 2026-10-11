import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/glass_page_route.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../../shared/widgets/states/app_state_views.dart';
import '../providers/discover_gubat_provider.dart';
import 'discover_gubat_detail_screen.dart';

Widget _discoverSkeleton(BuildContext context) => const GlassSkeletonCard(imageHeight: 0);

class DiscoverGubatListScreen extends ConsumerWidget {
  const DiscoverGubatListScreen({super.key});

  String _label(String value) =>
      value.split('_').map((word) => word.isEmpty ? word : '${word[0].toUpperCase()}${word.substring(1)}').join(' ');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);
    final items = ref.watch(discoverGubatListProvider);

    return GlassScaffold(
      title: 'Discover Gubat',
      onRefresh: () async {
        ref.invalidate(discoverGubatListProvider);
        await ref.read(discoverGubatListProvider.future);
      },
      body: items.when(
        loading: () => StateScrollView(
          padding: const EdgeInsets.all(24),
          child: LoadingStateView(
            message: 'Loading places, products and culture...',
            skeleton: const GlassSkeletonList(count: 5, itemBuilder: _discoverSkeleton),
            onRetry: () => ref.invalidate(discoverGubatListProvider),
          ),
        ),
        error: (error, _) => StateScrollView(
          padding: const EdgeInsets.all(24),
          child: ErrorStateView(
            title: 'Unable to load Discover Gubat',
            error: error,
            onRetry: () => ref.invalidate(discoverGubatListProvider),
          ),
        ),
        data: (rows) {
          if (rows.isEmpty) {
            return const StateScrollView(
              padding: EdgeInsets.all(24),
              child: EmptyStateView(
                icon: Icons.travel_explore_rounded,
                title: 'Nothing to discover yet',
                message: 'Tourist spots, local products and culture will appear here soon.',
              ),
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = rows[index];
              return GlassCard(
                onTap: () => Navigator.push(
                  context,
                  GlassPageRoute(
                    page: DiscoverGubatDetailScreen(slug: item.slug),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(item.type),
                      style: TextStyle(
                        color: glass.textOnGlassMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      style: TextStyle(
                        color: glass.textOnGlass,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.summary?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.summary!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: glass.textOnGlassMuted),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
