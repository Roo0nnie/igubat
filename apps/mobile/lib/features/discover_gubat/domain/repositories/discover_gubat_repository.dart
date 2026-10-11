import '../../../../core/usecases/result.dart';
import '../entities/discover_gubat_item.dart';

abstract interface class DiscoverGubatRepository {
  FutureResult<List<DiscoverGubatItem>> list();

  FutureResult<DiscoverGubatItem> getBySlug(String slug);
}
