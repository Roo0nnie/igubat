import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/discover/data/models/discover_gubat_entry.dart';
import 'package:mobile/features/discover/data/repositories/discover_gubat_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'DiscoverGubatRepository parses and caches API list responses',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: [
                  {
                    'id': 7,
                    'type': 'tourist_spot',
                    'title': 'Buenavista Beach',
                    'slug': 'buenavista-beach',
                    'summary': 'Beginner-friendly surf and beach destination.',
                    'body': 'Full detail',
                    'category': 'Beach',
                    'status': 'published',
                    'coverImageUrl': null,
                    'mapLocation': 'Buenavista, Gubat, Sorsogon',
                    'whereToBuy': null,
                    'eventDate': null,
                    'publishedAt': '2026-06-10T08:00:00.000Z',
                    'photos': [
                      {
                        'id': 1,
                        'imageUrl': 'https://files.gubat.gov.ph/buenavista.jpg',
                        'altText': 'Buenavista Beach shoreline',
                        'sortOrder': 0,
                      },
                    ],
                  },
                ],
              ),
            );
          },
        ),
      );
      final repository = DiscoverGubatRepository(dio: dio, prefs: prefs);

      final items = await repository.listByType(DiscoverGubatType.touristSpot);

      expect(items, hasLength(1));
      expect(items.single.title, 'Buenavista Beach');
      expect(items.single.detailLabel, 'Map location');
      expect(items.single.detailValue, 'Buenavista, Gubat, Sorsogon');
      expect(repository.wasCachedFor(DiscoverGubatType.touristSpot), isFalse);
      expect(
        prefs.getString('discover_gubat.list.tourist_spot'),
        contains('Buenavista Beach'),
      );
    },
  );
}
