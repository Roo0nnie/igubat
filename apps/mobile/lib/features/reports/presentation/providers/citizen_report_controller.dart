import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/usecases/citizen_report_params.dart';
import '../../domain/usecases/create_report.dart';
import 'my_reports_provider.dart';

part 'citizen_report_controller.g.dart';

/// Drives submission of a new citizen report (`POST /me/reports`).
///
/// [build] holds no state (the form owns its inputs); [submit] performs the
/// create and, on success, invalidates [myReportsProvider] so any list screen
/// refreshes. The method is named `submit` (not `update`/`refresh`, which are
/// reserved on AsyncNotifier).
@riverpod
class CitizenReportController extends _$CitizenReportController {
  @override
  Future<void> build() async {}

  /// Submits [params]. Returns `true` on success, `false` on failure, exposing
  /// the loading/error state via [state] for the calling widget.
  Future<bool> submit(CreateCitizenReportParams params) async {
    state = const AsyncLoading();
    final result = await ref.read(createReportUseCaseProvider).call(params);
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncData(null);
        ref.invalidate(myReportsProvider);
        return true;
      },
    );
  }
}
