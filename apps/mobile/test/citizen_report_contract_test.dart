import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reports/domain/entities/citizen_report_category.dart';

void main() {
  test('citizen report categories match backend enum values', () {
    expect(
      CitizenReportCategory.values.map((category) => category.apiValue).toList(),
      [
        'Road Damage',
        'Flooding',
        'Waste Management',
        'Street Lighting',
        'Public Safety',
        'Others',
      ],
    );
  });
}
