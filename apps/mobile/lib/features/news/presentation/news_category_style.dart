import 'package:flutter/material.dart';

import '../../../core/theme/glass_tokens.dart';

Color newsCategoryColor(String category) {
  switch (category) {
    case 'Business':
      return const Color(0xFF2563EB);
    case 'Health':
      return const Color(0xFF059669);
    case 'Infrastructure':
      return const Color(0xFFD97706);
    default:
      return GlassTokens.accentGreen;
  }
}

IconData newsCategoryIcon(String category) {
  switch (category) {
    case 'Business':
      return Icons.storefront_rounded;
    case 'Health':
      return Icons.health_and_safety_rounded;
    case 'Infrastructure':
      return Icons.construction_rounded;
    default:
      return Icons.campaign_rounded;
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatNewsDate(DateTime? date) {
  if (date == null) return '';
  final local = date.toLocal();
  return '${_months[local.month - 1]} ${local.day}, ${local.year}';
}
