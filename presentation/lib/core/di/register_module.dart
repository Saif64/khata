import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RegisterModule {
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
