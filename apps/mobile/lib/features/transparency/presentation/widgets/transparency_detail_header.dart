import 'package:flutter/material.dart';

import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_info_row.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../data/models/transparency_type.dart';
import '../../domain/entities/transparency_item.dart';
import 'transparency_format.dart';

/// Header section for transparency item detail: type badge, reference, title,
/// optional status badge, and published date.
class TransparencyDetailHeader extends StatelessWidget {
  const TransparencyDetailHeader({
    super.key,
    required this.item,
    this.status,
  });

  final TransparencyItem item;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final accent = item.type.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (item.coverImageUrl != null && item.coverImageUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
            child: Image.network(
              item.coverImageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _HeroPlaceholder(accent: accent, icon: item.type.icon),
            ),
          ),
          const SizedBox(height: 16),
        ] else ...[
          _HeroPlaceholder(accent: accent, icon: item.type.icon),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GlassBadge(
              label: item.type.singularLabel,
              color: accent,
              icon: item.type.icon,
            ),
            if (status != null && status!.trim().isNotEmpty)
              GlassBadge(
                label: formatStatusLabel(status!),
                color: statusColor(status!),
                icon: Icons.flag_outlined,
                compact: true,
              ),
          ],
        ),
        if (item.referenceNumber != null) ...[
          const SizedBox(height: 10),
          Text(
            item.referenceNumber!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: glass.textOnGlassMuted,
              fontFamily: 'monospace',
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          item.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: glass.textOnGlass,
          ),
        ),
        if (item.publishedAt != null) ...[
          const SizedBox(height: 12),
          GlassInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Published',
            value: formatTransparencyDate(item.publishedAt),
            labelWidth: 80,
          ),
        ],
      ],
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder({required this.accent, required this.icon});

  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, accent.withValues(alpha: 0.55)],
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 56,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}
