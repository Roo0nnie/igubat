import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';
import 'glass_surface.dart';

class GlassSearchBar extends StatelessWidget {
  const GlassSearchBar({
    super.key,
    this.hintText = 'Search services, news...',
    this.onChanged,
    this.controller,
    this.margin,
    this.floating = false,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? margin;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return Container(
      margin: margin ?? (floating ? const EdgeInsets.symmetric(horizontal: 24) : null),
      child: GlassSurface(
        intensity: GlassIntensity.prominent,
        borderRadius: BorderRadius.circular(GlassTokens.radiusGlassMd),
        boxShadow: GlassTokens.floatingShadow(),
        tint: floating ? Colors.white.withValues(alpha: 0.95) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(color: glass.textOnGlass, fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: glass.textOnGlassMuted),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: glass.textOnGlassMuted, size: 22),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            isDense: true,
          ),
        ),
      ),
    );
  }
}
