import 'cart_item_model.dart';

class Order {
  final String id;
  String status;
  final List<CartItem> items;

  Order({
    required this.id,
    required this.status,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];

    return Order(
      id: json['id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      items: itemsList.map((e) {
        // ✅ CORRECT STRUCTURE
        return CartItem.fromJson({
          "id": e['id'] ?? 0,
          "userId": e['userId'] ?? 0,
          "productId": e['productId'] ?? 0,
          "title": e['title'] ?? 'Unknown',
          "price": e['price'] ?? 0,
        });
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}