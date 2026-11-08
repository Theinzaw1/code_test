import 'catalog.dart';

abstract interface class CatalogRepository {
  Future<Member> member();
  Future<HomeData> home();
}
