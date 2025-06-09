import 'dart:convert';

import 'package:domain/domain.dart';
import 'package:hive/hive.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserEntity user);
  Future<UserEntity?> getCachedUser();
  Future<void> clearCachedUser();
}

const String _userBoxKey = 'userBox';
const String _userKey = 'user';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box<String> userBox;

  AuthLocalDataSourceImpl(this.userBox);

  @override
  Future<void> cacheUser(UserEntity user) async {
    await userBox.put(_userKey, json.encode(user.toJson()));
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    final userJson = userBox.get(_userKey);
    if (userJson != null) {
      return UserEntity.fromJson(json.decode(userJson));
    }
    return null;
  }

  @override
  Future<void> clearCachedUser() async {
    await userBox.delete(_userKey);
  }
}
