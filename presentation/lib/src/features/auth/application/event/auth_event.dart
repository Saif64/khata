import 'package:equatable/equatable.dart';
import 'package:domain/domain.dart'; // For UserEntity

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

class SignInWithPhoneRequested extends AuthEvent {
  final String phone;
  final String password;

  const SignInWithPhoneRequested({
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [phone, password];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

// Private event for internal BLoC use
class _AuthStateChanged extends AuthEvent {
  final UserEntity? user;

  const _AuthStateChanged(this.user);

  @override
  List<Object?> get props => [user];
}
