import '../../../../core/usecases/result.dart';
import '../entities/service_category.dart';
import '../entities/service_type.dart';

/// Read-only public Services Catalog contract (`/public/services` +
/// `/public/service-categories`).
abstract interface class ServicesRepository {
  /// All service categories, public, no auth.
  FutureResult<List<ServiceCategory>> getCategories();

  /// All service types, public, no auth.
  FutureResult<List<ServiceType>> getServiceTypes();

  /// A single service type by [slug] (detail screen + deep links).
  FutureResult<ServiceType> getServiceTypeBySlug(String slug);
}
