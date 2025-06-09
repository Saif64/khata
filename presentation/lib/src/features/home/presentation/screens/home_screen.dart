import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/auth/provider/auth.dart'; // Adjusted path

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutRequested());
            },
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            // Navigate back to SignInScreen after sign out
            Navigator.pushNamedAndRemoveUntil(
                context, '/signIn', (route) => false);
          } else if (state is AuthFailureState) {
            // Optionally show error during sign out, though less common
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Sign out failed: ${state.message}")),
            );
          }
        },
        child: const Center(
          child: Text('Welcome!'),
        ),
      ),
    );
  }
}
