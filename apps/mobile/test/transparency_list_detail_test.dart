import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/transparency/data/models/transparency_attachment.dart';
import 'package:mobile/features/transparency/data/models/transparency_item.dart';
import 'package:mobile/features/transparency/data/models/transparency_type.dart';
import 'package:mobile/features/transparency/data/repositories/transparency_repository.dart';
import 'package:mobile/features/transparency/presentation/screens/transparency_category_list_screen.dart';
import 'package:mobile/features/transparency/presentation/screens/transparency_item_detail_screen.dart';
import 'package:mobile/features/transparency/presentation/widgets/transparency_attachment_tile.dart';

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
  Future<List<TransparencyItem>> listByType(TransparencyType type) async {
    return items.where((item) => item.type == type).toList();
  }

  @override
  Future<TransparencyItem?> getBySlug(String slug) async {
    for (final item in items) {
      if (item.slug == slug) return item;
    }
    return null;
  }

  @override
  Future<Uri> cacheAttachment(TransparencyAttachment attachment) async {
    return Uri.parse(attachment.fileUrl);
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
  body: 'Section 1. This ordinance shall apply to all public markets.',
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

  testWidgets('detail screen renders metadata band and attachment tile', (
    tester,
  ) async {
    final repository = _FakeTransparencyRepository(items: [_ordinanceItem]);

    await tester.pumpWidget(
      _wrapWithRepository(
        repository: repository,
        child: const TransparencyItemDetailScreen(
          slug: 'ord-2026-018-single-use-plastic-reduction',
        ),
      ),
    );
    await tester.pump();

    expect(find.text(_ordinanceItem.title), findsOneWidget);
    expect(find.text('ORDINANCE NO. 2026-018'), findsOneWidget);
    expect(find.byType(TransparencyAttachmentTile), findsOneWidget);
    expect(find.text('Ordinance_2026-018_Full_Text.pdf'), findsOneWidget);
    expect(find.text('402 KB'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('Approved: 12 Mar 2026'),
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains(
              'Principal Author: Hon. M. Dela Cruz',
            ),
      ),
      findsOneWidget,
    );
  });
}
