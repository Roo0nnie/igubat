import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

/// Compact empty / error card for a Home feed section, with an optional
/// action (e.g. "Retry", "Sign In").
class HomeSectionMessage extends StatelessWidget {
  const HomeSectionMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  /// Standard "could not load" card with a Retry button.
  const HomeSectionMessage.error({
    super.key,
    required this.onAction,
    this.title = 'Couldn\'t load this section',
    this.message = 'Check your internet connection and try again.',
  }) : icon = Icons.cloud_off_outlined,
       actionLabel = 'Retry';

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return GlassCard(
      intensity: GlassIntensity.subtle,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, size: 28, color: glass.textOnGlassMuted),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: glass.textOnGlass,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: glass.textOnGlassMuted,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.secondaryColor,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
