import 'package:flutter/material.dart';

import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key, required this.title, required this.content});

  final String title;
  final String content;

  factory PolicyScreen.privacy() {
    return const PolicyScreen(
      title: 'Privacy Policy',
      content: 'iGubat collects only the information needed to provide LGU digital services, including profile, contact, barangay, request, report, and uploaded document data. Information is processed according to applicable Philippine data privacy requirements.',
    );
  }

  factory PolicyScreen.terms() {
    return const PolicyScreen(
      title: 'Terms of Use',
      content: 'Use iGubat only for legitimate citizen service requests, reports, emergency information, and public announcements. False submissions may be reviewed by LGU staff and handled according to applicable policy.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);

    return GlassScaffold(
      title: title,
      bottomPadding: false,
      useShellBackground: false,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          GlassCard(
            child: Text(
              content,
              style: TextStyle(color: glass.textOnGlass, fontSize: 15, height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}
