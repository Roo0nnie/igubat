import 'package:flutter/material.dart';

import '../../core/theme/app_styles.dart';
import 'glass/glass_background.dart';
import 'glass/glass_floating_nav_bar.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/services/presentation/screens/services_screen.dart';
import '../../features/news/presentation/screens/news_screen.dart';
import '../../features/emergency/presentation/screens/emergency_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ServicesScreen(),
    NewsScreen(),
    EmergencyScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        showBlobs: true,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: AppMotion.durationStandard,
                switchInCurve: AppMotion.pageTransitionCurve,
                switchOutCurve: AppMotion.transitionCurve,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: _screens[_currentIndex],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GlassFloatingNavBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                items: GlassFloatingNavBar.defaultItems,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
