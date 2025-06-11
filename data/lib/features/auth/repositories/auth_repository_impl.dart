import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';

import '../datasources/local_datasource/auth_local_datasource.dart';
import '../datasources/remote_datasource/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<Either<AuthFailure, UserEntity>> signUp({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? profileUrl,
  }) async {
    final failureOrUser = await remoteDataSource.signUp(
      name: name,
      phone: phone,
      password: password,
      email: email,
      profileUrl: profileUrl,
    );
    failureOrUser.fold(
      (l) => null,
      (user) => localDataSource.cacheUser(user),
    );
    return failureOrUser;
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final failureOrUser = await remoteDataSource.signInWithEmail(
      email: email,
      password: password,
    );
    failureOrUser.fold(
      (l) => null,
      (user) => localDataSource.cacheUser(user),
    );
    return failureOrUser;
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithGoogle() async {
    final failureOrUser = await remoteDataSource.signInWithGoogle();
    failureOrUser.fold(
      (l) => null,
      (user) => localDataSource.cacheUser(user),
    );
    return failureOrUser;
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithFacebook() async {
    final failureOrUser = await remoteDataSource.signInWithFacebook();
    failureOrUser.fold(
      (l) => null,
      (user) => localDataSource.cacheUser(user),
    );
    return failureOrUser;
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    final failureOrVoid = await remoteDataSource.signOut();
    failureOrVoid.fold((l) => null, (r) => localDataSource.clearCachedUser());
    return failureOrVoid;
  }

  @override
  Future<Either<AuthFailure, UserEntity?>> getCurrentUser() async {
    final failureOrUser = await remoteDataSource.getCurrentUser();
    return failureOrUser.fold(
      (failure) async {
        final cachedUser = await localDataSource.getCachedUser();
        if (cachedUser != null) {
          return Right(cachedUser);
        }

        return Left(failure);
      },
      (user) {
        if (user != null) {
          localDataSource.cacheUser(user);
        } else {
          localDataSource.clearCachedUser();
        }
        return Right(user);
      },
    );
  }

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;
}
