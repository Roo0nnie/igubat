import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'glass_surface.dart';

/// Icon + label + value row for detail screens (transparency, events, requests).
class GlassInfoRow extends StatelessWidget {
  const GlassInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.labelWidth = 72,
    this.iconColor,
    this.valueWidget,
  });

  final IconData icon;
  final String label;
  final String value;
  final double labelWidth;
  final Color? iconColor;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final color = iconColor ?? AppTheme.secondaryColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: TextStyle(color: glass.textOnGlassMuted, fontSize: 13),
          ),
        ),
        Expanded(
          child: valueWidget ??
              Text(
                value,
                style: TextStyle(
                  color: glass.textOnGlass,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
        ),
      ],
    );
  }
}
