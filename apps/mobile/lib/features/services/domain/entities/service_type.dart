/// A public LGU service the citizen can browse and request
/// (`/public/services`).
///
/// Domain entity — pure Dart, no serialization. [requirements], [formFields]
/// and [workflowSteps] are kept as raw JSON (the backend defines their shape
/// per service) so each screen reads only what it renders without a rigid model.
class ServiceType {
  const ServiceType({
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

  /// Raw requirements payload (list/map) — intentionally untyped.
  final Object? requirements;

  /// Raw form-field definitions — intentionally untyped.
  final Object? formFields;

  /// Raw workflow-step definitions — intentionally untyped.
  final Object? workflowSteps;

  final int? processingDays;
  final String? icon;
  final String? imageUrl;
  final bool isPopular;
  final bool isActive;
}
