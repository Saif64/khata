import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:presentation/src/features/auth/application/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final di = GetIt.instance;

void setupLocator() {
  // === Register Services ===
  // Register SupabaseClient as a lazy singleton. It will be created only when first needed.
  di.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // === Register Repositories ===
  // Register AuthRepository. When an AuthRepository is requested, GetIt will
  // create an AuthRepositoryImpl, providing it with the SupabaseClient instance.
  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(di<SupabaseClient>()),
  );

  // === Register BLoCs / ViewModels ===
  // Register AuthBloc as a factory. A new instance will be created every time it's requested.
  di.registerFactory<AuthBloc>(
    () => AuthBloc(di<AuthRepository>()),
  );
}
