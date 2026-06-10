import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/transparency_type.dart';
import 'transparency_tile.dart';

/// The Home "Transparency & Good Governance" section: a 2×3 grid of the six
/// content-type tiles. Slotted on Home above the news section with the
/// subtitle "Know where your taxes go."
class TransparencySection extends StatelessWidget {
  const TransparencySection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.6,
      ),
      itemCount: TransparencyType.values.length,
      itemBuilder: (context, index) {
        final type = TransparencyType.values[index];
        return TransparencyTile(
          type: type,
          onTap: () {
            context.push('/transparency/${type.routeSlug}');
          },
        );
      },
    );
  }
}
