import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecases/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/emergency_directory_repository_impl.dart';
import '../entities/emergency_directory_entry.dart';
import '../repositories/emergency_directory_repository.dart';

part 'get_emergency_directory.g.dart';

class GetEmergencyDirectory
    extends UseCase<List<EmergencyDirectoryEntry>, NoParams> {
  GetEmergencyDirectory(this._repository);

  final EmergencyDirectoryRepository _repository;

  @override
  FutureResult<List<EmergencyDirectoryEntry>> call(NoParams params) =>
      _repository.getDirectory();
}

@riverpod
GetEmergencyDirectory getEmergencyDirectoryUseCase(Ref ref) =>
    GetEmergencyDirectory(ref.watch(emergencyDirectoryRepositoryProvider));
