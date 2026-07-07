import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/base_repository.dart';
import '../../../../core/usecases/result.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/service_type.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_remote_data_source.dart';

part 'services_repository_impl.g.dart';

class ServicesRepositoryImpl with BaseRepository implements ServicesRepository {
  ServicesRepositoryImpl(this._remote);

  final ServicesRemoteDataSource _remote;

  @override
  FutureResult<List<ServiceCategory>> getCategories() => execute(
    () async => (await _remote.categories()).map((m) => m.toEntity()).toList(),
  );

  @override
  FutureResult<List<ServiceType>> getServiceTypes() => execute(
    () async => (await _remote.serviceTypes()).map((m) => m.toEntity()).toList(),
  );

  @override
  FutureResult<ServiceType> getServiceTypeBySlug(String slug) => execute(
    () async => (await _remote.serviceType(slug)).toEntity(),
  );
}

@riverpod
ServicesRepository servicesRepository(Ref ref) =>
    ServicesRepositoryImpl(ref.watch(servicesRemoteDataSourceProvider));
