import '../../product/domain/product.dart';

typedef Member = ({
  String name,
  String image,
  String tier,
  int points,
  int remaining,
  int goal,
  int notifications,
  int badge,
});
typedef BannerOffer = ({String title, String subtitle, String image});
typedef Shop = ({String name, String address, String image});
typedef ProductSection = ({String title, List<Product> products});
typedef HomeData = ({
  List<BannerOffer> banners,
  List<ProductSection> sections,
  List<Shop> shops,
});
