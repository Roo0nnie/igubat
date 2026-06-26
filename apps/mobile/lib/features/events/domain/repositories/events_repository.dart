import '../../../../core/usecases/result.dart';
import '../entities/event.dart';

/// Municipal Events contract (public endpoints, read-only on mobile).
abstract interface class EventsRepository {
  /// Published events, soonest first.
  FutureResult<List<Event>> list();

  /// A single event resolved by [slug] (with full [Event.description]).
  FutureResult<Event> getBySlug(String slug);
}
