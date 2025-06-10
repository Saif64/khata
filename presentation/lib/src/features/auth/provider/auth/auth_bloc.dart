import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<UserEntity?>? _userSubscription;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    _userSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthStateChanged(user)),
    );

    on<AuthStateChanged>((event, emit) {
      final user = event.user;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    });

    on<AuthCheckRequested>((event, emit) async {
      emit(const AuthLoading());
      final failureOrUser = await _authRepository.getCurrentUser();
      failureOrUser.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (user) {
          if (user != null) {
            emit(Authenticated(user));
          } else {
            emit(const Unauthenticated());
          }
        },
      );
    });

    on<SignUpRequested>((event, emit) async {
      emit(const AuthLoading());
      final failureOrUser = await _authRepository.signUp(
        name: event.name,
        phone: event.phone,
        password: event.password,
        email: event.email,
        profileUrl: event.profileUrl,
      );
      failureOrUser.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    });

    on<SignInWithEmailRequested>((event, emit) async {
      emit(const AuthLoading());
      final failureOrUser = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      failureOrUser.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    });

    on<SignInWithGoogleRequested>((event, emit) async {
      emit(const AuthLoading());
      final failureOrUser = await _authRepository.signInWithGoogle();
      failureOrUser.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    });

    on<SignInWithFacebookRequested>((event, emit) async {
      emit(const AuthLoading());
      final failureOrUser = await _authRepository.signInWithFacebook();
      failureOrUser.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    });

    on<SignOutRequested>((event, emit) async {
      emit(const AuthLoading());
      final failureOrVoid = await _authRepository.signOut();
      failureOrVoid.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (_) => emit(const Unauthenticated(message: 'Successfully signed out.')),
      );
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
