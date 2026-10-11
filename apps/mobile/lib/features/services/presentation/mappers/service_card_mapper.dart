import '../../../../core/mock/seed_data.dart' show Service;
import '../../domain/entities/service_type.dart';

class ServiceCard {
  const ServiceCard({required this.service, this.serviceTypeId});

  final Service service;
  final int? serviceTypeId;
}

extension ServiceTypeCardMapper on ServiceType {
  ServiceCard toServiceCard(Map<int, String> categoryNames) {
    return ServiceCard(
      serviceTypeId: id,
      service: Service(
        title: name,
        description: description ?? '',
        icon: icon ?? '',
        category: categoryNames[categoryId] ?? 'All',
        processingDays: processingDays ?? 0,
        isPopular: isPopular,
        isAvailable: isActive,
      ),
    );
  }
}
