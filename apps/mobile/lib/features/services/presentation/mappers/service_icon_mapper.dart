import 'package:flutter/material.dart';

/// Maps a backend service `icon` name (Lucide-style, shared with the web
/// portal) to a Material icon. Unknown names fall back to a generic article.
IconData serviceIconFor(String icon) {
  switch (icon) {
    case 'briefcase':
      return Icons.business_center;
    case 'file-text':
      return Icons.description;
    case 'megaphone':
      return Icons.campaign;
    case 'credit-card':
      return Icons.payment;
    case 'heart':
      return Icons.favorite;
    case 'heart-pulse':
      return Icons.monitor_heart;
    case 'heart-handshake':
      return Icons.volunteer_activism;
    case 'building-2':
      return Icons.apartment;
    case 'bus':
      return Icons.directions_bus;
    case 'badge-check':
      return Icons.verified;
    case 'receipt':
      return Icons.receipt_long;
    case 'hard-hat':
      return Icons.engineering;
    case 'fish':
      return Icons.set_meal;
    case 'scroll-text':
      return Icons.history_edu;
    case 'user-round':
      return Icons.elderly;
    case 'accessibility':
      return Icons.accessible;
    case 'graduation-cap':
      return Icons.school;
    case 'dumbbell':
      return Icons.sports_basketball;
    default:
      return Icons.article;
  }
}
