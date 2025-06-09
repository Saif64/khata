import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../src/features/auth/provider/auth.dart';

final di = GetIt.instance;

void setupLocator() {
  di.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  di.registerLazySingleton<Box<String>>(() => Hive.box<String>('userBox'));

  di.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(di<SupabaseClient>()),
  );
  di.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(di<Box<String>>()),
  );

  di.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
        di<AuthRemoteDataSource>(), di<AuthLocalDataSource>()),
  );

  di.registerFactory<AuthBloc>(
    () => AuthBloc(di<AuthRepository>()),
  );
}
