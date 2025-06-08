abstract class AuthFailure {
  final String message;

  AuthFailure(this.message);
}

class ServerFailure extends AuthFailure {
  ServerFailure(String message) : super(message);
}

class InvalidCredentialsFailure extends AuthFailure {
  InvalidCredentialsFailure(String message) : super(message);
}

class UserNotFoundFailure extends AuthFailure {
  UserNotFoundFailure(String message) : super(message);
}

class UserAlreadyExistsFailure extends AuthFailure {
  UserAlreadyExistsFailure(String message) : super(message);
}

class NetworkFailure extends AuthFailure {
  NetworkFailure(String message) : super(message);
}

class UnknownFailure extends AuthFailure {
  UnknownFailure(String message) : super(message);
}
