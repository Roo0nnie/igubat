import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../core/theme/app_theme.dart';
import 'glass_surface.dart';

/// Themed markdown body for detail screens. Shrink-wrapped (no nested scroll).
class GlassMarkdownBody extends StatelessWidget {
  const GlassMarkdownBody({
    super.key,
    required this.data,
    this.selectable = true,
  });

  final String data;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final baseStyle = TextStyle(
      color: glass.textOnGlass,
      fontSize: 15,
      height: 1.55,
    );

    final styleSheet = MarkdownStyleSheet(
      p: baseStyle,
      h1: baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppTheme.primaryColor,
      ),
      h2: baseStyle.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryColor,
      ),
      h3: baseStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: glass.textOnGlass,
      ),
      listBullet: baseStyle,
      blockquote: baseStyle.copyWith(
        color: glass.textOnGlassMuted,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: AppTheme.secondaryColor, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
      a: baseStyle.copyWith(
        color: AppTheme.secondaryColor,
        decoration: TextDecoration.underline,
      ),
      strong: baseStyle.copyWith(fontWeight: FontWeight.w700),
      em: baseStyle.copyWith(fontStyle: FontStyle.italic),
      code: baseStyle.copyWith(
        fontFamily: 'monospace',
        fontSize: 13,
        backgroundColor: glass.textOnGlassMuted.withValues(alpha: 0.1),
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: glass.border, width: 1),
        ),
      ),
    );

    return MarkdownBody(
      data: data,
      selectable: selectable,
      shrinkWrap: true,
      styleSheet: styleSheet,
    );
  }
}
