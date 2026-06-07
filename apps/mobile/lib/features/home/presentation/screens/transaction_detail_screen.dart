import 'package:flutter/material.dart';

import '../../../../core/mock/seed_data.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_badge.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final RecentTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return GlassScaffold(
      title: 'Transaction Details',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GlassCard(
            intensity: GlassIntensity.prominent,
            child: Column(
              children: [
                const Icon(Icons.receipt_long, color: AppTheme.secondaryColor, size: 48),
                const SizedBox(height: 16),
                Text(transaction.title, style: TextStyle(color: glass.textOnGlass, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(transaction.amount, style: TextStyle(color: glass.textOnGlass, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                GlassBadge(label: transaction.status, color: AppTheme.secondaryColor),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Date', transaction.date, glass),
                const SizedBox(height: 12),
                _row('Reference', 'LOCAL-${transaction.date.replaceAll(' ', '').replaceAll(',', '')}', glass),
                const SizedBox(height: 12),
                _row('Remarks', 'Offline sample transaction record. Backend activity records will replace this fallback.', glass),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, GlassTheme glass) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 92, child: Text(label, style: TextStyle(color: glass.textOnGlassMuted))),
        Expanded(child: Text(value, style: TextStyle(color: glass.textOnGlass, fontWeight: FontWeight.w600))),
      ],
    );
  }
}
