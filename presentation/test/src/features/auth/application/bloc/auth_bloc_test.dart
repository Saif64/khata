import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:presentation/src/features/auth/application/auth.dart';
import 'package:domain/domain.dart'; // Imports UserEntity, AuthRepository, AuthFailure types

// Manual Mock for AuthRepository
// Normally, you'd use @GenerateMocks([AuthRepository]) and build_runner
// For this subtask, a manual mock is simpler to implement directly.
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late UserEntity testUser;
  // A user entity that is different from testUser for specific stream tests
  late UserEntity anotherTestUser;

  setUp(() {
    mockAuthRepository = MockAuthRepository();

    // Define a default behavior for authStateChanges BEFORE bloc creation
    // This ensures the subscription in AuthBloc constructor doesn't throw/fail.
    // Individual tests can override this behavior if they test authStateChanges specifically.
    when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));

    authBloc = AuthBloc(mockAuthRepository);

    testUser = const UserEntity(id: '1', name: 'Test User', phone: '1234567890', email: 'test@example.com');
    anotherTestUser = const UserEntity(id: '2', name: 'Another User', phone: '0987654321', email: 'another@example.com');
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state is AuthInitial', () {
    // The AuthBloc constructor subscribes to authStateChanges.
    // If authStateChanges immediately emits a value (e.g. from a BehaviorSubject-like stream),
    // the state might transition away from AuthInitial very quickly.
    // Our default mock `Stream.value(null)` will cause it to go to Unauthenticated.
    // To test AuthInitial, we'd need a stream that doesn't emit immediately, or test the state *before* stream emission.
    // However, bloc_test handles this by setting up the bloc within `build` which is cleaner.
    // For this simple test, given the current setup, it will likely be Unauthenticated due to Stream.value(null).
    // Let's adjust the expectation or the default stream for this specific initial test.

    // Option 1: Expect Unauthenticated if Stream.value(null) is used in setUp's default mock.
    // expect(authBloc.state, const Unauthenticated());

    // Option 2: Create a bloc with a stream that hasn't emitted yet for this specific test.
    // This is what blocTest's `build` does internally.
    final freshAuthBloc = AuthBloc(MockAuthRepository()); // New mock that hasn't been told to emit on authStateChanges
    expect(freshAuthBloc.state, const AuthInitial());
    freshAuthBloc.close();
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when getCurrentUser returns a user',
      build: () {
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), Authenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when getCurrentUser returns null',
      build: () {
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Right(null));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when getCurrentUser returns a failure',
      build: () {
        when(mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Left(ServerFailure('Server Error')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthCheckRequested()),
      expect: () => [const AuthLoading(), const AuthFailureState('Server Error')],
    );
  });

  group('SignUpRequested', () {
    const signUpParams = SignUpRequested(
      name: 'New User',
      phone: '1122334455',
      password: 'password',
      email: 'new@example.com',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when signUp is successful',
      build: () {
        when(mockAuthRepository.signUp(
          name: signUpParams.name,
          phone: signUpParams.phone,
          password: signUpParams.password,
          email: signUpParams.email,
          profileUrl: signUpParams.profileUrl,
        )).thenAnswer((_) async => Right(testUser)); // Assuming signUp returns the user
        return authBloc;
      },
      act: (bloc) => bloc.add(signUpParams),
      expect: () => [const AuthLoading(), Authenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when signUp fails',
      build: () {
        when(mockAuthRepository.signUp(
          name: signUpParams.name,
          phone: signUpParams.phone,
          password: signUpParams.password,
          email: signUpParams.email,
          profileUrl: signUpParams.profileUrl,
        )).thenAnswer((_) async => Left(UserAlreadyExistsFailure('User exists')));
        return authBloc;
      },
      act: (bloc) => bloc.add(signUpParams),
      expect: () => [const AuthLoading(), const AuthFailureState('User exists')],
    );
  });

  group('SignInWithPhoneRequested', () {
    const signInParams = SignInWithPhoneRequested(
      phone: '1234567890',
      password: 'password',
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when signInWithPhone is successful',
      build: () {
        when(mockAuthRepository.signInWithPhone(
          phone: signInParams.phone,
          password: signInParams.password,
        )).thenAnswer((_) async => Right(testUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(signInParams),
      expect: () => [const AuthLoading(), Authenticated(testUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when signInWithPhone fails',
      build: () {
        when(mockAuthRepository.signInWithPhone(
          phone: signInParams.phone,
          password: signInParams.password,
        )).thenAnswer((_) async => Left(InvalidCredentialsFailure('Invalid credentials')));
        return authBloc;
      },
      act: (bloc) => bloc.add(signInParams),
      expect: () => [const AuthLoading(), const AuthFailureState('Invalid credentials')],
    );
  });

  group('SignOutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when signOut is successful',
      build: () {
        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => const Right(unit));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignOutRequested()),
      expect: () => [const AuthLoading(), const Unauthenticated(message: 'Successfully signed out.')],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailureState] when signOut fails',
      build: () {
        when(mockAuthRepository.signOut())
            .thenAnswer((_) async => Left(ServerFailure('Server Error')));
        return authBloc;
      },
      act: (bloc) => bloc.add(const SignOutRequested()),
      expect: () => [const AuthLoading(), const AuthFailureState('Server Error')],
    );
  });

  group('_AuthStateChanged (via authStateChanges stream)', () {
    // For these tests, we need to create a new AuthBloc instance within `build`
    // because the subscription to `authStateChanges` happens in the constructor.
    // blocTest's `build` callback is perfect for this.

    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated] when authStateChanges emits a user',
      build: () {
        // Override the default stream mock for this specific test
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(anotherTestUser));
        return AuthBloc(mockAuthRepository); // New bloc with the specific stream
      },
      // No act: event is triggered by stream upon subscription
      expect: () => [Authenticated(anotherTestUser)],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Unauthenticated] when authStateChanges emits null',
      build: () {
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.value(null));
        return AuthBloc(mockAuthRepository); // New bloc
      },
      expect: () => [const Unauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [Authenticated, Unauthenticated] when authStateChanges emits user then null',
      build: () {
        when(mockAuthRepository.authStateChanges).thenAnswer((_) => Stream.fromIterable([testUser, null]));
        return AuthBloc(mockAuthRepository);
      },
      expect: () => [Authenticated(testUser), const Unauthenticated()],
    );
  });
}
