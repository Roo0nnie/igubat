import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../data/models/transparency_item.dart';
import '../../data/models/transparency_type.dart';
import '../providers/transparency_detail_provider.dart';
import '../widgets/transparency_attachment_tile.dart';
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
    final itemAsync = ref.watch(transparencyDetailProvider(slug));

    return GlassScaffold(
      title: 'Transparency',
      bottomPadding: false,
      body: itemAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 80),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Could not load item: $error'),
        ),
        data: (item) {
          if (item == null) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('This item is no longer available.')),
            );
          }
          return _buildContent(context, item);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransparencyItem item) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          item.type.singularLabel.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Color(0xFF6B7280),
          ),
        ),
        if (item.referenceNumber != null) ...[
          const SizedBox(height: 4),
          Text(
            item.referenceNumber!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          item.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.25,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        TransparencyMetadataBand(item: item),
        if ((item.summary ?? '').isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            item.summary!,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
        if (item.body.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            item.body,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
        if (item.attachments.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            'Attachments (${item.attachments.length})',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          ...item.attachments.map(
            (attachment) => TransparencyAttachmentTile(attachment: attachment),
          ),
        ],
      ],
    );
  }
}
