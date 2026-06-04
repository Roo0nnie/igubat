import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_list_tile.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_slide_to_call.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../data/emergency_service.dart';

/// Emergency Hotline and Directory (TOR Module 7).
///
/// Guest-accessible screen that lets a citizen:
/// - slide-to-call the national 911 hotline (a deliberate gesture, not a tap),
/// - one-tap call or copy the COMCEN hotlines (Smart, TNT, Landline),
/// - browse the agency directory (Police, BFP, Hospital, Disaster) by category,
/// - one-tap call or copy any directory number,
/// - open the Municipality of Igubat on a map for reference (this does not
///   read or share the citizen's own device location).
class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  static const Color _emergencyRed = Color(0xFFB91C1C);

  /// Category shortcuts required by the TOR, mapped to the seed categories.
  static const List<String> _categories = [
    'All',
    'Police',
    'BFP',
    'Hospital',
    'Disaster',
  ];

  String _selectedCategory = 'All';

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

  String _categoryLabel(String category) {
    switch (category) {
      case 'Police':
        return 'Police (PNP)';
      case 'BFP':
        return 'Fire (BFP)';
      case 'Hospital':
        return 'Hospitals';
      case 'Disaster':
        return 'Disaster';
      default:
        return 'All';
    }
  }

  /// COMCEN (Community Emergency Communications Center) hotlines, surfaced in
  /// their own card so a citizen can reach the center regardless of carrier
  /// (User Story 7.2).
  List<Hotline> get _comcen =>
      SeedData.hotlines.where((h) => h.category == 'COMCEN').toList();

  List<Hotline> get _directory {
    // The standalone 911 hotline lives in the call-to-action card above and the
    // COMCEN numbers have their own section, so both are excluded from the
    // browsable agency directory.
    final hotlines = SeedData.hotlines
        .where((h) => h.number != '911' && h.category != 'COMCEN');
    if (_selectedCategory == 'All') return hotlines.toList();
    return hotlines.where((h) => h.category == _selectedCategory).toList();
  }

  /// Builds the directory subtitle showing the contact number plus the
  /// address and operating hours required by TOR Module 7, each on its own
  /// line and omitting any field the entry does not provide.
  String _directorySubtitle(Hotline hotline) {
    final lines = <String>[hotline.number];
    if (hotline.address != null && hotline.address!.isNotEmpty) {
      lines.add(hotline.address!);
    }
    if (hotline.hours != null && hotline.hours!.isNotEmpty) {
      lines.add('Hours: ${hotline.hours!}');
    }
    return lines.join('\n');
  }

  void _copyNumber(String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Copied $number'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final directory = _directory;

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
            border: Border.all(color: _emergencyRed.withValues(alpha: 0.3)),
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _emergencyRed.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_rounded, size: 48, color: _emergencyRed),
                ),
                const SizedBox(height: 16),
                const Text(
                  'IN CASE OF EMERGENCY',
                  style: TextStyle(
                    color: _emergencyRed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Call the numbers below immediately if you are in a life-threatening situation.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _emergencyRed.withValues(alpha: 0.85), fontSize: 13),
                ),
                const SizedBox(height: 24),
                GlassSlideToCall(
                  // The deliberate slide gesture is itself the safety
                  // affordance (User Story 7.1): completing it initiates the
                  // tel: action immediately, with no second confirmation.
                  label: 'Slide to call 911',
                  onSlideComplete: () => EmergencyService.call(context, '911'),
                ),
                const SizedBox(height: 12),
                GlassButton(
                  label: 'View Municipality Map',
                  variant: GlassButtonVariant.outline,
                  icon: Icons.map_outlined,
                  expanded: true,
                  onPressed: () => EmergencyService.openMunicipalityMap(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'COMCEN Hotlines',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: glass.textOnGlass),
          ),
          const SizedBox(height: 4),
          Text(
            'Community Emergency Communications Center — reachable on any carrier.',
            style: TextStyle(color: glass.textOnGlassMuted, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ..._comcen.map(
            (hotline) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassListTile(
                title: hotline.name,
                subtitle: hotline.number,
                // One-tap dial for COMCEN hotlines (User Story 7.2).
                onTap: () => EmergencyService.call(context, hotline.number),
                onTrailingTap: () => _copyNumber(hotline.number),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _emergencyRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.headset_mic, color: _emergencyRed, size: 22),
                ),
                trailing: Icon(Icons.copy, color: glass.textOnGlassMuted, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Emergency Contacts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: glass.textOnGlass),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final selected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(_categoryLabel(category)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : glass.textOnGlass,
                  ),
                  selectedColor: _emergencyRed,
                  backgroundColor: glass.border.withValues(alpha: 0.4),
                  side: BorderSide(color: glass.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (directory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No contacts in this category.',
                  style: TextStyle(color: glass.textOnGlassMuted),
                ),
              ),
            )
          else
            ...directory.map(
              (hotline) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassListTile(
                  title: hotline.name,
                  subtitle: _directorySubtitle(hotline),
                  // Tap-to-call directory entries (User Story 7.3).
                  onTap: () => EmergencyService.call(context, hotline.number),
                  onTrailingTap: () => _copyNumber(hotline.number),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _emergencyRed.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_hotlineIcon(hotline.category), color: _emergencyRed, size: 22),
                  ),
                  trailing: Icon(Icons.copy, color: glass.textOnGlassMuted, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
