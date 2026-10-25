import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/auto_dispose_cache.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/citizen_report.dart';
import '../../domain/usecases/get_my_reports.dart';
import '../../domain/usecases/get_report_by_id.dart';

/// The signed-in citizen's submitted reports (`GET /me/reports`), most recent
/// first as returned by the backend.
final myReportsProvider =
    FutureProvider.autoDispose<List<CitizenReport>>((ref) async {
      final result =
          await ref.watch(getMyReportsUseCaseProvider).call(const NoParams());
      final reports = result.fold((failure) => throw failure, (value) => value);
      cacheAutoDisposeResult(ref);
      return reports;
    });

/// A single citizen report resolved by [id] (`GET /me/reports/:id`), used by
/// the report detail screen.
final reportDetailProvider =
    FutureProvider.autoDispose.family<CitizenReport, int>((ref, id) async {
      final result =
          await ref.watch(getReportByIdUseCaseProvider).call(id);
      return result.fold((failure) => throw failure, (report) => report);
    });
