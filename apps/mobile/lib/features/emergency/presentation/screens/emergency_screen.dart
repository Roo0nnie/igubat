import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_list_tile.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_skeleton.dart';
import '../../../../shared/widgets/glass/glass_slide_to_call.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../../../shared/widgets/states/app_state_views.dart';
import '../../data/emergency_service.dart';
import '../../domain/entities/emergency_directory_entry.dart';
import '../providers/emergency_directory_provider.dart';

/// Maps a live [EmergencyType] to the category string the existing screen uses
/// for its COMCEN section, filter chips, subtitle, and icon logic — so the live
/// directory feeds the unchanged UI exactly like the former seed [Hotline]s.
String _categoryOf(EmergencyType type) {
  switch (type) {
    case EmergencyType.police:
      return 'Police';
    case EmergencyType.bfp:
      return 'BFP';
    case EmergencyType.hospital:
      return 'Hospital';
    case EmergencyType.comcen:
      return 'COMCEN';
    case EmergencyType.disasterResponse:
      return 'Disaster';
    case EmergencyType.unknown:
      return 'Other';
  }
}

/// Adapts a live [EmergencyDirectoryEntry] to the existing [Hotline] view-model
/// the screen already renders, preserving the name/number/address/hours layout.
Hotline _asHotline(EmergencyDirectoryEntry entry) => Hotline(
  name: entry.name,
  number: entry.contactNumber,
  category: _categoryOf(entry.type),
  address: entry.address,
  hours: entry.hours,
);

