import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

class GlassBadge extends StatelessWidget {
  const GlassBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.compact = false,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? GlassTokens.secondaryGreen;

    return GlassSurface(
      intensity: GlassIntensity.subtle,
      borderRadius: BorderRadius.circular(compact ? 8 : 12),
      tint: badgeColor.withValues(alpha: 0.15),
      border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      boxShadow: const [],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 14, color: badgeColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
