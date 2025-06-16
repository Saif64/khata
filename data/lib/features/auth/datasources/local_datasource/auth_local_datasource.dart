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
  final Box<UserEntity> userBox;

  AuthLocalDataSourceImpl(this.userBox);

  @override
  Future<void> cacheUser(UserEntity user) async {
    await userBox.put(_userKey, user);
  }

  @override
  Future<UserEntity?> getCachedUser() async {
    return userBox.get(_userKey);
  }

  @override
  Future<void> clearCachedUser() async {
    await userBox.delete(_userKey);
  }
}
