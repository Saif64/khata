import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:domain/domain.dart';

import '../event/auth_event.dart';
import '../state/auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late StreamSubscription<UserEntity?> _userSubscription;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    _userSubscription = _authRepository.authStateChanges.listen(
      (user) => add(_AuthStateChanged(user)),
    );

    on<_AuthStateChanged>((event, emit) {
      if (event.user != null) {
        emit(Authenticated(event.user!));
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
        (user) => emit(Authenticated(user)), // AuthStateChanged will also fire
      );
    });

    on<SignInWithPhoneRequested>((event, emit) async {
      emit(const AuthLoading());
      final failureOrUser = await _authRepository.signInWithPhone(
        phone: event.phone,
        password: event.password,
      );
      failureOrUser.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (user) => emit(Authenticated(user)), // AuthStateChanged will also fire
      );
    });

    on<SignOutRequested>((event, emit) async {
      emit(const AuthLoading());
      final failureOrVoid = await _authRepository.signOut();
      failureOrVoid.fold(
        (failure) => emit(AuthFailureState(failure.message)),
        (_) => emit(const Unauthenticated(message: 'Successfully signed out.')), // AuthStateChanged will also fire
      );
    });
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
