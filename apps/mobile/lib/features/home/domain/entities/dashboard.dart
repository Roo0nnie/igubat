/// Public dashboard counters. Mirrors the backend `/igubat/public/dashboard`
/// response.
class Dashboard {
  const Dashboard({
    required this.totalUsers,
    required this.pendingRequests,
    required this.activeServices,
    required this.newReports,
    required this.publishedAnnouncements,
    this.communityStats = const [],
  });

  final int totalUsers;
  final int pendingRequests;
  final int activeServices;
  final int newReports;
  final int publishedAnnouncements;

  /// Home "Community Stats" strip: enabled stats in the order and with the
  /// labels configured by the admin.
  final List<CommunityStat> communityStats;
}

class CommunityStat {
  const CommunityStat({
    required this.key,
    required this.label,
    required this.value,
  });

  /// Backend stat key, e.g. `registered_citizens`.
  final String key;
  final String label;
  final int value;
}
