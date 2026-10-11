import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/dashboard.dart';

/// DTO for the public dashboard. The recent-activity arrays are ignored on
/// mobile.
class DashboardModel {
  const DashboardModel({
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
  final List<CommunityStat> communityStats;

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    totalUsers: JsonUtils.asInt(json['totalUsers']),
    pendingRequests: JsonUtils.asInt(json['pendingRequests']),
    activeServices: JsonUtils.asInt(json['activeServices']),
    newReports: JsonUtils.asInt(json['newReports']),
    publishedAnnouncements: JsonUtils.asInt(json['publishedAnnouncements']),
    communityStats: [
      for (final item in (json['communityStats'] as List?) ?? const [])
        if (item is Map)
          CommunityStat(
            key: item['key']?.toString() ?? '',
            label: item['label']?.toString() ?? '',
            value: JsonUtils.asInt(item['value']),
          ),
    ],
  );

  Dashboard toEntity() => Dashboard(
    totalUsers: totalUsers,
    pendingRequests: pendingRequests,
    activeServices: activeServices,
    newReports: newReports,
    publishedAnnouncements: publishedAnnouncements,
    communityStats: communityStats,
  );
}
