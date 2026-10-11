import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/home/data/models/dashboard_model.dart';

void main() {
  test('parses admin-configured community stats in order', () {
    final dashboard = DashboardModel.fromJson({
      'totalUsers': 12,
      'pendingRequests': 3,
      'activeServices': 9,
      'newReports': 2,
      'publishedAnnouncements': 5,
      'communityStats': [
        {'key': 'published_news', 'label': 'News Posted', 'value': 5},
        {'key': 'registered_citizens', 'label': 'Citizens', 'value': '12'},
      ],
    }).toEntity();

    expect(dashboard.communityStats.map((s) => s.key), [
      'published_news',
      'registered_citizens',
    ]);
    expect(dashboard.communityStats.first.label, 'News Posted');
    expect(dashboard.communityStats.last.value, 12);
  });

  test('tolerates a response without communityStats', () {
    final dashboard = DashboardModel.fromJson({'totalUsers': 1}).toEntity();
    expect(dashboard.communityStats, isEmpty);
  });
}
