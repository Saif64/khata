import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/provider/auth.dart';
import 'features/home/presentation/screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomeScreen();
        }
        if (state is Unauthenticated || state is AuthFailureState) {
          // If AuthFailureState, could show SignInScreen with an error,
          // but for now, SignInScreen handles showing its own errors via SnackBar.
          return const SignInScreen();
        }
        // AuthInitial or AuthLoading
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
