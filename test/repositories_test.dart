import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/core/database.dart';
import 'package:jdonuts/core/result.dart';
import 'package:jdonuts/features/auth/data/local_auth.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';
import 'package:jdonuts/features/home/data/local_catalog.dart';
import 'package:jdonuts/features/product/data/products.dart';
import 'package:jdonuts/features/rewards/data/local_rewards.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DonutDatabase db;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = DonutDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  test(
    'seed transaction persists products, member, shop and challenge records',
    () async {
      final products = Products(db);
      final catalog = LocalCatalog(db, products);
      final home = await catalog.home();
      expect(home.shops, hasLength(4));
      expect(home.sections, hasLength(3));
      expect(home.banners, isNotEmpty);
      expect((await catalog.member()).points, 680000);
      expect((await products.product('p_coconut'))?.price, 3200);
      expect(await products.product('unknown'), isNull);
      expect(await LocalRewards(db).challenges(), hasLength(4));
    },
  );

  test('unknown login fails, registration persists, and logout preserves returning account', () async {
    final account = (
      phone: '+959254135592',
      firstName: 'Hania',
      lastName: '',
      birth: DateTime(1999, 5, 1),
    );
    final auth = LocalAuth(
      db,
      const FlutterSecureStorage(),
      latency: Duration.zero,
    );
    expect(
      await auth.requestCode(account.phone, register: false),
      isA<Ok<bool>>().having((r) => r.value, 'exists', false),
    );
    expect(
      await auth.verify(account.phone, '000000', register: true),
      isA<Failure<Account?>>(),
    );
    expect(await auth.register(account), isA<Ok<Account>>());
    final reopened = LocalAuth(
      db,
      const FlutterSecureStorage(),
      latency: Duration.zero,
    );
    expect(
      await reopened.restore(),
      isA<Ok<Account?>>().having((r) => r.value, 'account', account),
    );
    expect(await reopened.logout(), isA<Ok<void>>());
    expect(
      await reopened.restore(),
      isA<Ok<Account?>>().having((r) => r.value, 'account', null),
    );
    expect(
      await reopened.verify(account.phone, '123456', register: false),
      isA<Ok<Account?>>().having((r) => r.value, 'account', account),
    );
  });
}
