import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

class GlassListTile extends StatelessWidget {
  const GlassListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onTrailingTap,
    this.intensity = GlassIntensity.medium,
    this.highlightColor,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onTrailingTap;
  final GlassIntensity intensity;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return GlassSurface(
      intensity: intensity,
      borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
      tint: highlightColor,
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.s16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: glass.textOnGlass,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: glass.textOnGlassMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailingTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: trailing,
              ),
            ),
        ],
      ),
    );
  }
}

class GlassCopyableHotline extends StatelessWidget {
  const GlassCopyableHotline({
    super.key,
    required this.name,
    required this.number,
    required this.icon,
    this.iconColor,
  });

  final String name;
  final String number;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? const Color(0xFFB91C1C);

    return GlassListTile(
      title: name,
      subtitle: number,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      trailing: Icon(Icons.copy, color: glassThemeOf(context).textOnGlassMuted, size: 20),
      onTrailingTap: () {
        Clipboard.setData(ClipboardData(text: number));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Copied $number'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
