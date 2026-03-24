// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineOperationTypeAdapter extends TypeAdapter<OfflineOperationType> {
  @override
  final int typeId = 2;

  @override
  OfflineOperationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return OfflineOperationType.create;
      case 1:
        return OfflineOperationType.update;
      case 2:
        return OfflineOperationType.delete;
      default:
        return OfflineOperationType.create;
    }
  }

  @override
  void write(BinaryWriter writer, OfflineOperationType obj) {
    switch (obj) {
      case OfflineOperationType.create:
        writer.writeByte(0);
        break;
      case OfflineOperationType.update:
        writer.writeByte(1);
        break;
      case OfflineOperationType.delete:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineOperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OfflineProductAdapter extends TypeAdapter<OfflineProduct> {
  @override
  final int typeId = 1;

  @override
  OfflineProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineProduct(
      title: fields[0] as String,
      price: fields[1] as int,
      userId: fields[2] as int,
      isSynced: fields[3] as bool,
      createdAt: fields[4] as DateTime,
      operationType: fields[5] as OfflineOperationType? ?? OfflineOperationType.create,
      originalProductId: fields[6] as int?,
      operationId: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineProduct obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.isSynced)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.operationType)
      ..writeByte(6)
      ..write(obj.originalProductId)
      ..writeByte(7)
      ..write(obj.operationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
