import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';

class GlassBackground extends StatefulWidget {
  const GlassBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
  });

  final Widget child;
  final bool showBlobs;

  @override
  State<GlassBackground> createState() => _GlassBackgroundState();
}

class _GlassBackgroundState extends State<GlassBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    if (widget.showBlobs) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [glass.gradientStart, glass.gradientMid, glass.gradientEnd],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.showBlobs && !disableAnimations)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Stack(
                  children: [
                    Positioned(
                      top: -60 + (_controller.value * 20),
                      right: -40,
                      child: _Blob(
                        size: 200,
                        color: GlassTokens.secondaryGreen.withValues(alpha: 0.12),
                      ),
                    ),
                    Positioned(
                      bottom: 120 - (_controller.value * 30),
                      left: -60,
                      child: _Blob(
                        size: 160,
                        color: GlassTokens.primaryGreen.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                );
              },
            ),
          widget.child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
