import '../../../core/database.dart';
import '../../product/data/products.dart';
import '../domain/catalog.dart';
import '../domain/catalog_repository.dart';

class LocalCatalog implements CatalogRepository {
  LocalCatalog(this.db, this.products);
  final DonutDatabase db;
  final Products products;

  @override
  Future<Member> member() async {
    final r = (await db.records('members')).single;
    return (
      name: r['name'] as String,
      image: r['image'] as String,
      tier: r['tier'] as String,
      points: r['points'] as int,
      remaining: r['remaining'] as int,
      goal: r['goal'] as int,
      notifications: r['notifications'] as int,
      badge: r['badge'] as int,
    );
  }

  @override
  Future<HomeData> home() async {
    final catalog = {for (final p in await products.all()) p.id: p};
    final sections = (await db.records('sections'))
        .map<ProductSection>(
          (r) => (
            title: r['title'],
            products: List.unmodifiable(
              (r['ids'] as List).map((id) => catalog[id]).nonNulls,
            ),
          ),
        )
        .toList(growable: false);
    final banners = (await db.records('banners'))
        .map<BannerOffer>(
          (r) =>
              (title: r['title'], subtitle: r['subtitle'], image: r['image']),
        )
        .toList(growable: false);
    final shops = (await db.records('shops'))
        .map<Shop>(
          (r) => (name: r['name'], address: r['address'], image: r['image']),
        )
        .toList(growable: false);
    return (banners: banners, sections: sections, shops: shops);
  }
}
