import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

part 'get_event.g.dart';

class GetEvent extends UseCase<Event, String> {
  GetEvent(this._repository);

  final EventsRepository _repository;

  @override
  FutureResult<Event> call(String slug) => _repository.getBySlug(slug);
}

@riverpod
GetEvent getEventUseCase(Ref ref) =>
    GetEvent(ref.watch(eventsRepositoryProvider));
