import 'package:flutter/material.dart';
import 'glass/glass_card.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.onTap,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: padding == EdgeInsets.zero ? null : padding,
      margin: margin == EdgeInsets.zero ? null : margin,
      child: child,
    );
  }
}
