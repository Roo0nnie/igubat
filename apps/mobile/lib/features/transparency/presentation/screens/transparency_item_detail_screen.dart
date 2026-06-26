import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_markdown_body.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../data/models/transparency_type.dart';
import '../../domain/entities/transparency_item.dart';
import '../providers/transparency_detail_provider.dart';
import '../widgets/transparency_attachment_tile.dart';
import '../widgets/transparency_detail_header.dart';
import '../widgets/transparency_format.dart';
import '../widgets/transparency_metadata_band.dart';

/// Item detail screen. Shows the reference number, title, type-specific
/// metadata band, summary, full body, and the downloadable attachments list
/// (opened on demand via a signed URL). Reachable from the category list and
/// from notification deep links (`/transparency/:type/:slug`).
class TransparencyItemDetailScreen extends ConsumerWidget {
  const TransparencyItemDetailScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glass = glassThemeOf(context);
    final itemAsync = ref.watch(transparencyDetailProvider(slug));

    return GlassScaffold(
      title: itemAsync.maybeWhen(
        data: (item) => item?.type.singularLabel ?? 'Transparency',
        orElse: () => 'Transparency',
      ),
      bottomPadding: false,
      useShellBackground: false,
      body: itemAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(AppLayout.screenHorizontal),
          children: const [
            GlassSkeletonCard(),
            SizedBox(height: 16),
            GlassSkeletonCard(),
          ],
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(AppLayout.screenHorizontal),
          child: Text(
            'Could not load item: $error',
            style: TextStyle(color: glass.textOnGlassMuted),
          ),
        ),
        data: (item) {
          if (item == null) {
            return Padding(
              padding: const EdgeInsets.all(AppLayout.screenHorizontal),
              child: Center(
                child: Text(
                  'This item is no longer available.',
                  style: TextStyle(color: glass.textOnGlassMuted),
                ),
              ),
            );
          }
          return _buildContent(context, item, glass);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TransparencyItem item,
    GlassTheme glass,
  ) {
    final meta = item.metadataAs<Map<String, dynamic>>() ?? const {};
    final status = transparencyStatusOf(item.type, meta);
    final hasSummary = (item.summary ?? '').trim().isNotEmpty;
    final hasBody = item.body.trim().isNotEmpty;
    final hasMetadata = TransparencyMetadataBand.computeEntries(
      item,
      excludeStatus: status != null && status.trim().isNotEmpty,
    ).isNotEmpty;

    return ListView(
      padding: const EdgeInsets.all(AppLayout.screenHorizontal),
      children: [
        GlassCard(
          intensity: GlassIntensity.prominent,
          child: TransparencyDetailHeader(item: item, status: status),
        ),
        if (hasMetadata) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Details',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: glass.textOnGlass,
                  ),
                ),
                const SizedBox(height: 16),
                TransparencyMetadataBand(
                  item: item,
                  excludeStatus: status != null && status.trim().isNotEmpty,
                ),
              ],
            ),
          ),
        ],
        if (hasSummary || hasBody) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasSummary) ...[
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: glass.textOnGlass,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.summary!,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: glass.textOnGlass,
                    ),
                  ),
                ],
                if (hasSummary && hasBody) const SizedBox(height: 16),
                if (hasBody) GlassMarkdownBody(data: item.body),
              ],
            ),
          ),
        ],
        if (item.attachments.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attachments (${item.attachments.length})',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: glass.textOnGlass,
                  ),
                ),
                const SizedBox(height: 12),
                ...item.attachments.map(
                  (attachment) =>
                      TransparencyAttachmentTile(attachment: attachment),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
