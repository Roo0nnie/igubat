import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/discover_gubat_repository_impl.dart';
import '../../domain/entities/discover_gubat_item.dart';

final discoverGubatListProvider =
    FutureProvider.autoDispose<List<DiscoverGubatItem>>((ref) async {
  final result = await ref.watch(discoverGubatRepositoryProvider).list();
  return result.fold((failure) => throw failure, (items) => items);
});

final discoverGubatDetailProvider =
    FutureProvider.autoDispose.family<DiscoverGubatItem, String>((ref, slug) async {
  final result = await ref.watch(discoverGubatRepositoryProvider).getBySlug(slug);
  return result.fold((failure) => throw failure, (item) => item);
});
