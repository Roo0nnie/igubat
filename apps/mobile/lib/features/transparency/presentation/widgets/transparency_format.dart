// Lightweight formatting helpers for the Transparency surface. The mobile app
// does not depend on `intl`, so dates and peso amounts are formatted manually.

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
