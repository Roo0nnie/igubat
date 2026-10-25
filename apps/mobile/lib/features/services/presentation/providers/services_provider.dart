import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/auto_dispose_cache.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/service_category.dart';
import '../../domain/entities/service_type.dart';
import '../../domain/usecases/get_service_categories.dart';
import '../../domain/usecases/get_service_type_by_slug.dart';
import '../../domain/usecases/get_service_types.dart';

/// Live public service types (`/public/services`), replacing the seed catalog.
final serviceTypesProvider =
    FutureProvider.autoDispose<List<ServiceType>>((ref) async {
      final result =
          await ref.watch(getServiceTypesUseCaseProvider).call(const NoParams());
      final types = result.fold((failure) => throw failure, (value) => value);
      cacheAutoDisposeResult(ref);
      return types;
    });

/// Live public service categories (`/public/service-categories`), used for the
/// catalog filter chips.
final serviceCategoriesProvider =
    FutureProvider.autoDispose<List<ServiceCategory>>((ref) async {
      final result = await ref
          .watch(getServiceCategoriesUseCaseProvider)
          .call(const NoParams());
      final categories = result.fold(
        (failure) => throw failure,
        (value) => value,
      );
      cacheAutoDisposeResult(ref);
      return categories;
    });

/// A single service type by slug (`/public/services/:slug`) for detail screens.
final serviceTypeBySlugProvider =
    FutureProvider.autoDispose.family<ServiceType, String>((ref, slug) async {
      final result =
          await ref.watch(getServiceTypeBySlugUseCaseProvider).call(slug);
      return result.fold((failure) => throw failure, (type) => type);
    });
