import 'package:flutter/material.dart';

/// The six Full Disclosure Policy content types surfaced on the mobile
/// Transparency & Good Governance section. Each carries display metadata
/// (label, icon, accent colour, route slug) so the Home grid, the category
/// list app bar, and deep links share one source of truth.
enum TransparencyType {
  programProject,
  bidProcurement,
  financialReport,
  annualBudget,
  legislativeOrdinance,
  executiveOrder,
}

extension TransparencyTypeX on TransparencyType {
  /// The backend `type` enum value (snake_case) used by the API + cache keys.
  String get apiValue {
    switch (this) {
      case TransparencyType.programProject:
        return 'program_project';
      case TransparencyType.bidProcurement:
        return 'bid_procurement';
      case TransparencyType.financialReport:
        return 'financial_report';
      case TransparencyType.annualBudget:
        return 'annual_budget';
      case TransparencyType.legislativeOrdinance:
        return 'legislative_ordinance';
      case TransparencyType.executiveOrder:
        return 'executive_order';
    }
  }

  /// Stable slug used in the deep-link route `/transparency/:type`.
  String get routeSlug {
    switch (this) {
      case TransparencyType.programProject:
        return 'program-projects';
      case TransparencyType.bidProcurement:
        return 'bids-projects';
      case TransparencyType.financialReport:
        return 'financial-reports';
      case TransparencyType.annualBudget:
        return 'annual-budget';
      case TransparencyType.legislativeOrdinance:
        return 'legislative-ordinances';
      case TransparencyType.executiveOrder:
        return 'executive-orders';
    }
  }

  String get label {
    switch (this) {
      case TransparencyType.programProject:
        return 'Program and Projects';
      case TransparencyType.bidProcurement:
        return 'Bids and Projects';
      case TransparencyType.financialReport:
        return 'Financial Reports';
      case TransparencyType.annualBudget:
        return 'Annual Budget';
      case TransparencyType.legislativeOrdinance:
        return 'Legislative Ordinances';
      case TransparencyType.executiveOrder:
        return 'Executive Orders';
    }
  }

  /// Singular form used as the item-detail app bar title.
  String get singularLabel {
    switch (this) {
      case TransparencyType.programProject:
        return 'Program / Project';
      case TransparencyType.bidProcurement:
        return 'Bid / Procurement';
      case TransparencyType.financialReport:
        return 'Financial Report';
      case TransparencyType.annualBudget:
        return 'Annual Budget';
      case TransparencyType.legislativeOrdinance:
        return 'Legislative Ordinance';
      case TransparencyType.executiveOrder:
        return 'Executive Order';
    }
  }

  IconData get icon {
    switch (this) {
      case TransparencyType.programProject:
        return Icons.apartment_outlined;
      case TransparencyType.bidProcurement:
        return Icons.work_outline;
      case TransparencyType.financialReport:
        return Icons.trending_up;
      case TransparencyType.annualBudget:
        return Icons.account_balance_outlined;
      case TransparencyType.legislativeOrdinance:
        return Icons.description_outlined;
      case TransparencyType.executiveOrder:
        return Icons.shield_outlined;
    }
  }

  Color get accentColor {
    switch (this) {
      case TransparencyType.programProject:
        return const Color(0xFFF59E0B);
      case TransparencyType.bidProcurement:
        return const Color(0xFF8B5CF6);
      case TransparencyType.financialReport:
        return const Color(0xFF10B981);
      case TransparencyType.annualBudget:
        return const Color(0xFFEF4444);
      case TransparencyType.legislativeOrdinance:
        return const Color(0xFF3B82F6);
      case TransparencyType.executiveOrder:
        return const Color(0xFFEAB308);
    }
  }

  static TransparencyType fromApiValue(String value) {
    return TransparencyType.values.firstWhere(
      (type) => type.apiValue == value,
      orElse: () => TransparencyType.programProject,
    );
  }

  static TransparencyType? fromRouteSlug(String slug) {
    for (final type in TransparencyType.values) {
      if (type.routeSlug == slug) return type;
    }
    return null;
  }
}
