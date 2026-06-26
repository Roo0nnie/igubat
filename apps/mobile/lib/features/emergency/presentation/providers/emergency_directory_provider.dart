import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/emergency_directory_entry.dart';
import '../../domain/usecases/get_emergency_directory.dart';

/// Live public Emergency Directory entries (TOR Module 7). Backed by the public
/// `/public/emergency-directory` API, replacing the former seed hotlines.
final emergencyDirectoryProvider =
    FutureProvider.autoDispose<List<EmergencyDirectoryEntry>>((ref) async {
      final result =
          await ref.watch(getEmergencyDirectoryUseCaseProvider).call(
            const NoParams(),
          );
      return result.fold((failure) => throw failure, (entries) => entries);
    });
