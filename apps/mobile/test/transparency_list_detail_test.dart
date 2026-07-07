import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/usecases/result.dart';
import 'package:mobile/features/transparency/data/models/transparency_type.dart';
import 'package:mobile/features/transparency/data/repositories/transparency_repository_impl.dart';
import 'package:mobile/features/transparency/domain/entities/transparency_attachment.dart';
import 'package:mobile/features/transparency/domain/entities/transparency_item.dart';
import 'package:mobile/features/transparency/domain/repositories/transparency_repository.dart';
import 'package:mobile/features/transparency/presentation/screens/transparency_category_list_screen.dart';
import 'package:mobile/features/transparency/presentation/screens/transparency_item_detail_screen.dart';
import 'package:mobile/features/transparency/presentation/widgets/transparency_attachment_tile.dart';
import 'package:mobile/shared/widgets/glass/glass_card.dart';
import 'package:mobile/shared/widgets/glass/glass_markdown_body.dart';

class _FakeTransparencyRepository implements TransparencyRepository {
  _FakeTransparencyRepository({
    required this.items,
    this.cached = false,
    this.lastUpdated,
  });

  final List<TransparencyItem> items;
  final bool cached;
  final DateTime? lastUpdated;

  @override
  DateTime? lastUpdatedFor(TransparencyType type) => lastUpdated;

  @override
  bool wasCachedFor(TransparencyType type) => cached;

  @override
  FutureResult<List<TransparencyItem>> listByType(TransparencyType type) async {
    return Right(items.where((item) => item.type == type).toList());
  }

  @override
  FutureResult<TransparencyItem?> getBySlug(String slug) async {
    for (final item in items) {
      if (item.slug == slug) return Right(item);
    }
    return const Right(null);
  }

  @override
  FutureResult<Uri> cacheAttachment(TransparencyAttachment attachment) async {
    return Right(Uri.parse(attachment.fileUrl));
  }
}

