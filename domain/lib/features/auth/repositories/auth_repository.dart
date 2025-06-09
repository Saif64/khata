import 'package:fpdart/fpdart.dart';

import '../entities/user_entity.dart';
import '../failures/auth_failure.dart';

abstract class AuthRepository {
  Future<Either<AuthFailure, UserEntity>> signUp({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? profileUrl,
  });

  Future<Either<AuthFailure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<AuthFailure, UserEntity>> signInWithGoogle();

  Future<Either<AuthFailure, UserEntity>> signInWithFacebook();

  Future<Either<AuthFailure, void>> signOut();

  Future<Either<AuthFailure, UserEntity?>> getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}
