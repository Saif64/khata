import 'package:domain/domain.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 2; // Unique ID for the enum

  @override
  TransactionType read(BinaryReader reader) {
    return TransactionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    writer.writeByte(obj.index);
  }
}

class TransactionEntityAdapter extends TypeAdapter<TransactionEntity> {
  @override
  final int typeId = 1; // Unique ID for the entity

  @override
  TransactionEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionEntity(
      id: fields[0] as String,
      amount: fields[1] as double,
      description: fields[2] as String,
      type: fields[3] as TransactionType,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.date);
  }
}
