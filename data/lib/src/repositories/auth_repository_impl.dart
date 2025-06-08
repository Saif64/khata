import 'dart:async';

import 'package:domain/domain.dart'; // Assuming this will be set up to export necessary domain files
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Later, ensure domain/domain.dart exports:
// export 'src/entities/user_entity.dart';
// export 'src/repositories/auth_repository.dart';
// export 'src/failures/auth_failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient supabaseClient;

  AuthRepositoryImpl(this.supabaseClient);

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
        phone: phone,
        password: password,
      );

      if (response.user == null) {
        return Left(UserAlreadyExistsFailure(
            'User with this phone already exists or another error occurred.'));
      }

      final userId = response.user!.id;

      await supabaseClient.from('profiles').insert({
        'id': userId,
        'name': name,
        'phone': phone,
        'email': email,
        'profile_url': profileUrl,
      });

      return Right(UserEntity(
        id: userId,
        name: name,
        phone: phone,
        email: email,
        profileUrl: profileUrl,
      ));
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('network')) {
        return Left(NetworkFailure('Please check your internet connection.'));
      }
      // Check for user already exists more specifically if possible,
      // Supabase might throw a specific error code or message pattern
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
  Future<Either<AuthFailure, UserEntity>> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        phone: phone,
        password: password,
      );

      if (response.user == null) {
        return Left(InvalidCredentialsFailure('Invalid phone or password.'));
      }

      final userId = response.user!.id;

      final profileResponse = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // profileResponse will throw if not found due to .single(),
      // but good to keep a check or handle specific errors if Supabase changes behavior.
      // If Supabase returns a map directly and it's empty, that's another case.
      // Assuming profileResponse is Map<String, dynamic>
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
        return Left(InvalidCredentialsFailure('Invalid phone or password.'));
      }
      if (e.message.toLowerCase().contains('network')) {
        return Left(NetworkFailure('Please check your internet connection.'));
      }
      return Left(ServerFailure('Supabase auth error: ${e.message}'));
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        // PGRST116: "The result contains 0 rows"
        return Left(UserNotFoundFailure('User profile not found.'));
      }
      return Left(ServerFailure('Database error: ${e.message}'));
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
        // Supabase user.phone might be null, ensure null safety
        phone: profileResponse['phone'] ?? supabaseUser.phone ?? '',
        name: profileResponse['name'],
        email: profileResponse[
            'email'], // Email might be in profile or from Supabase user
        profileUrl: profileResponse['profile_url'],
      ));
    } on PostgrestException catch (e) {
      // PGRST116: "The result contains 0 rows"
      if (e.code == 'PGRST116') {
        // It's possible the user exists in auth but profile creation failed or is pending.
        // Depending on app requirements, you might return Right(UserEntity with partial data)
        // or Left(failure). For now, returning failure.
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
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      return const Right(unit); // Using unit from fpdart
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
  Stream<UserEntity?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.asyncMap((authState) async {
      final session = authState.session;
      final user = session?.user;

      if (user == null) {
        return null; // User signed out or session expired
      }

      // AuthChangeEvent.passwordRecovery should probably not lead to a full UserEntity emission
      // until the user signs in again. For now, we only proceed if signedIn or userUpdated.
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
            email: profileResponse['email'] ??
                user.email, // Combine sources for email
            profileUrl: profileResponse['profile_url'],
          );
        } on PostgrestException catch (e) {
          // Log error, and return null as profile is essential.
          // Consider specific error logging or reporting.
          print(
              'Error fetching profile on authStateChange (PostgrestException: ${e.code}): ${e.message}');
          // If profile is not found (PGRST116), it's a critical issue for a logged-in user.
          // Returning null will effectively make the app treat the user as logged out.
          return null;
        } catch (e) {
          print('Error fetching profile on authStateChange: $e');
          // For other errors during profile fetch, also return null.
          return null;
        }
      } else if (authState.event == AuthChangeEvent.signedOut) {
        return null;
      }
      // For other events like tokenRefreshed, mfaChallenge, etc.,
      // we don't have a new UserEntity to emit, so we can return null
      // or fetch the current user again if needed, but that might be redundant
      // if the user data hasn't changed. For now, only signIn and userUpdated trigger profile fetch.
      // If the stream needs to emit the current user on token refresh, this logic would need adjustment.
      // However, onAuthStateChange usually emits userUpdated after token refresh if user data changed.
      return null; // Default to null for other states we don't explicitly handle by fetching profile
    });
  }
}
