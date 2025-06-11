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

    on<AuthStateChanged>(_onAuthStateChanged);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignUpRequested>(_onSignupRequested);
    on<SignInWithEmailRequested>(_onSignInWithPhone);
    on<SignInWithGoogleRequested>(_onSignInWithGoogle);
    on<SignInWithFacebookRequested>(_onSignInWithFacebook);
    on<SignOutRequested>(_onSignOut);
  }

  FutureOr<void> _onSignInWithPhone(event, emit) async {
    emit(const AuthLoading());
    final failureOrUser = await _authRepository.signInWithEmail(
      email: event.email,
      password: event.password,
    );
    failureOrUser.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  FutureOr<void> _onSignOut(event, emit) async {
    emit(const AuthLoading());
    final failureOrVoid = await _authRepository.signOut();
    failureOrVoid.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (_) => emit(const Unauthenticated(message: 'Successfully signed out.')),
    );
  }

  FutureOr<void> _onSignInWithFacebook(event, emit) async {
    emit(const AuthLoading());
    final failureOrUser = await _authRepository.signInWithFacebook();
    failureOrUser.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  FutureOr<void> _onSignInWithGoogle(event, emit) async {
    emit(const AuthLoading());
    final failureOrUser = await _authRepository.signInWithGoogle();
    failureOrUser.fold(
      (failure) => emit(AuthFailureState(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  FutureOr<void> _onSignupRequested(event, emit) async {
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
  }

  FutureOr<void> _onAuthCheckRequested(event, emit) async {
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
  }

  FutureOr<void> _onAuthStateChanged(event, emit) {
    final user = event.user;
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(const Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
