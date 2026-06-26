import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/service_category.dart';

/// DTO for a public service category (`/public/service-categories`). Maps to the
/// [ServiceCategory] entity.
class ServiceCategoryModel {
  const ServiceCategoryModel({
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

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceCategoryModel(
      id: JsonUtils.asInt(json['id']),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      sortOrder: JsonUtils.asInt(json['sortOrder']),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  ServiceCategory toEntity() => ServiceCategory(
    id: id,
    name: name,
    slug: slug,
    description: description,
    sortOrder: sortOrder,
    isActive: isActive,
  );
}
