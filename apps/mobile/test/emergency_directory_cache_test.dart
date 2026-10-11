import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/emergency/data/datasources/emergency_directory_local_data_source.dart';
import 'package:mobile/features/emergency/domain/entities/emergency_directory_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('returns null and is not offline when nothing was saved', () async {
    final local = EmergencyDirectoryLocalDataSource(await SharedPreferences.getInstance());

    expect(local.readCached(), isNull);
    expect(local.servedFromCache, isFalse);
  });

  test('round-trips saved entries and flags them as served from cache', () async {
    final prefs = await SharedPreferences.getInstance();
    const entries = [
      EmergencyDirectoryEntry(
        id: 1,
        name: 'COMCEN Gubat',
        type: EmergencyType.comcen,
        contactNumber: '(056) 311-0117',
      ),
      EmergencyDirectoryEntry(
        id: 2,
        name: 'MDRRMO',
        type: EmergencyType.disasterResponse,
        contactNumber: '0917-000-0000',
        address: 'Municipal Hall',
        hours: '24/7',
      ),
    ];

    await EmergencyDirectoryLocalDataSource(prefs).cache(entries);

    final fresh = EmergencyDirectoryLocalDataSource(prefs);
    final cached = fresh.readCached()!;

    expect(fresh.servedFromCache, isTrue);
    expect(fresh.lastUpdated, isNotNull);
    expect(cached, hasLength(2));
    expect(cached[0].type, EmergencyType.comcen);
    expect(cached[1].type, EmergencyType.disasterResponse);
    expect(cached[1].address, 'Municipal Hall');
    expect(cached[1].hours, '24/7');
  });
}
