import '../../../../core/usecases/result.dart';
import '../../data/models/transparency_type.dart';
import '../entities/transparency_attachment.dart';
import '../entities/transparency_item.dart';

/// Read-only Transparency & Good Governance contract.
abstract interface class TransparencyRepository {
  /// Latest published items for [type], most recent first. Falls back to the
  /// offline cache then seed data, so this never fails.
  FutureResult<List<TransparencyItem>> listByType(TransparencyType type);

  /// A single item by slug (detail screen + notification deep links).
  FutureResult<TransparencyItem?> getBySlug(String slug);

  /// Downloads an attachment to the app cache and returns a local (or remote
  /// fallback) URI to open.
  FutureResult<Uri> cacheAttachment(TransparencyAttachment attachment);

  /// "Last updated" timestamp for a type's cached list, if known.
  DateTime? lastUpdatedFor(TransparencyType type);

  /// Whether the current list data for [type] came from the offline cache.
  bool wasCachedFor(TransparencyType type);
}
