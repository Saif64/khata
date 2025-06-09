import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:presentation/core/theme/app_theme.dart';
import 'package:presentation/src/features/auth/provider/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection.dart';
import 'core/routes.dart';
import 'src/auth_wrapper.dart'; // Import the AuthWrapper
// Auth BLoC and Screens
import 'src/features/auth/presentation/screens/sign_in_screen.dart';
import 'src/features/auth/presentation/screens/sign_up_screen.dart';
import 'src/features/home/presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  await Hive.initFlutter();
  await Hive.openBox<String>('userBox');
  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'Khata',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routes: {
          '/': (context) => const AuthWrapper(), // Initial route
          Routes.SIGN_IN: (context) => const SignInScreen(),
          Routes.SIGN_UP: (context) => const SignUpScreen(),
          Routes.HOME: (context) => const HomeScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}
