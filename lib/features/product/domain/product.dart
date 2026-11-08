typedef Product = ({
  String id,
  String code,
  String name,
  int price,
  bool isNew,
  int? discount,
  String image,
  String description,
});

int productTotal(int price, int quantity) =>
    price * (quantity < 1 ? 1 : quantity);
