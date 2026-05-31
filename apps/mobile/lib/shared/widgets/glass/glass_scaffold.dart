import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_tokens.dart';
import 'glass_background.dart';

class GlassScaffold extends StatelessWidget {
  const GlassScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.leading,
    this.floating = false,
    this.showBackgroundBlobs = true,
    this.onRefresh,
    this.bottomPadding = true,
    this.header,
    this.backgroundColor,
    this.useShellBackground = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool floating;
  final bool showBackgroundBlobs;
  final Future<void> Function()? onRefresh;
  /// When [useShellBackground] is true, padding is applied inside scroll views only.
  final bool bottomPadding;
  final Widget? header;
  final Color? backgroundColor;
  final bool useShellBackground;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Do not shrink the viewport above the nav — content must scroll behind it.
    final bottomPad = useShellBackground
        ? 0.0
        : (bottomPadding ? AppLayout.scrollBottomPadding(context) : 0.0);

    Widget content = body;
    if (bottomPad > 0) {
      content = Padding(
        padding: EdgeInsets.only(bottom: bottomPad),
        child: body,
      );
    }

    if (onRefresh != null) {
      content = RefreshIndicator(
        color: GlassTokens.secondaryGreen,
        backgroundColor: Colors.white,
        onRefresh: onRefresh!,
        child: content,
      );
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          _GlassAppBar(
            title: title!,
            leading: leading,
            actions: actions,
            isDark: isDark,
          ),
        if (header != null) header!,
        Expanded(child: content),
      ],
    );

    final bodyChild = useShellBackground
        ? column
        : GlassBackground(showBlobs: showBackgroundBlobs, child: column);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Material(
          type: MaterialType.transparency,
          child: bodyChild,
        ),
      ),
    );
  }
}

class _GlassAppBar extends StatelessWidget {
  const _GlassAppBar({
    required this.title,
    this.leading,
    this.actions,
    required this.isDark,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassTokens.blurMedium,
          sigmaY: GlassTokens.blurMedium,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.primaryColor.withValues(alpha: 0.92)
                : AppTheme.primaryColor.withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: SizedBox(
                height: kToolbarHeight,
                child: NavigationToolbar(
                  leading: leading,
                  middle: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  centerMiddle: true,
                  trailing: actions != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: actions!,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
