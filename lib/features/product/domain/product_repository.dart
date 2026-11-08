import 'product.dart';

abstract interface class ProductRepository {
  Future<Product?> product(String id);
}
