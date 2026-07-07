import 'package:flutter/material.dart';

import '../../../../shared/widgets/glass/glass_info_row.dart';
import '../../data/models/transparency_type.dart';
import '../../domain/entities/transparency_item.dart';
import 'transparency_format.dart';

/// Metadata entry with icon for the transparency detail key-details card.
class TransparencyMetadataRow {
  const TransparencyMetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

/// Type-specific metadata rows shown in the key-details card on item detail.
class TransparencyMetadataBand extends StatelessWidget {
  const TransparencyMetadataBand({
    super.key,
    required this.item,
    this.excludeStatus = true,
  });

  final TransparencyItem item;

  /// When true, status is omitted (shown in header badge instead).
  final bool excludeStatus;

  List<TransparencyMetadataRow> _entries() =>
      computeEntries(item, excludeStatus: excludeStatus);

  static List<TransparencyMetadataRow> computeEntries(
    TransparencyItem item, {
    bool excludeStatus = true,
  }) {
    final meta = item.metadataAs<Map<String, dynamic>>() ?? const {};
    final rows = <TransparencyMetadataRow>[];
    void add(IconData icon, String label, String value) {
      if (value.trim().isNotEmpty) {
        rows.add(TransparencyMetadataRow(icon: icon, label: label, value: value));
      }
    }

    switch (item.type) {
      case TransparencyType.programProject:
        if (!excludeStatus) {
          add(
            Icons.flag_outlined,
            'Status',
            formatStatusLabel((meta['projectStatus'] ?? '').toString()),
          );
        }
        add(
          Icons.payments_outlined,
          'Cost',
          meta['costPhp'] == null ? '' : formatPeso(meta['costPhp']),
        );
        add(
          Icons.business_outlined,
          'Office',
          (meta['implementingOffice'] ?? '').toString(),
        );
        add(
          Icons.calendar_today_outlined,
          'Start',
          formatTransparencyDate(meta['startDate']),
        );
        break;
      case TransparencyType.bidProcurement:
        if (!excludeStatus) {
          add(
            Icons.flag_outlined,
            'Status',
            formatStatusLabel((meta['bidStatus'] ?? '').toString()),
          );
        }
        add(
          Icons.payments_outlined,
          'ABC',
          meta['approvedBudgetForContractPhp'] == null
              ? ''
              : formatPeso(meta['approvedBudgetForContractPhp']),
        );
        add(
          Icons.calendar_today_outlined,
          'Closes',
          formatTransparencyDate(meta['closingDate']),
        );
        add(
          Icons.emoji_events_outlined,
          'Awarded To',
          (meta['awardedTo'] ?? '').toString(),
        );
        add(
          Icons.payments_outlined,
          'Awarded Amount',
          meta['awardedAmountPhp'] == null
              ? ''
              : formatPeso(meta['awardedAmountPhp']),
        );
        break;
      case TransparencyType.financialReport:
        add(
          Icons.description_outlined,
          'Report',
          (meta['reportType'] ?? '').toString().toUpperCase(),
        );
        add(
          Icons.date_range_outlined,
          'Period',
          (meta['fiscalPeriod'] ?? '').toString(),
        );
        add(
          Icons.person_outline,
          'Prepared By',
          (meta['preparedBy'] ?? '').toString(),
        );
        break;
      case TransparencyType.annualBudget:
        add(
          Icons.account_balance_outlined,
          'Type',
          (meta['budgetType'] ?? '').toString(),
        );
        add(
          Icons.payments_outlined,
          'Total',
          meta['totalAmountPhp'] == null
              ? ''
              : formatPeso(meta['totalAmountPhp']),
        );
        add(
          Icons.verified_outlined,
          'Endorsed By',
          (meta['endorsedBy'] ?? '').toString(),
        );
        break;
      case TransparencyType.legislativeOrdinance:
        add(
          Icons.calendar_today_outlined,
          'Approved',
          formatTransparencyDate(meta['dateApproved']),
        );
        add(
          Icons.event_available_outlined,
          'Effective',
          formatTransparencyDate(item.effectiveDate),
        );
        add(
          Icons.person_outline,
          'Principal Author',
          (meta['principalAuthor'] ?? '').toString(),
        );
        add(
          Icons.groups_outlined,
          'Sponsors',
          (meta['sponsors'] ?? '').toString(),
        );
        break;
      case TransparencyType.executiveOrder:
        add(
          Icons.calendar_today_outlined,
          'Issued',
          formatTransparencyDate(meta['dateIssued']),
        );
        add(
          Icons.event_available_outlined,
          'Effective',
          formatTransparencyDate(item.effectiveDate),
        );
        add(
          Icons.person_outline,
          'Issued By',
          (meta['issuedBy'] ?? '').toString(),
        );
        add(
          Icons.gavel_outlined,
          'Revokes',
          (meta['revokes'] ?? '').toString(),
        );
        break;
    }

    if (item.fiscalYear != null) {
      add(Icons.date_range_outlined, 'Fiscal Year', item.fiscalYear.toString());
    }
    if ((item.barangay ?? '').isNotEmpty) {
      add(Icons.location_on_outlined, 'Barangay', item.barangay!);
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          GlassInfoRow(
            icon: entries[i].icon,
            label: entries[i].label,
            value: entries[i].value,
            labelWidth: 100,
          ),
        ],
      ],
    );
  }
}
