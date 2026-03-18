import 'product_model.dart';

class CartItem {
  final int id;
  final int userId;
  final Product product;

  CartItem({
    required this.id,
    required this.userId,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      product: Product(
        id: json['productId'] ?? 0,
        title: json['title'] ?? 'Unknown',
        price: (json['price'] ?? 0).toDouble(),
        userId: json['userId'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'productId': product.id,
      'title': product.title,
      'price': product.price,
    };
  }
}