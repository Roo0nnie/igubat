import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/event.dart';
import '../../domain/usecases/get_event.dart';
import '../../domain/usecases/list_events.dart';

/// Published municipal events, soonest first. Backed by the public events
/// endpoint.
final eventsListProvider = FutureProvider.autoDispose<List<Event>>((ref) async {
  final result =
      await ref.watch(listEventsUseCaseProvider).call(const NoParams());
  return result.fold((failure) => throw failure, (events) => events);
});

/// A single event resolved by [slug], used by the detail screen.
final eventDetailProvider =
    FutureProvider.autoDispose.family<Event, String>((ref, slug) async {
      final result = await ref.watch(getEventUseCaseProvider).call(slug);
      return result.fold((failure) => throw failure, (event) => event);
    });
