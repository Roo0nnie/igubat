import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Retains a successfully loaded auto-dispose provider briefly so tab changes
/// do not immediately repeat the same public catalog requests.
void cacheAutoDisposeResult(Ref ref, {Duration ttl = const Duration(minutes: 2)}) {
  final link = ref.keepAlive();
  final timer = Timer(ttl, link.close);
  ref.onDispose(timer.cancel);
}
