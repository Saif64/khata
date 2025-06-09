import 'dart:async';

import 'package:domain/domain.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
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

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<Either<AuthFailure, UserEntity>> signUp({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? profileUrl,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: phone, // Continue using phone for email-based auth
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'profile_url': profileUrl,
        },
      );

      if (response.user == null) {
        return Left(UserAlreadyExistsFailure(
            'User with this phone already exists or another error occurred.'));
      }

      return Right(UserEntity(
        id: response.user!.id,
        name: name,
        phone: phone,
        email: email,
        profileUrl: profileUrl,
      ));
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('network')) {
        return Left(NetworkFailure('Please check your internet connection.'));
      }
      if (e.statusCode == '422' ||
          e.message.toLowerCase().contains('already exists')) {
        return Left(
            UserAlreadyExistsFailure('User with this phone already exists.'));
      }
      return Left(ServerFailure('Supabase auth error: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure('An unknown error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Left(InvalidCredentialsFailure('Invalid email or password.'));
      }

      final userId = response.user!.id;

      final profileResponse = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      if (profileResponse.isEmpty) {
        return Left(UserNotFoundFailure('User profile not found.'));
      }

      return Right(UserEntity(
        id: userId,
        name: profileResponse['name'],
        phone: profileResponse['phone'],
        email: profileResponse['email'],
        profileUrl: profileResponse['profile_url'],
      ));
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        return Left(InvalidCredentialsFailure('Invalid email or password.'));
      }
      if (e.message.toLowerCase().contains('network')) {
        return Left(NetworkFailure('Please check your internet connection.'));
      }
      return Left(ServerFailure('Supabase auth error: ${e.message}'));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Left(UserNotFoundFailure('User profile not found.'));
      }
      return Left(ServerFailure('Database error: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure('An unknown error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithGoogle() async {
    try {
      final bool success = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
      );
      if (!success) {
        return Left(ServerFailure('Google sign-in was not successful.'));
      }
      // The user will be available in the auth state changes stream
      // For now, we can't return a UserEntity directly from here
      // But we need to, so we'll listen to the stream for the first user event
      final user = await authStateChanges.first;
      if (user != null) {
        return Right(user);
      } else {
        return Left(ServerFailure("Couldn't get user after Google sign-in."));
      }
    } catch (e) {
      return Left(UnknownFailure('An unknown error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity>> signInWithFacebook() async {
    try {
      final bool success = await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.facebook,
      );
      if (!success) {
        return Left(ServerFailure('Facebook sign-in was not successful.'));
      }
      final user = await authStateChanges.first;
      if (user != null) {
        return Right(user);
      } else {
        return Left(ServerFailure("Couldn't get user after Facebook sign-in."));
      }
    } catch (e) {
      return Left(UnknownFailure('An unknown error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      return const Right(unit);
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('network')) {
        return Left(NetworkFailure('Please check your internet connection.'));
      }
      return Left(ServerFailure('Supabase auth error: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure('An unknown error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, UserEntity?>> getCurrentUser() async {
    final supabaseUser = supabaseClient.auth.currentUser;

    if (supabaseUser == null) {
      return const Right(null);
    }

    try {
      final profileResponse = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', supabaseUser.id)
          .single();

      return Right(UserEntity(
        id: supabaseUser.id,
        phone: profileResponse['phone'] ?? supabaseUser.phone ?? '',
        name: profileResponse['name'],
        email: profileResponse['email'],
        profileUrl: profileResponse['profile_url'],
      ));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Left(UserNotFoundFailure(
            'User profile not found. Associated auth user exists.'));
      }
      return Left(ServerFailure('Failed to fetch user profile: ${e.message}'));
    } catch (e) {
      return Left(UnknownFailure(
          'An error occurred while fetching user profile: ${e.toString()}'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.asyncMap((authState) async {
      final session = authState.session;
      final user = session?.user;

      if (user == null) {
        return null;
      }

      if (authState.event == AuthChangeEvent.signedIn ||
          authState.event == AuthChangeEvent.userUpdated) {
        try {
          final profileResponse = await supabaseClient
              .from('profiles')
              .select()
              .eq('id', user.id)
              .single();

          return UserEntity(
            id: user.id,
            phone: profileResponse['phone'] ?? user.phone ?? '',
            name: profileResponse['name'],
            email: profileResponse['email'] ?? user.email,
            profileUrl: profileResponse['profile_url'],
          );
        } on PostgrestException {
          // Profile might not exist yet for a new OAuth user
          // Let's create it
          final newProfile = {
            'id': user.id,
            'name': user.userMetadata?['full_name'] ?? 'No Name',
            'phone': user.phone ?? 'No Phone',
            'email': user.email,
            'profile_url': user.userMetadata?['avatar_url']
          };
          await supabaseClient.from('profiles').upsert(newProfile);
          return UserEntity.fromJson(
              newProfile.map((key, value) => MapEntry(key, value.toString())));
        } catch (e) {
          return null;
        }
      } else if (authState.event == AuthChangeEvent.signedOut) {
        return null;
      }
      return null;
    });
  }
}
