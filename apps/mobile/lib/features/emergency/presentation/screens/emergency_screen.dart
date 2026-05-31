import 'package:flutter/material.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_list_tile.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  IconData _hotlineIcon(String category) {
    switch (category) {
      case 'Police':
        return Icons.local_police;
      case 'BFP':
        return Icons.local_fire_department;
      case 'Hospital':
        return Icons.local_hospital;
      case 'Disaster':
        return Icons.flood;
      default:
        return Icons.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final hotlines = SeedData.hotlines.where((h) => h.number != '911').toList();

    return GlassScaffold(
      title: 'Emergency Hotlines',
      bottomPadding: true,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          AppLayout.scrollBottomPadding(context),
        ),
        children: [
          GlassSurface(
            intensity: GlassIntensity.prominent,
            borderRadius: BorderRadius.circular(GlassTokens.radiusGlassLg),
            tint: glass.emergencyTint,
            border: Border.all(color: const Color(0xFFB91C1C).withValues(alpha: 0.3)),
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB91C1C).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_rounded, size: 48, color: Color(0xFFB91C1C)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'IN CASE OF EMERGENCY',
                  style: TextStyle(
                    color: Color(0xFFB91C1C),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Call the numbers below immediately if you are in a life-threatening situation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: const Color(0xFFB91C1C).withValues(alpha: 0.85), fontSize: 13),
                ),
                const SizedBox(height: 24),
                GlassButton(
                  label: 'CALL 911 NOW',
                  variant: GlassButtonVariant.emergency,
                  expanded: true,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                GlassButton(
                  label: 'Share Location',
                  variant: GlassButtonVariant.outline,
                  icon: Icons.location_on_outlined,
                  expanded: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Emergency Contacts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: glass.textOnGlass),
          ),
          const SizedBox(height: 16),
          ...hotlines.map(
            (hotline) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCopyableHotline(
                name: hotline.name,
                number: hotline.number,
                icon: _hotlineIcon(hotline.category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
