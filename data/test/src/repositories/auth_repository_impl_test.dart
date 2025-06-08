import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:data/src/repositories/auth_repository_impl.dart';
import 'package:domain/domain.dart';


// --- Mocks ---
// Normally, you'd use @GenerateMocks and build_runner.
// For this subtask, manual mocks are used.

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockUser extends Mock implements User {} // Supabase User class
class MockSession extends Mock implements Session {} // Supabase Session class
class MockAuthResponse extends Mock implements AuthResponse {}
// PostgrestResponse is not directly part of SupabaseQueryBuilder's fluent interface for insert/update
// but operations like .execute() or .then() might yield it or its data.
// For .single(), it returns Map<String, dynamic>. For .insert(), it might return nothing or throw.

void main() {
  late AuthRepositoryImpl authRepository;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockSupabaseUser;
  // late MockSession mockSession; // Not directly used in current tests, but good to have if needed
  late MockAuthResponse mockAuthResponse;
  late MockSupabaseQueryBuilder mockQueryBuilder;

  final testUserEntity = UserEntity(
    id: 'user-id',
    name: 'Test User',
    phone: '1234567890',
    email: 'test@example.com',
    profileUrl: 'http://example.com/profile.png',
  );

  final testSupabaseUserMap = {
    'id': 'user-id',
    'name': 'Test User',
    'phone': '1234567890',
    'email': 'test@example.com',
    'profile_url': 'http://example.com/profile.png',
  };

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockSupabaseUser = MockUser();
    // mockSession = MockSession();
    mockAuthResponse = MockAuthResponse();
    mockQueryBuilder = MockSupabaseQueryBuilder();

    authRepository = AuthRepositoryImpl(mockSupabaseClient);

    // Default behaviors
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(mockSupabaseClient.from(any)).thenReturn(mockQueryBuilder);

    // QueryBuilder chaining defaults - return the mockQueryBuilder itself for chaining
    when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
    when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder); // For insert, it's often just awaited or returns specific type not query builder
    when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);
    when(mockQueryBuilder.single()).thenAnswer((_) async => {}); // Default for .single() to return empty map

    // Default Supabase User properties
    when(mockSupabaseUser.id).thenReturn(testUserEntity.id);
    when(mockSupabaseUser.phone).thenReturn(testUserEntity.phone);
    when(mockSupabaseUser.email).thenReturn(testUserEntity.email);

    // Default AuthResponse
    when(mockAuthResponse.user).thenReturn(mockSupabaseUser);
    // when(mockAuthResponse.session).thenReturn(mockSession); // If session is needed
  });

  group('signUp', () {
    test('success', () async {
      // Arrange
      when(mockGoTrueClient.signUp(
        phone: testUserEntity.phone,
        password: 'password',
        // Supabase signUp doesn't take name/email/profileUrl directly in GoTrueClient,
        // these are handled by inserting into 'profiles' table.
      )).thenAnswer((_) async => mockAuthResponse);

      // Mock the insert into 'profiles' table - important: insert often returns void or specific result, not QueryBuilder
      // For a successful insert, the 'thenAnswer' for insert should represent that.
      // If using `execute()` for PostgREST, it returns a PostgrestResponse.
      // If just awaiting `insert()`, it might return void or throw on error.
      // Let's assume `insert()` itself doesn't throw for success.
      // And it returns a dynamic type that we might not need to chain further for this test.
      // So, we don't need a specific `thenReturn` for `mockQueryBuilder.insert(any)` unless it's chained.
      // The key is that it doesn't throw an exception.
      // If `insert` returns `PostgrestResponse<dynamic>`, then mock it.
      // For simplicity, assume `await insert()` completes without error.
      // We are verifying the call to insert, not its chained result for this success case.
      // The `when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);` in setUp might be too generic.
      // Let's override it for this specific test if needed, or ensure it does not throw.
      // For this test, we'll assume the insert call itself (if it returns void or the data itself) is successful.
      // If the actual code is `await ...insert(...).execute()`, then mock `execute()`.
      // The current AuthRepositoryImpl code is `await supabaseClient.from('profiles').insert(...)`
      // This returns Future<void> or Future<List<Map<String, dynamic>>> based on PostgREST client.
      // Assuming it returns void or data that we don't check further in this success path for insert.
      // So, the default `when(mockQueryBuilder.insert(any)).thenReturn(mockQueryBuilder);` is okay if no further chaining on insert.
      // Let's make it more explicit for insert if it returns void/data and not chainable:
      when(mockSupabaseClient.from('profiles').insert(any)).thenAnswer((_) async => []); // Simulate successful insert returning list (often empty for insert)


      // Act
      final result = await authRepository.signUp(
        name: testUserEntity.name,
        phone: testUserEntity.phone,
        password: 'password',
        email: testUserEntity.email,
        profileUrl: testUserEntity.profileUrl,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('should be Right, got ${l.message}'),
        (r) {
          expect(r.id, testUserEntity.id);
          expect(r.name, testUserEntity.name);
          expect(r.phone, testUserEntity.phone);
        },
      );
      verify(mockSupabaseClient.from('profiles').insert(any)).called(1);
    });

    test('auth error (user already exists)', () async {
      // Arrange
      when(mockGoTrueClient.signUp(phone: 'phone', password: 'password'))
          .thenThrow(AuthException('User already exists', statusCode: '422')); // Common for user already exists

      // Act
      final result = await authRepository.signUp(name: 'Test', phone: 'phone', password: 'password');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<UserAlreadyExistsFailure>());
          expect(failure.message, contains('User with this phone already exists.'));
        },
        (_) => fail('should be Left'),
      );
    });

    test('network error during signUp', () async {
      when(mockGoTrueClient.signUp(phone: 'phone', password: 'password'))
          .thenThrow(AuthException('Network error')); // Generic AuthException for network
      final result = await authRepository.signUp(name: 'Test', phone: 'phone', password: 'password');
      expect(result.isLeft(), true);
      result.fold((l) => expect(l, isA<NetworkFailure>()), (r) => fail('Should be Left'));
    });


    test('profile insert fails (PostgrestException)', () async {
      // Arrange
      when(mockGoTrueClient.signUp(
        phone: testUserEntity.phone,
        password: 'password',
      )).thenAnswer((_) async => mockAuthResponse);
      // No need to mock mockAuthResponse.user as it's defaulted in setUp.

      when(mockSupabaseClient.from('profiles').insert(any))
          .thenThrow(PostgrestException(message: 'Insert failed due to constraint', code: '23505')); // Example: unique constraint violation

      // Act
      final result = await authRepository.signUp(
        name: testUserEntity.name,
        phone: testUserEntity.phone,
        password: 'password',
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
            expect(failure, isA<ServerFailure>()); // Mapped to ServerFailure in impl
            expect(failure.message, contains('Database error: Insert failed due to constraint'));
        },
        (_) => fail('should be Left'),
      );
    });
  });

  group('signInWithPhone', () {
    test('success', () async {
      // Arrange
      when(mockGoTrueClient.signInWithPassword(phone: 'phone', password: 'password'))
          .thenAnswer((_) async => mockAuthResponse);
      // mockSupabaseUser is returned by mockAuthResponse by default from setUp

      when(mockQueryBuilder.single()).thenAnswer((_) async => testSupabaseUserMap);

      // Act
      final result = await authRepository.signInWithPhone(phone: 'phone', password: 'password');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('should be Right, got ${l.message}'),
        (r) {
          expect(r.id, testUserEntity.id);
          expect(r.name, testUserEntity.name);
        },
      );
      verify(mockSupabaseClient.from('profiles').select().eq('id', testUserEntity.id).single()).called(1);
    });

    test('invalid credentials', () async {
      when(mockGoTrueClient.signInWithPassword(phone: 'phone', password: 'password'))
          .thenThrow(AuthException('Invalid login credentials'));

      final result = await authRepository.signInWithPhone(phone: 'phone', password: 'password');

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<InvalidCredentialsFailure>()),
        (r) => fail('Should be Left'),
      );
    });

    test('profile not found (PostgrestException PGRST116)', () async {
      when(mockGoTrueClient.signInWithPassword(phone: 'phone', password: 'password'))
          .thenAnswer((_) async => mockAuthResponse);

      when(mockQueryBuilder.single())
          .thenThrow(PostgrestException(message: 'Not found', code: 'PGRST116'));

      final result = await authRepository.signInWithPhone(phone: 'phone', password: 'password');

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<UserNotFoundFailure>()),
        (r) => fail('Should be Left'),
      );
    });
  });

  group('signOut', () {
    test('success', () async {
      when(mockGoTrueClient.signOut()).thenAnswer((_) async {}); // signOut returns Future<void>
      final result = await authRepository.signOut();
      expect(result.isRight(), true);
      result.fold((l) => fail('Should be Right'), (r) => expect(r, unit));
      verify(mockGoTrueClient.signOut()).called(1);
    });

    test('failure (AuthException)', () async {
      when(mockGoTrueClient.signOut()).thenThrow(AuthException('Network error'));
      final result = await authRepository.signOut();
      expect(result.isLeft(), true);
      result.fold((l) => expect(l, isA<NetworkFailure>()), (r) => fail('Should be Left'));
    });
  });

  group('getCurrentUser', () {
    test('user logged in, profile found', () async {
      when(mockGoTrueClient.currentUser).thenReturn(mockSupabaseUser);
      when(mockQueryBuilder.single()).thenAnswer((_) async => testSupabaseUserMap);

      final result = await authRepository.getCurrentUser();

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be Right'),
        (r) {
          expect(r, isNotNull);
          expect(r!.id, testUserEntity.id);
          expect(r.name, testUserEntity.name);
        },
      );
    });

    test('user not logged in', () async {
      when(mockGoTrueClient.currentUser).thenReturn(null);
      final result = await authRepository.getCurrentUser();
      expect(result.isRight(), true);
      result.fold((l) => fail('Should be Right'), (r) => expect(r, isNull));
    });

    test('user logged in, profile not found (PGRST116)', () async {
      when(mockGoTrueClient.currentUser).thenReturn(mockSupabaseUser);
      when(mockQueryBuilder.single()).thenThrow(PostgrestException(message: 'Not found', code: 'PGRST116'));

      final result = await authRepository.getCurrentUser();

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<UserNotFoundFailure>()), // As per current impl
        (r) => fail('Should be Left'),
      );
    });
  });

  group('authStateChanges', () {
    test('emits UserEntity when Supabase auth state changes to signedIn and profile is found', () async {
      // Arrange
      final authState = AuthState(AuthChangeEvent.signedIn, mockSession);
      when(mockSession.user).thenReturn(mockSupabaseUser); // Ensure session has user
      when(mockGoTrueClient.onAuthStateChange).thenAnswer((_) => Stream.value(authState));
      when(mockQueryBuilder.single()).thenAnswer((_) async => testSupabaseUserMap);

      // Act
      final stream = authRepository.authStateChanges;

      // Assert
      expect(stream, emitsInOrder([
        isA<UserEntity>()
            .having((user) => user.id, 'id', testUserEntity.id)
            .having((user) => user.name, 'name', testUserEntity.name),
        // Add more emits if the stream is expected to emit more values
      ]));
    });

    test('emits null when Supabase auth state changes to signedOut', () async {
      final authState = AuthState(AuthChangeEvent.signedOut, null); // No session on signedOut
      when(mockGoTrueClient.onAuthStateChange).thenAnswer((_) => Stream.value(authState));

      final stream = authRepository.authStateChanges;

      expect(stream, emits(isNull));
    });

    test('emits null if user is signed in but profile fetch fails (PostgrestException)', () async {
      final authState = AuthState(AuthChangeEvent.signedIn, mockSession);
      when(mockSession.user).thenReturn(mockSupabaseUser);
      when(mockGoTrueClient.onAuthStateChange).thenAnswer((_) => Stream.value(authState));
      when(mockQueryBuilder.single()).thenThrow(PostgrestException(message: 'Error', code: 'PGRST116'));

      final stream = authRepository.authStateChanges;

      // Assert that it emits null due to the error handling in the stream's map function
      expect(stream, emits(isNull));
    });
  });
}
