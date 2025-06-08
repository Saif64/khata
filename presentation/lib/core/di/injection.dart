import 'package:get_it/get_it.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added import

import 'injection.config.dart';

final locator = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // Manually register SupabaseClient if not already handled by a module in injectable.
  // This ensures it's available for AuthRepositoryImpl or other services.
  // Supabase.instance.client is initialized in main.dart before this function is called.
  if (!locator.isRegistered<SupabaseClient>()) {
    locator.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }
  await locator.init();
}
