// Lightweight formatting helpers for the Transparency surface. The mobile app
// does not depend on `intl`, so dates and peso amounts are formatted manually.

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/transparency_type.dart';

const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a date-like value as "12 Mar 2026". Accepts [DateTime] or an
/// ISO-8601 / yyyy-MM-dd string; returns the raw string if unparseable.
String formatTransparencyDate(dynamic value) {
  if (value == null) return '';
  final date = value is DateTime ? value : DateTime.tryParse(value.toString());
  if (date == null) return value.toString();
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// Formats a numeric peso amount as "₱4,250,000.00".
String formatPeso(dynamic value) {
  final amount = value is num ? value : num.tryParse(value?.toString() ?? '');
  if (amount == null) return value?.toString() ?? '';
  final fixed = amount.toStringAsFixed(2);
  final parts = fixed.split('.');
  final intPart = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(intPart[i]);
  }
  return '₱$buffer.${parts[1]}';
}

/// Relative "Last updated …" label for the offline cache banner.
String formatRelativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
  if (diff.inHours < 24) return '${diff.inHours} hours ago';
  return '${diff.inDays} days ago';
}

/// Capitalizes a raw status string for display (e.g. `planned` → `Planned`).
String formatStatusLabel(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.length == 1) return trimmed.toUpperCase();
  return trimmed[0].toUpperCase() + trimmed.substring(1).toLowerCase();
}

/// Returns a semantic color for transparency status values.
Color statusColor(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'planned':
    case 'draft':
    case 'pending':
      return const Color(0xFFF59E0B);
    case 'ongoing':
    case 'open':
    case 'active':
    case 'in_progress':
      return const Color(0xFF3B82F6);
    case 'completed':
    case 'awarded':
    case 'closed':
    case 'published':
      return const Color(0xFF10B981);
    case 'cancelled':
    case 'archived':
      return const Color(0xFF6B7280);
    default:
      return AppTheme.secondaryColor;
  }
}

/// Extracts the primary status string from a transparency item's metadata.
String? transparencyStatusOf(
  TransparencyType type,
  Map<String, dynamic> meta,
) {
  switch (type) {
    case TransparencyType.programProject:
      return meta['projectStatus']?.toString();
    case TransparencyType.bidProcurement:
      return meta['bidStatus']?.toString();
    case TransparencyType.financialReport:
    case TransparencyType.annualBudget:
    case TransparencyType.legislativeOrdinance:
    case TransparencyType.executiveOrder:
      return null;
  }
}
