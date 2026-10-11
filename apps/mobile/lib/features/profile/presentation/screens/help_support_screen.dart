import 'package:flutter/material.dart';

import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final articles = [
      ('Submit a service request', 'Open Services, choose the service you need, complete the stepper, and keep the receipt.'),
      ('Track your request', 'Open Recent Transactions or My Applications to view status, timeline, remarks, and documents.'),
      ('Report a community issue', 'Use the issue report form to send category, location, description, and optional photos to the LGU.'),
      ('Emergency help', 'Open Emergency to call COMCEN, BFP, PNP, hospital, or MDRRMO hotlines.'),
    ];

    return GlassScaffold(
      title: 'Help & Support',
      bottomPadding: false,
      useShellBackground: false,
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: articles.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final article = articles[index];
          return GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.$1, style: TextStyle(color: glass.textOnGlass, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(article.$2, style: TextStyle(color: glass.textOnGlassMuted, height: 1.45)),
              ],
            ),
          );
        },
      ),
    );
  }
}
