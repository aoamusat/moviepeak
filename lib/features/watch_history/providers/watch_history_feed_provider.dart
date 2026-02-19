import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';

final firstPageWatchHistoryProvider = FutureProvider((ref) {
  return ref.watch(watchHistoryProvider(1).future);
});
