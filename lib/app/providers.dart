import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../data/models/movie.dart';
import '../data/models/subscription_plan.dart';
import '../data/models/subscription_status.dart';
import '../data/models/watch_history_entry.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/discovery_repository.dart';
import '../data/repositories/movies_repository.dart';
import '../data/repositories/requests_repository.dart';
import '../data/repositories/subscriptions_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/watch_history_repository.dart';
import '../features/auth/controllers/auth_controller.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(ref.watch(flutterSecureStorageProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(secureStorageServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});

final moviesRepositoryProvider = Provider<MoviesRepository>((ref) {
  return MoviesRepository(ref.watch(apiClientProvider));
});

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(ref.watch(moviesRepositoryProvider));
});

final subscriptionsRepositoryProvider =
    Provider<SubscriptionsRepository>((ref) {
  return SubscriptionsRepository(ref.watch(apiClientProvider));
});

final watchHistoryRepositoryProvider = Provider<WatchHistoryRepository>((ref) {
  return WatchHistoryRepository(ref.watch(apiClientProvider));
});

final requestsRepositoryProvider = Provider<RequestsRepository>((ref) {
  return RequestsRepository(ref.watch(apiClientProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
    secureStorageService: ref.watch(secureStorageServiceProvider),
  )..bootstrap();
});

final subscriptionStatusProvider =
    FutureProvider<SubscriptionStatus?>((ref) async {
  return ref.watch(subscriptionsRepositoryProvider).getMySubscription();
});

final plansProvider = FutureProvider<List<SubscriptionPlan>>((ref) async {
  return ref.watch(subscriptionsRepositoryProvider).getPlans();
});

final topRequestsProvider = FutureProvider((ref) async {
  return ref.watch(requestsRepositoryProvider).top();
});

final watchHistoryProvider = FutureProvider.family<PagedWatchHistory, int>(
  (ref, page) async {
    final result = await ref
        .watch(watchHistoryRepositoryProvider)
        .myHistory(page: page, limit: 20);
    return PagedWatchHistory(
      page: result.page,
      total: result.total,
      hasMore: result.hasMore,
      items: result.items,
    );
  },
);

final watchlistProvider = FutureProvider((ref) async {
  return ref.watch(moviesRepositoryProvider).getWatchlist();
});

final discoveryBucketProvider =
    FutureProvider.family<List<Movie>, String>((ref, bucket) async {
  return ref.watch(discoveryRepositoryProvider).getBucket(bucket);
});

class PagedWatchHistory {
  PagedWatchHistory({
    required this.page,
    required this.total,
    required this.hasMore,
    required this.items,
  });

  final int page;
  final int total;
  final bool hasMore;
  final List<WatchHistoryEntry> items;
}
