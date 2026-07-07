/// A public service category that groups related [ServiceType]s
/// (`/public/service-categories`).
///
/// Domain entity — pure Dart, no serialization.
class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.sortOrder = 0,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String slug;
  final String? description;
  final int sortOrder;
  final bool isActive;
}
