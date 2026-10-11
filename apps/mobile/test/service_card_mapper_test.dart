import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/services/domain/entities/service_type.dart';
import 'package:mobile/features/services/presentation/mappers/service_card_mapper.dart';

void main() {
  test('maps live service type into a request card with backend id', () {
    const serviceType = ServiceType(
      id: 42,
      categoryId: 9,
      name: 'Business Permit',
      slug: 'business-permit',
      description: 'Apply for a permit.',
      processingDays: 5,
      icon: 'briefcase',
      isPopular: true,
      isActive: true,
    );

    final card = serviceType.toServiceCard({9: 'E-Services'});

    expect(card.serviceTypeId, 42);
    expect(card.service.title, 'Business Permit');
    expect(card.service.category, 'E-Services');
    expect(card.service.processingDays, 5);
  });
}
