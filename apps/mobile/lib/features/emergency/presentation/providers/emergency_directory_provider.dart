import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/emergency_directory_repository_impl.dart';
import '../../domain/entities/emergency_directory_entry.dart';
import '../../domain/usecases/get_emergency_directory.dart';

/// Live public Emergency Directory entries (TOR Module 7). Backed by the public
/// `/public/emergency-directory` API, with the last saved copy as an offline
/// fallback.
final emergencyDirectoryProvider =
    FutureProvider.autoDispose<List<EmergencyDirectoryEntry>>((ref) async {
      final result =
          await ref.watch(getEmergencyDirectoryUseCaseProvider).call(
            const NoParams(),
          );
      return result.fold((failure) => throw failure, (entries) => entries);
    });

/// Offline state of the directory currently shown: `null` when the data is
/// live, otherwise when the saved copy was last refreshed (may itself be null
/// for an unknown timestamp).
typedef EmergencyOfflineStatus = ({DateTime? savedAt});

final emergencyDirectoryOfflineProvider =
    Provider.autoDispose<EmergencyOfflineStatus?>((ref) {
      final directory = ref.watch(emergencyDirectoryProvider);
      if (!directory.hasValue) return null;
      final repo = ref.watch(emergencyDirectoryRepositoryProvider);
      return repo.servedFromCache ? (savedAt: repo.lastUpdated) : null;
    });
