import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_remote_data_source.dart';

part 'events_repository_impl.g.dart';

class EventsRepositoryImpl with BaseRepository implements EventsRepository {
  EventsRepositoryImpl(this._remote);

  final EventsRemoteDataSource _remote;

  @override
  FutureResult<List<Event>> list() => execute(
    () async => (await _remote.list()).map((m) => m.toEntity()).toList(),
  );

  @override
  FutureResult<Event> getBySlug(String slug) =>
      execute(() async => (await _remote.getBySlug(slug)).toEntity());
}

@riverpod
EventsRepository eventsRepository(Ref ref) =>
    EventsRepositoryImpl(ref.watch(eventsRemoteDataSourceProvider));
