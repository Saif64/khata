import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:presentation/core/theme/app_theme.dart';
import 'package:presentation/src/features/auth/provider/auth.dart';
import 'package:presentation/src/features/home/adapters/transaction_adapter.dart';
import 'package:presentation/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:presentation/src/features/home/presentation/screens/add_transaction_screen.dart';
import 'package:presentation/src/features/home/presentation/screens/all_transactions_screen.dart';
import 'package:presentation/src/features/home/presentation/screens/edit_transaction_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection.dart';
import 'core/routes.dart';
import 'src/auth_wrapper.dart';
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
  Hive.registerAdapter(TransactionEntityAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  await Hive.openBox<String>('userBox');
  await Hive.openBox<TransactionEntity>('transactionBox');

  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => di<AuthRepository>(),
        ),
        RepositoryProvider<HomeRepository>(
          create: (context) => di<HomeRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                di<AuthBloc>()..add(const AuthCheckRequested()),
          ),
          BlocProvider<HomeBloc>(
            create: (context) => di<HomeBloc>(),
          )
        ],
        child: MaterialApp(
          title: 'Khata',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routes: {
            '/': (context) => const AuthWrapper(),
            Routes.SIGN_IN: (context) => const SignInScreen(),
            Routes.SIGN_UP: (context) => const SignUpScreen(),
            Routes.HOME: (context) => const HomeScreen(),
            Routes.ALL_TRANSACTION: (context) => const AllTransactionsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == Routes.ADD_TRANSACTION) {
              final type = settings.arguments as TransactionType;
              return MaterialPageRoute(
                builder: (context) => AddTransactionScreen(type: type),
              );
            }
            if (settings.name == Routes.EDIT_TRANSACTION) {
              final transaction = settings.arguments as TransactionEntity;
              return MaterialPageRoute(
                builder: (context) =>
                    EditTransactionScreen(transaction: transaction),
              );
            }
            return null;
          },
          initialRoute: '/',
        ),
      ),
    );
  }
}
