import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../services/storage/theme_storage_service.dart';
import '../../domain/entities/transparency_attachment.dart';
import '../../domain/entities/transparency_item.dart';
import '../models/transparency_item_model.dart';
import '../models/transparency_type.dart';

part 'transparency_local_data_source.g.dart';

/// SharedPreferences-backed cache + seed fallback for the transparency surface.
/// Tracks "last updated" and "served from cache" state per [TransparencyType].
class TransparencyLocalDataSource {
  TransparencyLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  final Map<TransparencyType, DateTime> _lastUpdated = {};
  final Map<TransparencyType, bool> _servedFromCache = {};

  DateTime? lastUpdatedFor(TransparencyType type) => _lastUpdated[type];

  bool wasCachedFor(TransparencyType type) => _servedFromCache[type] ?? false;

  static String _listKey(TransparencyType type) =>
      '${AppConstants.transparencyCachePrefix}.list.${type.apiValue}';
  static String _listUpdatedKey(TransparencyType type) =>
      '${_listKey(type)}.updated_at';
  static String _detailKey(String slug) =>
      '${AppConstants.transparencyCachePrefix}.detail.$slug';

  Future<void> cacheList(TransparencyType type, List<TransparencyItem> items) async {
    final now = DateTime.now();
    _lastUpdated[type] = now;
    _servedFromCache[type] = false;
    await Future.wait([
      _prefs.setString(
        _listKey(type),
        jsonEncode(
          items.map((e) => TransparencyItemModel.fromEntity(e).toJson()).toList(),
        ),
      ),
      _prefs.setString(_listUpdatedKey(type), now.toIso8601String()),
    ]);
  }

  List<TransparencyItem>? readCachedList(TransparencyType type) {
    final raw = _prefs.getString(_listKey(type));
    if (raw == null) return null;
    try {
      final updatedAt = DateTime.tryParse(
        _prefs.getString(_listUpdatedKey(type)) ?? '',
      );
      if (updatedAt != null) _lastUpdated[type] = updatedAt;
      final data = jsonDecode(raw);
      if (data is! List) return null;
      _servedFromCache[type] = true;
      return data
          .whereType<Map>()
          .map(
            (e) =>
                TransparencyItemModel.fromJson(e.cast<String, dynamic>())
                    .toEntity(),
          )
          .toList()
        ..sort(_byPublishedDesc);
    } on FormatException {
      return null;
    }
  }

  Future<void> cacheDetail(TransparencyItem item) async {
    if (item.slug.isEmpty) return;
    await _prefs.setString(
      _detailKey(item.slug),
      jsonEncode(TransparencyItemModel.fromEntity(item).toJson()),
    );
  }

