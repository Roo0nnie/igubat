import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/base_remote_data_source.dart';
import '../../../../core/network/dio_client.dart';
import '../models/event_model.dart';

part 'events_remote_data_source.g.dart';

/// Talks to the public events endpoints. List + by-slug detail, read-only.
class EventsRemoteDataSource with BaseRemoteDataSource {
  EventsRemoteDataSource(this._client);

  final DioClient _client;

  Future<List<EventModel>> list() => guard(
    () => _client.getList(ApiConstants.publicEvents, EventModel.fromJson),
  );

  Future<EventModel> getBySlug(String slug) => guard(
    () => _client.getOne(ApiConstants.publicEvent(slug), EventModel.fromJson),
  );
}

@riverpod
EventsRemoteDataSource eventsRemoteDataSource(Ref ref) =>
    EventsRemoteDataSource(ref.watch(dioClientProvider));
