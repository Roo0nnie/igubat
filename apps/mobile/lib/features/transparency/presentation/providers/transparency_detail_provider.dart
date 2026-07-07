import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/transparency_item.dart';
import '../../domain/usecases/get_disclosure_by_slug.dart';

/// A single transparency item resolved by [slug], used by the detail screen
/// and by notification deep links (`metadata.slug`).
final transparencyDetailProvider =
    FutureProvider.family<TransparencyItem?, String>((ref, slug) async {
      final result =
          await ref.watch(getDisclosureBySlugUseCaseProvider).call(slug);
      return result.fold((failure) => throw failure, (item) => item);
    });