  TransparencyItem? readCachedDetail(String slug) {
    final raw = _prefs.getString(_detailKey(slug));
    if (raw == null) return null;
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return null;
      return TransparencyItemModel.fromJson(data.cast<String, dynamic>())
          .toEntity();
    } on FormatException {
      return null;
    }
  }

  List<TransparencyItem> seedListByType(TransparencyType type) {
    _lastUpdated.remove(type);
    _servedFromCache[type] = false;
    return _seed.where((item) => item.type == type).toList()
      ..sort(_byPublishedDesc);
  }

  TransparencyItem? seedBySlug(String slug) {
    for (final item in _seed) {
      if (item.slug == slug) return item;
    }
    return null;
  }

  static int _byPublishedDesc(TransparencyItem a, TransparencyItem b) =>
      (b.publishedAt ?? DateTime(0)).compareTo(a.publishedAt ?? DateTime(0));

  static final List<TransparencyItem> _seed = [
    TransparencyItem(
      id: 1,
      type: TransparencyType.programProject,
      title: 'Buenavista Beach Mangrove Rehabilitation',
      slug: 'prj-2026-014-buenavista-beach-mangrove-rehabilitation',
      referenceNumber: 'PRJ-2026-014',
      summary:
          'Rehabilitation and reforestation of 4.2 hectares of mangrove coastline in Brgy. Buenavista to restore coastal protection and fisheries.',
      body:
          'The LGU, in partnership with the MENRO, will replant 12,000 mangrove propagules across the Buenavista coastline.',
      fiscalYear: 2026,
      barangay: 'Buenavista',
      metadata: const {
        'projectStatus': 'ongoing',
        'costPhp': 1850000,
        'implementingOffice': 'MENRO',
      },
      publishedAt: DateTime(2026, 3, 1),
      attachments: const [
        TransparencyAttachment(
          id: 1,
          fileName: 'Mangrove_Project_Brief.pdf',
          fileUrl:
              'https://files.gubat.gov.ph/transparency/prj-2026-014-brief.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 318000,
        ),
      ],
    ),
    TransparencyItem(
      id: 2,
      type: TransparencyType.programProject,
      title: 'Farm-to-Market Road Concreting — Brgy. Rizal',
      slug: 'prj-2026-009-farm-to-market-road-concreting-brgy-rizal',
      referenceNumber: 'PRJ-2026-009',
      summary:
          'Concreting of 1.8 km farm-to-market road to improve agricultural transport for upland barangays.',
      fiscalYear: 2026,
      barangay: 'Rizal',
      metadata: const {'projectStatus': 'planned', 'costPhp': 4250000},
      publishedAt: DateTime(2026, 4, 12),
    ),
    TransparencyItem(
      id: 3,
      type: TransparencyType.bidProcurement,
      title: 'Invitation to Bid — Concreting of Brgy. Rizal Road',
      slug: 'ib-2026-007-concreting-of-brgy-rizal-road',
      referenceNumber: 'IB-2026-007',
      summary:
          'Public bidding for the concreting of Brgy. Rizal road. Sealed bids accepted until the closing date.',
      fiscalYear: 2026,
      effectiveDate: DateTime(2026, 6, 28),
      metadata: const {
        'approvedBudgetForContractPhp': 4250000,
        'bidStatus': 'open',
        'closingDate': '2026-06-28',
      },
      publishedAt: DateTime(2026, 6, 10),
      attachments: const [
        TransparencyAttachment(
          id: 2,
          fileName: 'IB-2026-007_Invitation.pdf',
          fileUrl: 'https://files.gubat.gov.ph/transparency/ib-2026-007.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 240000,
        ),
      ],
    ),
    TransparencyItem(
      id: 4,
      type: TransparencyType.bidProcurement,
      title: 'Rehabilitation of Public Market — Phase 2',
      slug: 'ib-2026-003-rehabilitation-of-public-market-phase-2',
      referenceNumber: 'IB-2026-003',
      summary:
          'Award notice for the rehabilitation of the public market, phase 2.',
      fiscalYear: 2026,
      metadata: const {
        'bidStatus': 'awarded',
        'awardedTo': 'Sorsogon Builders Inc.',
        'awardedAmountPhp': 8640000,
      },
      publishedAt: DateTime(2026, 5, 2),
    ),
    TransparencyItem(
      id: 5,
      type: TransparencyType.financialReport,
      title: 'Statement of Allotments, Obligations and Balances — Q1 2026',
      slug: 'saob-q1-2026',
      referenceNumber: 'SAOB-Q1-2026',
      summary: 'Quarterly SAOB for the first quarter of fiscal year 2026.',
      fiscalYear: 2026,
      metadata: const {'reportType': 'saob', 'fiscalPeriod': 'Q1 2026'},
      publishedAt: DateTime(2026, 4, 20),
      attachments: const [
        TransparencyAttachment(
          id: 3,
          fileName: 'SAOB_Q1_2026.pdf',
          fileUrl: 'https://files.gubat.gov.ph/transparency/saob-q1-2026.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 512000,
        ),
      ],
    ),
    TransparencyItem(
      id: 6,
      type: TransparencyType.financialReport,
      title: 'COA Annual Audit Report — FY 2025',
      slug: 'coa-2025-annual-audit-report',
      referenceNumber: 'COA-2025',
      summary: 'Commission on Audit annual audit report for fiscal year 2025.',
      fiscalYear: 2025,
      metadata: const {'reportType': 'coa_annual', 'fiscalPeriod': 'FY 2025'},
      publishedAt: DateTime(2026, 2, 10),
    ),
    TransparencyItem(
      id: 7,
      type: TransparencyType.annualBudget,
      title: 'Annual Budget FY 2026',
      slug: 'ab-2026-annual-budget',
      referenceNumber: 'AB-2026',
      summary:
          'The approved annual budget of the Municipality of Gubat for fiscal year 2026.',
      body:
          'The FY 2026 budget prioritizes coastal resilience, health, and education.',
      fiscalYear: 2026,
      metadata: const {'budgetType': 'annual', 'totalAmountPhp': 312000000},
      publishedAt: DateTime(2026, 1, 15),
      attachments: const [
        TransparencyAttachment(
          id: 4,
          fileName: 'Annual_Budget_FY2026.pdf',
          fileUrl: 'https://files.gubat.gov.ph/transparency/ab-2026.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 1240000,
        ),
      ],
    ),
    TransparencyItem(
      id: 8,
      type: TransparencyType.annualBudget,
      title: 'Supplemental Budget No. 1, FY 2026',
      slug: 'sb-2026-01-supplemental-budget',
      referenceNumber: 'SB-2026-01',
      summary: 'First supplemental budget for fiscal year 2026.',
      fiscalYear: 2026,
      metadata: const {'budgetType': 'supplemental', 'totalAmountPhp': 18500000},
      publishedAt: DateTime(2026, 5, 20),
    ),
    TransparencyItem(
      id: 9,
      type: TransparencyType.legislativeOrdinance,
      title: 'An Ordinance Reducing Single-Use Plastic in Public Markets',
      slug: 'ord-2026-018-single-use-plastic-reduction',
      referenceNumber: 'Ord. No. 2026-018',
      summary:
          'This ordinance prohibits the use of single-use plastic carry bags by vendors in all public markets of the Municipality of Gubat, effective 27 March 2026.',
      body:
          'Section 1. Title — This ordinance shall be known as the Single-Use Plastic Reduction Ordinance.',
      fiscalYear: 2026,
      effectiveDate: DateTime(2026, 3, 27),
      metadata: const {
        'dateApproved': '2026-03-12',
        'principalAuthor': 'Hon. M. Dela Cruz',
        'sponsors': 'Hon. R. Bautista, Hon. J. Reyes',
      },
      publishedAt: DateTime(2026, 3, 13),
      attachments: const [
        TransparencyAttachment(
          id: 5,
          fileName: 'Ordinance_2026-018_Full_Text.pdf',
          fileUrl: 'https://files.gubat.gov.ph/transparency/ord-2026-018.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 412000,
        ),
        TransparencyAttachment(
          id: 6,
          fileName: 'SB_Minutes_2026-03-12.pdf',
          fileUrl:
              'https://files.gubat.gov.ph/transparency/sb-minutes-2026-03-12.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 186000,
        ),
      ],
    ),
    TransparencyItem(
      id: 10,
      type: TransparencyType.legislativeOrdinance,
      title: 'An Ordinance Establishing the Municipal Disaster Response Fund',
      slug: 'ord-2026-012-disaster-response-fund',
      referenceNumber: 'Ord. No. 2026-012',
      summary: 'Establishes a standing municipal disaster response fund.',
      fiscalYear: 2026,
      effectiveDate: DateTime(2026, 2, 20),
      metadata: const {
        'dateApproved': '2026-02-05',
        'principalAuthor': 'Hon. J. Reyes',
      },
      publishedAt: DateTime(2026, 2, 6),
    ),
    TransparencyItem(
      id: 11,
      type: TransparencyType.executiveOrder,
      title: 'Implementation of Pacific Coast Cleanliness Drive',
      slug: 'eo-2026-05-pacific-coast-cleanliness-drive',
      referenceNumber: 'EO No. 2026-05',
      summary:
          'Directs all barangays to conduct monthly coastal clean-up activities along the Pacific coast of Gubat.',
      fiscalYear: 2026,
      effectiveDate: DateTime(2026, 5, 2),
      metadata: const {
        'dateIssued': '2026-05-01',
        'issuedBy': 'Hon. Sharon Rose Aragon-Escoto',
      },
      publishedAt: DateTime(2026, 5, 2),
      attachments: const [
        TransparencyAttachment(
          id: 7,
          fileName: 'EO_2026-05.pdf',
          fileUrl: 'https://files.gubat.gov.ph/transparency/eo-2026-05.pdf',
          mimeType: 'application/pdf',
          sizeBytes: 168000,
        ),
      ],
    ),
    TransparencyItem(
      id: 12,
      type: TransparencyType.executiveOrder,
      title: 'Creation of the Municipal Investment Promotion Team',
      slug: 'eo-2026-03-investment-promotion-team',
      referenceNumber: 'EO No. 2026-03',
      summary: 'Creates a team to streamline local investment under RA 11032.',
      fiscalYear: 2026,
      metadata: const {
        'dateIssued': '2026-03-10',
        'issuedBy': 'Hon. Sharon Rose Aragon-Escoto',
      },
      publishedAt: DateTime(2026, 3, 11),
    ),
  ];
}

@Riverpod(keepAlive: true)
TransparencyLocalDataSource transparencyLocalDataSource(Ref ref) =>
    TransparencyLocalDataSource(ref.watch(sharedPreferencesProvider));
