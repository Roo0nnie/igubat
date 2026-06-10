import 'package:flutter/material.dart';

import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../data/models/transparency_type.dart';

/// One of the six Home-grid cards. Meets the ≥44×44 px tap-target guideline
/// and routes to the matching category list on tap.
class TransparencyTile extends StatelessWidget {
  const TransparencyTile({super.key, required this.type, required this.onTap});

  final TransparencyType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: type.accentColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(type.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              type.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: glassThemeOf(context).textOnGlass,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
