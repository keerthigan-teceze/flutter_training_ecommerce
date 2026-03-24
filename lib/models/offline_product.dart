import 'package:hive/hive.dart';

part 'offline_product.g.dart';

/// Enum representing the type of offline operation
@HiveType(typeId: 2)
enum OfflineOperationType {
  @HiveField(0)
  create,
  
  @HiveField(1)
  update,
  
  @HiveField(2)
  delete,
}

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

  @HiveField(5)
  OfflineOperationType operationType;

  /// Original product ID (used for UPDATE and DELETE operations)
  @HiveField(6)
  int? originalProductId;

  /// Unique ID for this offline operation
  @HiveField(7)
  String? operationId;

  OfflineProduct({
    required this.title,
    required this.price,
    required this.userId,
    this.isSynced = false,
    required this.createdAt,
    this.operationType = OfflineOperationType.create,
    this.originalProductId,
    this.operationId,
  });

  /// Factory constructor for CREATE operation
  factory OfflineProduct.forCreate({
    required String title,
    required int price,
    required int userId,
  }) {
    return OfflineProduct(
      title: title,
      price: price,
      userId: userId,
      createdAt: DateTime.now(),
      operationType: OfflineOperationType.create,
      operationId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Factory constructor for UPDATE operation
  factory OfflineProduct.forUpdate({
    required int originalProductId,
    required String title,
    required int price,
    required int userId,
  }) {
    return OfflineProduct(
      title: title,
      price: price,
      userId: userId,
      createdAt: DateTime.now(),
      operationType: OfflineOperationType.update,
      originalProductId: originalProductId,
      operationId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Factory constructor for DELETE operation
  factory OfflineProduct.forDelete({
    required int originalProductId,
    required int userId,
  }) {
    return OfflineProduct(
      title: '',
      price: 0,
      userId: userId,
      createdAt: DateTime.now(),
      operationType: OfflineOperationType.delete,
      originalProductId: originalProductId,
      operationId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  /// Check if this is a delete operation
  bool get isDelete => operationType == OfflineOperationType.delete;

  /// Check if this is an update operation
  bool get isUpdate => operationType == OfflineOperationType.update;

  /// Check if this is a create operation
  bool get isCreate => operationType == OfflineOperationType.create;
}
