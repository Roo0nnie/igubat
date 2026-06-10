import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transparency_item.dart';
import '../../data/repositories/transparency_repository.dart';

/// A single transparency item resolved by [slug], used by the detail screen
/// and by notification deep links (`metadata.slug`).
final transparencyDetailProvider =
    FutureProvider.family<TransparencyItem?, String>((ref, slug) {
  return ref.watch(transparencyRepositoryProvider).getBySlug(slug);
});
