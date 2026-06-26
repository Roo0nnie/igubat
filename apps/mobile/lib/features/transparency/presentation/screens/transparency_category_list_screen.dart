import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/glass_tokens.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_scaffold.dart';
import '../../../../shared/widgets/glass/glass_search_bar.dart';
import '../../../../shared/widgets/glass/glass_surface.dart';
import '../../data/models/transparency_type.dart';
import '../../domain/entities/transparency_item.dart';
import '../providers/transparency_list_provider.dart';
import '../widgets/transparency_format.dart';

/// Category list for a single transparency [type]. Published items only, sorted
/// most recent first, with fiscal-year and status chip filters plus free-text
/// search. Shows a "Last updated - cached" banner from the offline cache.
class TransparencyCategoryListScreen extends ConsumerStatefulWidget {
  const TransparencyCategoryListScreen({super.key, required this.type});

  final TransparencyType type;

  @override
  ConsumerState<TransparencyCategoryListScreen> createState() =>
      _TransparencyCategoryListScreenState();
}

class _TransparencyCategoryListScreenState
    extends ConsumerState<TransparencyCategoryListScreen> {
  String _search = '';
  int? _fiscalYearFilter;
  String? _statusFilter;

  String? _statusOf(TransparencyItem item) {
    switch (item.type) {
      case TransparencyType.programProject:
        return item.metadata['projectStatus']?.toString();
      case TransparencyType.bidProcurement:
        return item.metadata['bidStatus']?.toString();
      default:
        return null;
    }
  }

  List<TransparencyItem> _applyFilters(List<TransparencyItem> items) {
    final query = _search.trim().toLowerCase();
    return items.where((item) {
      if (_fiscalYearFilter != null && item.fiscalYear != _fiscalYearFilter) {
        return false;
      }
      if (_statusFilter != null && _statusOf(item) != _statusFilter) {
        return false;
      }
      if (query.isNotEmpty) {
        final haystack = '${item.title} ${item.referenceNumber ?? ''}'
            .toLowerCase();
        if (!haystack.contains(query)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final glass = glassThemeOf(context);
    final listAsync = ref.watch(transparencyListProvider(widget.type));
    final lastUpdated = ref.watch(transparencyLastUpdatedProvider(widget.type));
    final servedFromCache = ref.watch(
      transparencyServedFromCacheProvider(widget.type),
    );

    return GlassScaffold(
      title: widget.type.label,
      bottomPadding: false,
      useShellBackground: false,
      onRefresh: () async {
        ref.invalidate(transparencyListProvider(widget.type));
        await ref.read(transparencyListProvider(widget.type).future);
      },
      body: listAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 80),
            child: CircularProgressIndicator(color: AppTheme.secondaryColor),
          ),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Could not load items: $error',
            style: TextStyle(color: glass.textOnGlassMuted),
          ),
        ),
        data: (items) {
          final fiscalYears =
              items
                  .map((item) => item.fiscalYear)
                  .whereType<int>()
                  .toSet()
                  .toList()
                ..sort((a, b) => b.compareTo(a));
          final statuses = items
              .map(_statusOf)
              .whereType<String>()
              .toSet()
              .toList();
          final filtered = _applyFilters(items);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              if (servedFromCache && lastUpdated != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Last updated ${formatRelativeTime(lastUpdated)} - cached',
                    style: TextStyle(
                      fontSize: 11,
                      color: glass.textOnGlass,
                    ),
                  ),
                ),
              _buildFilters(context, fiscalYears, statuses),
              const SizedBox(height: 12),
              GlassSearchBar(
                hintText: 'Search by title or reference number...',
                onChanged: (value) => setState(() => _search = value),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      'No items match your filters.',
                      style: TextStyle(color: glass.textOnGlassMuted),
                    ),
                  ),
                )
              else
                ...filtered.map((item) => _buildItemCard(context, item)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    List<int> fiscalYears,
    List<String> statuses,
  ) {
    final chips = <Widget>[
      _chip(context, 'All', _fiscalYearFilter == null && _statusFilter == null, () {
        setState(() {
          _fiscalYearFilter = null;
          _statusFilter = null;
        });
      }),
      for (final year in fiscalYears)
        _chip(context, 'FY $year', _fiscalYearFilter == year, () {
          setState(
            () => _fiscalYearFilter = _fiscalYearFilter == year ? null : year,
          );
        }),
      for (final status in statuses)
        _chip(
          context,
          status[0].toUpperCase() + status.substring(1),
          _statusFilter == status,
          () {
            setState(
              () => _statusFilter = _statusFilter == status ? null : status,
            );
          },
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final chip in chips)
            Padding(padding: const EdgeInsets.only(right: 8), child: chip),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    final glass = glassThemeOf(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.primaryColor
              : glass.surfaceFor(GlassIntensity.prominent),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppTheme.primaryColor : glass.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.white : glass.textOnGlass,
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, TransparencyItem item) {
    final glass = glassThemeOf(context);
    final status = _statusOf(item);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        intensity: GlassIntensity.subtle,
        onTap: () {
          context.push('/transparency/${item.type.routeSlug}/${item.slug}');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.referenceNumber != null)
              Text(
                item.referenceNumber!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: glass.textOnGlassMuted,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: glass.textOnGlass,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (status != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    item.summary ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: glass.textOnGlassMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
