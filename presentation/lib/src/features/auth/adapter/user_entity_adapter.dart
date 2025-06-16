import 'package:domain/domain.dart';
import 'package:hive_flutter/adapters.dart';

class UserEntityAdapter extends TypeAdapter<UserEntity> {
  @override
  final int typeId = 0; // Choose a unique ID

  @override
  UserEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserEntity(
      id: fields[0] as String,
      phone: fields[1] as String,
      name: fields[2] as String,
      email: fields[3] as String?,
      profileUrl: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.profileUrl);
  }
}
