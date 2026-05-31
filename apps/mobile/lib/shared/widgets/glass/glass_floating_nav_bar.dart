import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_tokens.dart';

class GlassNavItem {
  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class GlassFloatingNavBar extends StatelessWidget {
  const GlassFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;

  static const defaultItems = [
    GlassNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    GlassNavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view, label: 'Services'),
    GlassNavItem(icon: Icons.article_outlined, activeIcon: Icons.article, label: 'News'),
    GlassNavItem(icon: Icons.warning_amber_rounded, activeIcon: Icons.warning_rounded, label: 'Emergency'),
    GlassNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  static const double _tabHighlightRadius = 14;
  static const double _tabHorizontalInset = 6;
  static const double _innerVerticalPadding = 6.0;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>() ?? GlassTheme.light;
    final borderRadius = BorderRadius.circular(AppLayout.navBorderRadius);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: AppLayout.navHorizontalMargin,
        right: AppLayout.navHorizontalMargin,
        bottom: AppLayout.navBottomInset + bottomInset,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          height: AppLayout.navHeight,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: GlassTokens.floatingShadow(color: GlassTokens.primaryGreen),
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: GlassTokens.blurMedium,
                sigmaY: GlassTokens.blurMedium,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: glass.navTint,
                  borderRadius: borderRadius,
                  border: Border.all(color: glass.border),
                ),
                padding: const EdgeInsets.all(_innerVerticalPadding),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final trackHeight = constraints.maxHeight;
                    final itemWidth = constraints.maxWidth / items.length;
                    final highlightWidth = itemWidth - (_tabHorizontalInset * 2);

                    return SizedBox(
                      height: trackHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          AnimatedPositioned(
                            duration: AppMotion.navIndicatorDuration,
                            curve: AppMotion.navIndicatorCurve,
                            left: currentIndex * itemWidth + _tabHorizontalInset,
                            top: 0,
                            bottom: 0,
                            width: highlightWidth,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(_tabHighlightRadius),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: List.generate(items.length, (index) {
                                return Expanded(
                                  child: _NavTab(
                                    item: items[index],
                                    isActive: index == currentIndex,
                                    onTap: () {
                                      if (index != currentIndex) {
                                        HapticFeedback.lightImpact();
                                        onTap(index);
                                      }
                                    },
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final GlassNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive
        ? AppTheme.primaryColor
        : Colors.white.withValues(alpha: 0.72);
    final labelColor = isActive
        ? AppTheme.primaryColor
        : Colors.white.withValues(alpha: 0.62);

    return Semantics(
      label: item.label,
      selected: isActive,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GlassFloatingNavBar._tabHighlightRadius),
          splashColor: AppTheme.primaryColor.withValues(alpha: 0.08),
          highlightColor: AppTheme.primaryColor.withValues(alpha: 0.04),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: iconColor,
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.1,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: labelColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
