// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
    );
  }

  @override
  void write(BinaryWriter writer, OfflineProduct obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.price)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.isSynced)
      ..writeByte(4)
      ..write(obj.createdAt);
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
