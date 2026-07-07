/// Lifecycle of a citizen-submitted community issue report.
///
/// Top-level enum (no freezed) with a defensive [unknown] member so the UI
/// never crashes on an unexpected wire value. The wire sends snake_case for
/// `in_progress`; everything else matches the member name.
enum CitizenReportStatus {
  received,
  inProgress,
  resolved,
  closed,
  unknown;

  /// Maps the backend `status` string onto a member, falling back to
  /// [CitizenReportStatus.unknown].
  static CitizenReportStatus fromApi(String? value) => switch (value) {
    'received' => CitizenReportStatus.received,
    'in_progress' => CitizenReportStatus.inProgress,
    'resolved' => CitizenReportStatus.resolved,
    'closed' => CitizenReportStatus.closed,
    _ => CitizenReportStatus.unknown,
  };
}
