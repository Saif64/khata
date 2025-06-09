import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:presentation/core/theme/app_theme.dart';

import '../../provider/auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const routeName = '/signUp';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _profileUrlController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _profileUrlController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _signUp(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SignUpRequested(
            name: _nameController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
            email: _emailController.text.isEmpty ? null : _emailController.text,
            profileUrl: _profileUrlController.text.isEmpty
                ? null
                : _profileUrlController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() {
            _isLoading = state is AuthLoading;
          });

          if (state is Authenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          // Welcome Text
                          Text(
                            'Create Account',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join us and get started',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.black.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Form Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.cardBackground,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Full Name',
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: colorScheme.primary,
                                      ),
                                      fillColor: colorScheme.inputFill,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _phoneController,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      prefixIcon: Icon(
                                        Icons.phone_outlined,
                                        color: colorScheme.primary,
                                      ),
                                      fillColor: colorScheme.inputFill,
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email (Optional)',
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: colorScheme.primary,
                                      ),
                                      fillColor: colorScheme.inputFill,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: colorScheme.primary,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      fillColor: colorScheme.inputFill,
                                    ),
                                    obscureText: _obscurePassword,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _profileUrlController,
                                    decoration: InputDecoration(
                                      labelText: 'Profile URL (Optional)',
                                      prefixIcon: Icon(
                                        Icons.image_outlined,
                                        color: colorScheme.primary,
                                      ),
                                      fillColor: colorScheme.inputFill,
                                    ),
                                  ),
                                  const SizedBox(height: 32),

                                  // Sign Up Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: _isLoading
                                        ? Container(
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(
                                                    Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : ElevatedButton(
                                            onPressed: () => _signUp(context),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  colorScheme.primary,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Create Account'),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sign In Link
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : Colors.black.withOpacity(0.6),
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
