import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _pushNotifications = true;

  IconData _badgeIcon(String icon) {
    switch (icon) {
      case 'star':
        return Icons.star_outline;
      case 'verified':
        return Icons.verified_outlined;
      case 'community':
        return Icons.groups_outlined;
      default:
        return Icons.emoji_events_outlined;
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(authStateProvider.notifier).signOut();
    if (!mounted) return;

    // Sign-out happens from the Profile tab, an authenticated-only surface.
    // Return the now-unauthenticated user to the public Home surface instead
    // of leaving them stranded on account management.
    context.go(AppRoutes.home);

    toastification.show(
      title: const Text('Signed out successfully'),
      type: ToastificationType.success,
      autoCloseDuration: const Duration(seconds: 2),
      style: ToastificationStyle.flat,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = ref.watch(currentUserProvider);
    final glass = glassThemeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (authState.isLoading && user == null) {
      return GlassScaffold(
        title: 'My Profile',
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final displayName = user?.name ?? 'Citizen';
    final displayEmail = user?.email ?? '';
    final avatarLabel = displayName.isNotEmpty
        ? displayName.characters.first.toUpperCase()
        : '?';

    return GlassScaffold(
      title: 'My Profile',
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          AppLayout.scrollBottomPadding(context),
        ),
        children: [
          GlassCard(
            intensity: GlassIntensity.prominent,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.secondaryColor, width: 3),
                      ),
                    ),
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.primaryColor,
                      child: user?.image != null
                          ? null
                          : Text(
                              avatarLabel,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: glass.textOnGlass,
                  ),
                ),
                if (displayEmail.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    displayEmail,
                    style: TextStyle(color: glass.textOnGlassMuted),
                  ),
                ],
                const SizedBox(height: 16),
                GlassButton(
                  label: 'Edit Profile',
                  variant: GlassButtonVariant.outline,
                  icon: Icons.edit_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GlassCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: glass.textOnGlass,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        SeedData.currentUser.verificationLevel,
                        style: TextStyle(fontSize: 12, color: glass.textOnGlassMuted),
                      ),
                    ],
                  ),
                ),
                GlassBadge(
                  label: 'Verified',
                  color: AppTheme.secondaryColor,
                  icon: Icons.verified,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Achievements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: glass.textOnGlass),
          ),
          const SizedBox(height: 12),
          Row(
            children: SeedData.achievementBadges.map((badge) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: badge != SeedData.achievementBadges.last ? 8 : 0,
                  ),
                  child: GlassCard(
                    intensity: GlassIntensity.subtle,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Column(
                      children: [
                        Icon(_badgeIcon(badge.icon), color: AppTheme.secondaryColor, size: 22),
                        const SizedBox(height: 6),
                        Text(
                          badge.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: glass.textOnGlassMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Settings & Preferences',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: glass.textOnGlass),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _settingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  glass: glass,
                  trailing: Switch(
                    value: _pushNotifications,
                    onChanged: (v) => setState(() => _pushNotifications = v),
                    activeTrackColor: AppTheme.secondaryColor,
                  ),
                ),
                Divider(height: 1, color: glass.border),
                _settingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  glass: glass,
                  trailing: Switch(
                    value: isDark,
                    onChanged: (v) {
                      ref.read(themeModeProvider.notifier).setThemeMode(
                            v ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                    activeTrackColor: AppTheme.secondaryColor,
                  ),
                ),
                Divider(height: 1, color: glass.border),
                _settingsTile(icon: Icons.language, title: 'Language (English)', glass: glass),
                Divider(height: 1, color: glass.border),
                _settingsTile(icon: Icons.help_outline, title: 'Help & Support', glass: glass),
                Divider(height: 1, color: glass.border),
                _settingsTile(icon: Icons.privacy_tip_outlined, title: 'Privacy Policy', glass: glass),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassSurface(
            intensity: GlassIntensity.subtle,
            borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
            tint: const Color(0xFFB91C1C).withValues(alpha: 0.08),
            border: Border.all(color: const Color(0xFFB91C1C).withValues(alpha: 0.4)),
            onTap: _handleSignOut,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFFB91C1C),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required GlassTheme glass,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: glass.textOnGlassMuted),
      title: Text(title, style: TextStyle(fontSize: 15, color: glass.textOnGlass)),
      trailing: trailing ?? Icon(Icons.chevron_right, color: glass.textOnGlassMuted),
      onTap: trailing == null ? () {} : null,
      minVerticalPadding: 12,
    );
  }
}
