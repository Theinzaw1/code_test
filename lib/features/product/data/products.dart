import '../../../core/database.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';

class Products implements ProductRepository {
  Products(this.db);
  final DonutDatabase db;

  Future<List<Product>> all() async =>
      (await db.records('products'))
          .map<Product>(
            (r) => (
              id: r['id'],
              code: r['code'],
              name: r['name'],
              price: r['price'],
              isNew: r['isNew'],
              discount: r['discount'],
              image: r['image'],
              description: r['description'],
            ),
          )
          .toList(growable: false);

  @override
  Future<Product?> product(String id) async =>
      (await all()).where((product) => product.id == id).firstOrNull;
}
