import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../presentation/bloc/auth/auth_bloc.dart';
import '../../../presentation/bloc/auth/auth_event.dart';
import '../../../presentation/bloc/auth/auth_state.dart';
import '../../../presentation/themes/app_colors.dart';
import '../../../presentation/themes/app_typography.dart';
import '../../../presentation/widgets/common/custom_button.dart';
import '../../../presentation/widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Text('Welcome Back', style: AppTypography.heading1),
                  const SizedBox(height: 40),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else
                    CustomButton(
                      text: 'Sign In',
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          SignInWithEmailRequested(
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
