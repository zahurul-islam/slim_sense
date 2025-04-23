import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../presentation/themes/app_colors.dart';
import '../../../presentation/themes/app_typography.dart';
import '../../bloc/auth/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      // Hide keyboard
      FocusScope.of(context).unfocus();
      
      // Trigger password reset
      context.read<AuthBloc>().add(
        ResetPasswordEvent(
          email: _emailController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryColor),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSentState) {
            // Show success message and navigate back
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset email sent. Please check your inbox.'),
                backgroundColor: AppColors.successColor,
              ),
            );
            
            // Navigate back after a short delay
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context).pop();
            });
          } else if (state is AuthErrorState) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorColor,
              ),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    const Icon(
                      Icons.lock_reset,
                      size: 80,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      "Forgot Password",
                      style: AppTypography.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    
                    // Instructions
                    Text(
                      "Enter your email address below, and we'll send you instructions to reset your password.",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Reset Password Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              // Simple email validation
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Reset Password Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state is AuthLoadingState ? null : _resetPassword,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: AppColors.textWhiteColor,
                                ),
                                child: state is AuthLoadingState
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: AppColors.textWhiteColor,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Reset Password'),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Back to Login
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Back to Login',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
