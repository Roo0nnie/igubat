import '../../../../core/usecases/result.dart';
import '../entities/emergency_directory_entry.dart';

/// Read-only public Emergency Directory contract (`/public/emergency-directory`).
abstract interface class EmergencyDirectoryRepository {
  /// All emergency directory entries (hotlines, agencies). Public, no auth.
  /// Falls back to the last saved copy when the network is unavailable.
  FutureResult<List<EmergencyDirectoryEntry>> getDirectory();

  /// When the directory was last fetched from the server, if ever.
  DateTime? get lastUpdated;

  /// Whether the most recent [getDirectory] result came from the offline copy.
  bool get servedFromCache;
}
