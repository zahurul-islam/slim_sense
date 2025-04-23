import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../presentation/themes/app_colors.dart';
import '../../../presentation/themes/app_typography.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../onboarding_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleObscurePassword() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleObscureConfirmPassword() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  void _signup() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      // Hide keyboard
      FocusScope.of(context).unfocus();
      
      // Trigger signup
      context.read<AuthBloc>().add(
        SignUpWithEmailEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Privacy Policy'),
          backgroundColor: AppColors.errorColor,
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
          if (state is AuthenticatedState) {
            // Navigate to onboarding after signup
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
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
                    // App Logo (smaller for signup)
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDarkColor.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.fitness_center,
                            size: 40,
                            color: AppColors.textWhiteColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      "Create Account",
                      style: AppTypography.heading2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      "Join ${AppConstants.appName} and start your weight loss journey",
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    // Signup Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Name Field
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
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
                          const SizedBox(height: 16),
                          
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: _toggleObscurePassword,
                              ),
                            ),
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
                          
                          // Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: 'Confirm your password',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: _toggleObscureConfirmPassword,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          
                          // Terms and Conditions Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToTerms = value ?? false;
                                  });
                                },
                                activeColor: AppColors.primaryColor,
                              ),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text: 'I agree to the ',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondaryColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' and ',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondaryColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Sign Up Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state is AuthLoadingState ? null : _signup,
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
                                    : const Text('Sign Up'),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Already have account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: AppTypography.bodyMedium,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Log In',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