Widget _wrapWithRepository({
  required TransparencyRepository repository,
  required Widget child,
}) {
  return ProviderScope(
    overrides: [transparencyRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(theme: AppTheme.lightTheme, home: child),
  );
}

Future<void> _pumpDetail(
  WidgetTester tester,
  TransparencyRepository repository,
  String slug,
) async {
  await tester.pumpWidget(
    _wrapWithRepository(
      repository: repository,
      child: TransparencyItemDetailScreen(slug: slug),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _scrollTo(Finder finder, WidgetTester tester) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}

final _bidItem = TransparencyItem(
  id: 101,
  type: TransparencyType.bidProcurement,
  title: 'Invitation to Bid - Concreting of Brgy. Rizal Road',
  slug: 'ib-2026-007-concreting-of-brgy-rizal-road',
  referenceNumber: 'IB-2026-007',
  summary: 'Sealed bids accepted until the closing date.',
  fiscalYear: 2026,
  metadata: const {
    'type': 'bid_procurement',
    'approvedBudgetForContractPhp': 4250000,
    'bidStatus': 'open',
    'closingDate': '2026-06-28',
  },
  publishedAt: DateTime(2026, 6, 10),
);

final _ordinanceItem = TransparencyItem(
  id: 202,
  type: TransparencyType.legislativeOrdinance,
  title: 'An Ordinance Reducing Single-Use Plastic in Public Markets',
  slug: 'ord-2026-018-single-use-plastic-reduction',
  referenceNumber: 'ORDINANCE NO. 2026-018',
  summary: 'Prohibits single-use plastic carry bags in public markets.',
  body: 'Section 1. This ordinance shall apply to all public markets.\n\n## Scope\n\nApplies to all vendors.',
  fiscalYear: 2026,
  effectiveDate: DateTime(2026, 3, 27),
  metadata: const {
    'type': 'legislative_ordinance',
    'dateApproved': '2026-03-12',
    'principalAuthor': 'Hon. M. Dela Cruz',
    'sponsors': 'Hon. R. Bautista, Hon. J. Reyes',
  },
  publishedAt: DateTime(2026, 3, 13),
  attachments: const [
    TransparencyAttachment(
      id: 1,
      fileName: 'Ordinance_2026-018_Full_Text.pdf',
      fileUrl: 'https://files.gubat.gov.ph/transparency/ord-2026-018.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 412000,
    ),
  ],
);

final _projectItem = TransparencyItem(
  id: 2,
  type: TransparencyType.programProject,
  title: 'Farm-to-Market Road Concreting — Brgy. Rizal',
  slug: 'prj-2026-009-farm-to-market-road-concreting-brgy-rizal',
  referenceNumber: 'PRJ-2026-009',
  summary:
      'Concreting of 1.8 km farm-to-market road to improve agricultural transport for upland barangays.',
  body: '## Scope\n\nConcreting of 1.8 km of road with line canals.',
  fiscalYear: 2026,
  barangay: 'Rizal',
  metadata: const {
    'projectStatus': 'planned',
    'costPhp': 4250000,
    'implementingOffice': 'Municipal Engineering Office',
    'startDate': '2026-07-01',
  },
  publishedAt: DateTime(2026, 4, 12),
  attachments: const [
    TransparencyAttachment(
      id: 3,
      fileName: 'PRJ-2026-009_Project_Profile.pdf',
      fileUrl: 'https://files.gubat.gov.ph/transparency/prj-2026-009.pdf',
      mimeType: 'application/pdf',
      sizeBytes: 279000,
    ),
  ],
);

void main() {
  testWidgets('category list renders cached transparency items and banner', (
    tester,
  ) async {
    final repository = _FakeTransparencyRepository(
      items: [_bidItem],
      cached: true,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 12)),
    );

    await tester.pumpWidget(
      _wrapWithRepository(
        repository: repository,
        child: const TransparencyCategoryListScreen(
          type: TransparencyType.bidProcurement,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Bids and Projects'), findsOneWidget);
    expect(find.text('IB-2026-007'), findsOneWidget);
    expect(find.text(_bidItem.title), findsOneWidget);
    expect(find.textContaining('Last updated'), findsOneWidget);
    expect(find.textContaining('- cached'), findsOneWidget);
  });

  testWidgets('detail screen renders glass cards, metadata, and attachment', (
    tester,
  ) async {
    final repository = _FakeTransparencyRepository(items: [_ordinanceItem]);

    await _pumpDetail(
      tester,
      repository,
      'ord-2026-018-single-use-plastic-reduction',
    );

    expect(find.text(_ordinanceItem.title), findsOneWidget);
    expect(find.text('ORDINANCE NO. 2026-018'), findsOneWidget);
    expect(find.byType(GlassCard), findsWidgets);
    expect(find.text('Key Details'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('12 Mar 2026'), findsWidgets);
    expect(find.text('Principal Author'), findsOneWidget);
    expect(find.text('Hon. M. Dela Cruz'), findsOneWidget);

    await _scrollTo(find.text('Description'), tester);
    expect(find.text('Description'), findsOneWidget);
    expect(find.byType(GlassMarkdownBody), findsOneWidget);
    expect(find.text('## Scope'), findsNothing);
    expect(find.text('Scope'), findsOneWidget);

    await _scrollTo(find.text('Attachments (1)'), tester);
    expect(find.byType(TransparencyAttachmentTile), findsOneWidget);
    expect(find.text('Ordinance_2026-018_Full_Text.pdf'), findsOneWidget);
    expect(find.text('402 KB'), findsOneWidget);
  });

  testWidgets('detail screen shows capitalized status badge for projects', (
    tester,
  ) async {
    final repository = _FakeTransparencyRepository(items: [_projectItem]);

    await _pumpDetail(
      tester,
      repository,
      'prj-2026-009-farm-to-market-road-concreting-brgy-rizal',
    );

    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('planned'), findsNothing);
    expect(find.text('₱4,250,000.00'), findsOneWidget);
    expect(find.text('Municipal Engineering Office'), findsOneWidget);

    await _scrollTo(find.text('Attachments (1)'), tester);
    expect(find.text('PRJ-2026-009_Project_Profile.pdf'), findsOneWidget);

    await tester.tap(find.text('PRJ-2026-009_Project_Profile.pdf'));
    await tester.pump();
  });
}
