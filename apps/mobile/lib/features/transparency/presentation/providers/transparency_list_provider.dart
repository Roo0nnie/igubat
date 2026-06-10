import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transparency_item.dart';
import '../../data/models/transparency_type.dart';
import '../../data/repositories/transparency_repository.dart';

/// Published transparency items for a content [TransparencyType], most recent
/// first. Backed by the public API and persistent offline cache.
final transparencyListProvider =
    FutureProvider.family<List<TransparencyItem>, TransparencyType>((
      ref,
      type,
    ) {
      return ref.watch(transparencyRepositoryProvider).listByType(type);
    });

/// The "Last updated" timestamp for a type's cached list, if available.
final transparencyLastUpdatedProvider =
    Provider.family<DateTime?, TransparencyType>((ref, type) {
      ref.watch(transparencyListProvider(type));
      return ref.watch(transparencyRepositoryProvider).lastUpdatedFor(type);
    });

/// Whether the current list data for [type] came from the offline cache.
final transparencyServedFromCacheProvider =
    Provider.family<bool, TransparencyType>((ref, type) {
      ref.watch(transparencyListProvider(type));
      return ref.watch(transparencyRepositoryProvider).wasCachedFor(type);
    });
