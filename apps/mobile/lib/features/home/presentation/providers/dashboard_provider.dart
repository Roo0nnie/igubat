import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/auto_dispose_cache.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/dashboard.dart';
import '../../domain/usecases/get_dashboard.dart';

/// Public dashboard counters for the Home "Community Stats" strip.
final dashboardProvider = FutureProvider.autoDispose<Dashboard>((ref) async {
  final result = await ref
      .watch(getDashboardUseCaseProvider)
      .call(const NoParams());
  final dashboard = result.fold((failure) => throw failure, (value) => value);
  cacheAutoDisposeResult(ref);
  return dashboard;
});
