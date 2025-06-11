import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../src/features/auth/provider/auth.dart';

final di = GetIt.instance;

void setupLocator() {
  di.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  di.registerLazySingleton<Box<String>>(() => Hive.box<String>('userBox'));

  di.registerLazySingleton<Box<TransactionEntity>>(
      () => Hive.box<TransactionEntity>('transactionBox'));

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

  di.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(di<SupabaseClient>()),
  );
  di.registerLazySingleton<HomeLocalDataSource>(
    () => HomeLocalDataSourceImpl(di<Box<TransactionEntity>>()),
  );
  di.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(
        di<HomeRemoteDataSource>(), di<HomeLocalDataSource>()),
  );
  di.registerFactory<HomeBloc>(
    () => HomeBloc(di<HomeRepository>()),
  );
}
