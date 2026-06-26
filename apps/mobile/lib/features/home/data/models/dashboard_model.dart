import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/dashboard.dart';

/// DTO for the public dashboard. Only the count fields are modelled; the
/// recent-activity arrays are ignored on mobile.
class DashboardModel {
  const DashboardModel({
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

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    totalUsers: JsonUtils.asInt(json['totalUsers']),
    pendingRequests: JsonUtils.asInt(json['pendingRequests']),
    activeServices: JsonUtils.asInt(json['activeServices']),
    newReports: JsonUtils.asInt(json['newReports']),
    publishedAnnouncements: JsonUtils.asInt(json['publishedAnnouncements']),
  );

  Dashboard toEntity() => Dashboard(
    totalUsers: totalUsers,
    pendingRequests: pendingRequests,
    activeServices: activeServices,
    newReports: newReports,
    publishedAnnouncements: publishedAnnouncements,
  );
}
