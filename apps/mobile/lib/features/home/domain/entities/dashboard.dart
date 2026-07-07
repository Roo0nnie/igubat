/// Public dashboard counters shown on the Home "Community Stats" strip.
/// Mirrors the count fields of the backend `/igubat/public/dashboard` response.
class Dashboard {
  const Dashboard({
    required this.totalUsers,
    required this.pendingRequests,
    required this.activeServices,
    required this.newReports,
    required this.publishedAnnouncements,
  });

  final int totalUsers;
  final int pendingRequests;
  final int activeServices;
  final int newReports;
  final int publishedAnnouncements;
}
