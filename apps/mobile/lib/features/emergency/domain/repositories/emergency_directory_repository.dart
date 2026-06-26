import '../../../../core/usecases/result.dart';
import '../entities/emergency_directory_entry.dart';

/// Read-only public Emergency Directory contract (`/public/emergency-directory`).
abstract interface class EmergencyDirectoryRepository {
  /// All emergency directory entries (hotlines, agencies). Public, no auth.
  FutureResult<List<EmergencyDirectoryEntry>> getDirectory();
}
