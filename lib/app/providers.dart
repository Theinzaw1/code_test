import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/database.dart';
import '../core/reachability.dart';
import '../core/result.dart';
import '../features/auth/data/local_auth.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/home/data/local_catalog.dart';
import '../features/home/domain/catalog_repository.dart';
import '../features/product/data/products.dart';
import '../features/rewards/data/local_rewards.dart';
import '../features/rewards/domain/rewards_repository.dart';

final databaseProvider = Provider((ref) {
  final db = DonutDatabase();
  ref.onDispose(db.close);
  return db;
});
final authProvider = Provider<AuthRepository>(
  (ref) => LocalAuth(ref.watch(databaseProvider), const FlutterSecureStorage()),
);
final productsProvider = Provider(
  (ref) => Products(ref.watch(databaseProvider)),
);
final catalogProvider = Provider<CatalogRepository>(
  (ref) =>
      LocalCatalog(ref.watch(databaseProvider), ref.watch(productsProvider)),
);
final rewardsProvider = Provider<RewardsRepository>(
  (ref) => LocalRewards(ref.watch(databaseProvider)),
);
final memberProvider = FutureProvider(
  (ref) => ref.watch(catalogProvider).member(),
);
final homeProvider = FutureProvider((ref) => ref.watch(catalogProvider).home());
final productProvider = FutureProvider.family(
  (ref, String id) => ref.watch(productsProvider).product(id),
);
final challengesProvider = FutureProvider(
  (ref) => ref.watch(rewardsProvider).challenges(),
);
final onlineProvider = StreamProvider((ref) => observeReachability());
final sessionProvider = AsyncNotifierProvider<Session, Account?>(Session.new);

class Session extends AsyncNotifier<Account?> {
  @override
  Future<Account?> build() async =>
      switch (await ref.watch(authProvider).restore()) {
        Ok(:final value) => value,
        Failure(:final message) => throw StateError(message),
      };

  void signIn(Account account) => state = AsyncData(account);
  void clear() => state = const AsyncData(null);
}
