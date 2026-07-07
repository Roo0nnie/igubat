import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/service_request.dart';
import '../../domain/usecases/cancel_service_request.dart';
import '../../domain/usecases/create_service_request.dart';
import '../../domain/usecases/get_my_requests.dart';
import '../../domain/usecases/get_request.dart';
import '../../domain/usecases/service_request_params.dart';

part 'service_requests_provider.g.dart';

/// Loads and mutates the citizen's `/me/requests` list. Mutations refresh
/// optimistically where safe and fall back to a full reload otherwise.
@riverpod
class ServiceRequestsController extends _$ServiceRequestsController {
  @override
  Future<List<ServiceRequest>> build() async {
    final result =
        await ref.read(getMyRequestsUseCaseProvider).call(const NoParams());
    return result.fold((failure) => throw failure, (requests) => requests);
  }

  /// Submits a new request. On success the created request is prepended to the
  /// list and returned so the caller can show its tracking number; returns
  /// `null` on failure.
  Future<ServiceRequest?> submit(CreateServiceRequestParams params) async {
    final result =
        await ref.read(createServiceRequestUseCaseProvider).call(params);
    return result.fold((_) => null, (created) {
      final current = state.value ?? <ServiceRequest>[];
      state = AsyncData([created, ...current]);
      return created;
    });
  }

  /// Cancels a request, then reloads so the new status/history is reflected.
  /// Returns `true` on success.
  Future<bool> cancelRequest(int id) async {
    final result =
        await ref.read(cancelServiceRequestUseCaseProvider).call(id);
    return result.fold((_) => false, (_) {
      reload();
      return true;
    });
  }

  /// Re-fetches the full list from the backend.
  Future<void> reload() async {
    state = const AsyncLoading();
    final result =
        await ref.read(getMyRequestsUseCaseProvider).call(const NoParams());
    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      AsyncData.new,
    );
  }
}

/// Loads a single request's detail (with attachments + history) by id.
@riverpod
Future<ServiceRequest> serviceRequestDetail(Ref ref, int id) async {
  final result = await ref.read(getRequestUseCaseProvider).call(id);
  return result.fold((failure) => throw failure, (request) => request);
}
