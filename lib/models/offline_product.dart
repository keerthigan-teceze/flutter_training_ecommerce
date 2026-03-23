import 'package:hive/hive.dart';

part 'offline_product.g.dart';

@HiveType(typeId: 1)
class OfflineProduct extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  int price;

  @HiveField(2)
  int userId;

  @HiveField(3)
  bool isSynced;

  @HiveField(4)
  DateTime createdAt;

  OfflineProduct({
    required this.title,
    required this.price,
    required this.userId,
    this.isSynced = false,
    required this.createdAt,
  });
}