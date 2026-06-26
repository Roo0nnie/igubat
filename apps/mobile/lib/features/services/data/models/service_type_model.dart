import '../../../../core/utils/json_utils.dart';
import '../../domain/entities/service_type.dart';

/// DTO for a public service type (`/public/services`). Maps to the
/// [ServiceType] entity.
///
/// `requirements`, `formFields` and `workflowSteps` are passed through as raw
/// JSON (whatever the backend sends) and never modelled.
class ServiceTypeModel {
  const ServiceTypeModel({
    required this.id,
    required this.name,
    required this.slug,
    this.categoryId,
    this.description,
    this.requirements,
    this.formFields,
    this.workflowSteps,
    this.processingDays,
    this.icon,
    this.imageUrl,
    this.isPopular = false,
    this.isActive = true,
  });

  final int id;
  final int? categoryId;
  final String name;
  final String slug;
  final String? description;
  final Object? requirements;
  final Object? formFields;
  final Object? workflowSteps;
  final int? processingDays;
  final String? icon;
  final String? imageUrl;
  final bool isPopular;
  final bool isActive;

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: JsonUtils.asInt(json['id']),
      categoryId: json['categoryId'] == null
          ? null
          : JsonUtils.asInt(json['categoryId']),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      // Raw JSON pass-through — shape is owned by the backend.
      requirements: json['requirements'],
      formFields: json['formFields'],
      workflowSteps: json['workflowSteps'],
      processingDays: json['processingDays'] == null
          ? null
          : JsonUtils.asInt(json['processingDays']),
      icon: json['icon'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  ServiceType toEntity() => ServiceType(
    id: id,
    categoryId: categoryId,
    name: name,
    slug: slug,
    description: description,
    requirements: requirements,
    formFields: formFields,
    workflowSteps: workflowSteps,
    processingDays: processingDays,
    icon: icon,
    imageUrl: imageUrl,
    isPopular: isPopular,
    isActive: isActive,
  );
}