/// Emergency Hotline and Directory (TOR Module 7).
///
/// Guest-accessible screen that lets a citizen:
/// - slide-to-call the national 911 hotline (a deliberate gesture, not a tap),
/// - one-tap call or copy the COMCEN hotlines (Smart, TNT, Landline),
/// - browse the agency directory (Police, BFP, Hospital, Disaster) by category,
/// - one-tap call or copy any directory number,
/// - open the Municipality of Igubat on a map for reference (this does not
///   read or share the citizen's own device location).
class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
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
  List<Hotline> _comcen(List<Hotline> hotlines) =>
      hotlines.where((h) => h.category == 'COMCEN').toList();

  List<Hotline> _directory(List<Hotline> hotlines) {
    // The standalone 911 hotline lives in the call-to-action card above and the
    // COMCEN numbers have their own section, so both are excluded from the
    // browsable agency directory.
    final entries = hotlines
        .where((h) => h.number != '911' && h.category != 'COMCEN');
    if (_selectedCategory == 'All') return entries.toList();
    return entries.where((h) => h.category == _selectedCategory).toList();
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

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _savedLabel(DateTime? savedAt) {
    if (savedAt == null) return 'Showing numbers saved on this phone.';
    final t = savedAt.toLocal();
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'AM' : 'PM';
    return 'Showing numbers saved on ${_months[t.month - 1]} ${t.day}, ${t.year} at $hour:$minute $period.';
  }

  Widget _offlineBanner(DateTime? savedAt, GlassTheme glass) {
    const amber = Color(0xFFD97706);
    final accent = glass.readable(amber);
    return Semantics(
      liveRegion: true,
      child: GlassSurface(
        intensity: GlassIntensity.subtle,
        borderRadius: BorderRadius.circular(16),
        tint: amber.withValues(alpha: 0.12),
        border: Border.all(color: amber.withValues(alpha: 0.45)),
        boxShadow: const [],
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.cloud_off_rounded, color: accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You're offline",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: glass.textOnGlass,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_savedLabel(savedAt)} Calling still works without internet.',
                    style: TextStyle(fontSize: 13, height: 1.4, color: glass.textOnGlassMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leadingIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _hotlineTile({
    required Hotline hotline,
    required String subtitle,
    required IconData icon,
    required GlassTheme glass,
  }) {
    return GlassListTile(
      title: hotline.name,
      subtitle: subtitle,
      onTap: () => EmergencyService.call(context, hotline.number),
      leading: _leadingIcon(icon, glass.dangerOnGlass),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Copy ${hotline.number}',
            onPressed: () => _copyNumber(hotline.number),
            icon: Icon(Icons.copy_rounded, color: glass.textOnGlassMuted, size: 20),
          ),
          IconButton.filled(
            tooltip: 'Call ${hotline.name}',
            onPressed: () => EmergencyService.call(context, hotline.number),
            style: IconButton.styleFrom(backgroundColor: _emergencyRed),
            icon: const Icon(Icons.call_rounded, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final asyncDirectory = ref.watch(emergencyDirectoryProvider);
    // Live entries adapted to the existing Hotline view-model; empty while the
    // directory is loading or failed (the static 911 / map card stays usable).
    final hotlines = asyncDirectory.maybeWhen(
      data: (entries) => entries.map(_asHotline).toList(),
      orElse: () => const <Hotline>[],
    );
    final comcen = _comcen(hotlines);
    final directory = _directory(hotlines);
    final offline = ref.watch(emergencyDirectoryOfflineProvider);

    return GlassScaffold(
      title: 'Emergency Hotlines',
      bottomPadding: true,
      onRefresh: () async {
        ref.invalidate(emergencyDirectoryProvider);
        await ref.read(emergencyDirectoryProvider.future);
      },
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          AppLayout.scrollBottomPadding(context),
        ),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              gradient: GlassTokens.emergencyGradient,
              borderRadius: BorderRadius.circular(GlassTokens.radiusGlassLg),
              boxShadow: GlassTokens.ambientShadow(color: _emergencyRed, opacity: 0.3),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.warning_rounded, size: 32, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'In case of emergency',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'If a life is in danger, call 911 right away.',
                            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GlassSlideToCall(
                  // The deliberate slide gesture is itself the safety
                  // affordance (User Story 7.1): completing it initiates the
                  // tel: action immediately, with no second confirmation.
                  label: 'Slide to call 911',
                  onColoredBackground: true,
                  onSlideComplete: () => EmergencyService.call(context, '911'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Drag the phone button to the right to start the call.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassListTile(
            title: 'Municipality Map',
            subtitle: 'Open Igubat in your maps app',
            onTap: () => EmergencyService.openMunicipalityMap(context),
            leading: _leadingIcon(Icons.map_outlined, glass.brandOnGlass),
            trailing: Icon(Icons.open_in_new_rounded, color: glass.textOnGlassMuted, size: 20),
            onTrailingTap: () => EmergencyService.openMunicipalityMap(context),
          ),
          if (offline != null) ...[
            const SizedBox(height: 12),
            _offlineBanner(offline.savedAt, glass),
          ],
          const SizedBox(height: 28),
          Text(
            'COMCEN Hotlines',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: glass.textOnGlass),
          ),
          const SizedBox(height: 4),
          Text(
            'Community Emergency Communications Center — reachable on any carrier. Tap a number to call.',
            style: TextStyle(color: glass.textOnGlassMuted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          if (asyncDirectory.isLoading && comcen.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ExcludeSemantics(child: GlassSkeletonList(count: 2)),
            ),
          ...comcen.map(
            (hotline) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              // One-tap dial for COMCEN hotlines (User Story 7.2).
              child: _hotlineTile(
                hotline: hotline,
                subtitle: hotline.number,
                icon: Icons.headset_mic,
                glass: glass,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Emergency Contacts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: glass.textOnGlass),
          ),
          const SizedBox(height: 4),
          Text(
            'Police, fire, hospitals, and disaster response in Gubat.',
            style: TextStyle(color: glass.textOnGlassMuted, fontSize: 13, height: 1.4),
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
                  backgroundColor: glass.surfaceMedium,
                  side: BorderSide(
                    color: selected ? _emergencyRed : glass.textOnGlassMuted.withValues(alpha: 0.35),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (asyncDirectory.isLoading && hotlines.isEmpty)
            LoadingStateView(
              message: 'Loading emergency contacts...',
              skeleton: const GlassSkeletonList(count: 4),
              onRetry: () => ref.invalidate(emergencyDirectoryProvider),
            )
          else if (asyncDirectory.hasError && hotlines.isEmpty)
            ErrorStateView(
              title: 'Unable to load contacts',
              message:
                  '${friendlyErrorMessage(asyncDirectory.error)} You can still slide to call 911 above. '
                  'Once you connect, these numbers are saved on your phone for offline use.',
              onRetry: () => ref.invalidate(emergencyDirectoryProvider),
            )
          else if (directory.isEmpty)
            EmptyStateView(
              icon: Icons.contact_phone_outlined,
              title: 'No contacts in this category',
              message: 'Choose "All" or another category to see more numbers.',
            )
          else
            ...directory.map(
              (hotline) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                // Tap-to-call directory entries (User Story 7.3).
                child: _hotlineTile(
                  hotline: hotline,
                  subtitle: _directorySubtitle(hotline),
                  icon: _hotlineIcon(hotline.category),
                  glass: glass,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
