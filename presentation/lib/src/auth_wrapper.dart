import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation/core/widgets/loader.dart';

import 'features/auth/presentation/screens/sign_in_screen.dart';
import 'features/auth/provider/auth.dart';
import 'main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return MainLandingScreen();
        }
        if (state is Unauthenticated || state is AuthFailureState) {
          return const SignInScreen();
        }

        return Loader();
      },
    );
  }
}
