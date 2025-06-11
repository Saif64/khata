import 'package:domain/domain.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class SignUpRequested extends AuthEvent {
  final String name;
  final String phone;
  final String password;
  final String? email;
  final String? profileUrl;

  const SignUpRequested({
    required this.name,
    required this.phone,
    required this.password,
    this.email,
    this.profileUrl,
  });

  @override
  List<Object?> get props => [name, phone, password, email, profileUrl];
}

class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

class SignInWithFacebookRequested extends AuthEvent {
  const SignInWithFacebookRequested();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthStateChanged extends AuthEvent {
  final UserEntity? user;

  const AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
