import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../entities/event.dart';
import '../repositories/events_repository.dart';

part 'list_events.g.dart';

class ListEvents extends UseCase<List<Event>, NoParams> {
  ListEvents(this._repository);

  final EventsRepository _repository;

  @override
  FutureResult<List<Event>> call(NoParams params) => _repository.list();
}

@riverpod
ListEvents listEventsUseCase(Ref ref) =>
    ListEvents(ref.watch(eventsRepositoryProvider));
