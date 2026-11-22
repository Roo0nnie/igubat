import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/result.dart';
import 'package:mobile/features/reports/data/repositories/citizen_reports_repository_impl.dart';
import 'package:mobile/features/reports/domain/entities/citizen_report.dart';
import 'package:mobile/features/reports/domain/entities/citizen_report_status.dart';
import 'package:mobile/features/reports/domain/repositories/citizen_reports_repository.dart';
import 'package:mobile/features/reports/domain/usecases/citizen_report_params.dart';
import 'package:mobile/features/reports/presentation/screens/report_issue_screen.dart';

/// Captures submitted reports and answers with a configurable result.
class _FakeReportsRepository implements CitizenReportsRepository {
  _FakeReportsRepository({this.fail = false});

  final bool fail;
  final List<CreateCitizenReportParams> created = [];

  @override
  FutureResult<List<CitizenReport>> getMyReports() async => const Right([]);

  @override
  FutureResult<CitizenReport> getReportById(int id) async =>
      const Left(NotFoundFailure('not used'));

  @override
  FutureResult<CitizenReport> createReport(
    CreateCitizenReportParams params,
  ) async {
    created.add(params);
    if (fail) return const Left(NetworkFailure('offline'));
    return Right(
      CitizenReport(
        id: 1,
        category: params.category,
        description: params.description,
        status: CitizenReportStatus.received,
      ),
    );
  }
}

Future<void> _pumpScreen(
  WidgetTester tester,
  _FakeReportsRepository repo,
) async {
  tester.view.physicalSize = const Size(1080, 3600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [citizenReportsRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: ReportIssueScreen()),
    ),
  );
  await tester.pump();
}

Future<void> _submit(WidgetTester tester) async {
  final button = find.text('Submit Report');
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Finder _field(String label) => find.widgetWithText(TextField, label);

void main() {
  testWidgets('asks for a description before submitting', (tester) async {
    final repo = _FakeReportsRepository();
    await _pumpScreen(tester, repo);

    await _submit(tester);

    expect(find.text('Please describe the issue.'), findsOneWidget);
    expect(repo.created, isEmpty);
  });

  testWidgets('submits a trimmed report with the default category', (
    tester,
  ) async {
    final repo = _FakeReportsRepository();
    await _pumpScreen(tester, repo);

    await tester.enterText(
      _field('Description'),
      '  Deep pothole on the bridge  ',
    );
    await tester.enterText(_field('Location address'), 'Gubat bridge');
    await _submit(tester);

    expect(repo.created, hasLength(1));
    final params = repo.created.single;
    expect(params.category, 'Road Damage');
    expect(params.description, 'Deep pothole on the bridge');
    expect(params.locationAddress, 'Gubat bridge');
    // Profile stores "Barangay Cogon"; the screen must send the canonical name.
    expect(params.barangay, 'Cogon');
    expect(find.text('Report submitted.'), findsOneWidget);
  });

  testWidgets('omits an empty location and reports a failed submission', (
    tester,
  ) async {
    final repo = _FakeReportsRepository(fail: true);
    await _pumpScreen(tester, repo);

    await tester.enterText(_field('Description'), 'Streetlight is out');
    await _submit(tester);

    expect(repo.created.single.locationAddress, isNull);
    expect(
      find.text('Could not submit report. Please try again.'),
      findsOneWidget,
    );
  });
}
