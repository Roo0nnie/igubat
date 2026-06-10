import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/transparency_item.dart';
import '../../data/models/transparency_type.dart';
import 'transparency_format.dart';

/// The type-specific metadata band shown at the top of the item detail screen
/// (e.g. "Approved 12 Mar 2026 · Effective 27 Mar 2026 · Principal Author …").
class TransparencyMetadataBand extends StatelessWidget {
  const TransparencyMetadataBand({super.key, required this.item});

  final TransparencyItem item;

  String _formatDate(dynamic value) => formatTransparencyDate(value);

  String _formatPeso(dynamic value) => formatPeso(value);

  List<MapEntry<String, String>> _rows() {
    final meta = item.metadataAs<Map<String, dynamic>>() ?? const {};
    final rows = <MapEntry<String, String>>[];
    void add(String label, String value) {
      if (value.trim().isNotEmpty) rows.add(MapEntry(label, value));
    }

    switch (item.type) {
      case TransparencyType.programProject:
        add('Status', (meta['projectStatus'] ?? '').toString());
        add(
          'Cost',
          meta['costPhp'] == null ? '' : _formatPeso(meta['costPhp']),
        );
        add('Office', (meta['implementingOffice'] ?? '').toString());
        add('Start', _formatDate(meta['startDate']));
        break;
      case TransparencyType.bidProcurement:
        add('Status', (meta['bidStatus'] ?? '').toString());
        add(
          'ABC',
          meta['approvedBudgetForContractPhp'] == null
              ? ''
              : _formatPeso(meta['approvedBudgetForContractPhp']),
        );
        add('Closes', _formatDate(meta['closingDate']));
        add('Awarded To', (meta['awardedTo'] ?? '').toString());
        add(
          'Awarded Amount',
          meta['awardedAmountPhp'] == null
              ? ''
              : _formatPeso(meta['awardedAmountPhp']),
        );
        break;
      case TransparencyType.financialReport:
        add('Report', (meta['reportType'] ?? '').toString().toUpperCase());
        add('Period', (meta['fiscalPeriod'] ?? '').toString());
        add('Prepared By', (meta['preparedBy'] ?? '').toString());
        break;
      case TransparencyType.annualBudget:
        add('Type', (meta['budgetType'] ?? '').toString());
        add(
          'Total',
          meta['totalAmountPhp'] == null
              ? ''
              : _formatPeso(meta['totalAmountPhp']),
        );
        add('Endorsed By', (meta['endorsedBy'] ?? '').toString());
        break;
      case TransparencyType.legislativeOrdinance:
        add('Approved', _formatDate(meta['dateApproved']));
        add('Effective', _formatDate(item.effectiveDate));
        add('Principal Author', (meta['principalAuthor'] ?? '').toString());
        add('Sponsors', (meta['sponsors'] ?? '').toString());
        break;
      case TransparencyType.executiveOrder:
        add('Issued', _formatDate(meta['dateIssued']));
        add('Effective', _formatDate(item.effectiveDate));
        add('Issued By', (meta['issuedBy'] ?? '').toString());
        add('Revokes', (meta['revokes'] ?? '').toString());
        break;
    }
    if (item.fiscalYear != null) add('Fiscal Year', item.fiscalYear.toString());
    if ((item.barangay ?? '').isNotEmpty) add('Barangay', item.barangay!);
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows();
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: Color(0xFF374151),
                    ),
                    children: [
                      TextSpan(
                        text: '${row.key}: ',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      TextSpan(text: row.value),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
