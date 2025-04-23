import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../home/home_page.dart';
import '../onboarding_screen.dart';
import 'signup_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignInWithEmailRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  void _handleGoogleSignIn() {
    context.read<AuthBloc>().add(const GoogleSignInRequested());
  }

  void _handleFacebookSignIn() {
    context.read<AuthBloc>().add(const FacebookSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    // Set system overlay style for a more immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(10),
              ),
            );
          } else if (state is Authenticated) {
            if (state.user.hasCompletedProfile) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const OnboardingScreen(),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // App Logo Animation
                    Center(
                      child: Hero(
                        tag: 'app_logo',
                        child: SizedBox(
                          height: 150,
                          child: Lottie.asset(
                            'assets/animations/fitness_animation.json',
                            repeat: true,
                            animate: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Welcome Text
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Welcome to SlimSense',
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your personal fitness companion',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Social Login Buttons
                    Text(
                      'Sign in with',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Google Sign In Button
                    SocialLoginButton(
                      icon: FontAwesomeIcons.google,
                      text: 'Continue with Google',
                      backgroundColor: Colors.white,
                      textColor: Colors.black87,
                      isLoading: state is AuthLoading,
                      onPressed: _handleGoogleSignIn,
                    ),
                    const SizedBox(height: 12),
                    // Facebook Sign In Button
                    SocialLoginButton(
                      icon: FontAwesomeIcons.facebook,
                      text: 'Continue with Facebook',
                      backgroundColor: const Color(0xFF1877F2),
                      textColor: Colors.white,
                      isLoading: state is AuthLoading,
                      onPressed: _handleFacebookSignIn,
                    ),
                    const SizedBox(height: 24),

                    // Divider with OR text
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.lock_outlined,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleLogin(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login Button
                    PrimaryButton(
                      text: 'Sign In with Email',
                      isLoading: state is AuthLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 24),
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const SignupPage(),
                                transitionsBuilder: (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOut;
                                  var tween = Tween(
                                    begin: begin,
                                    end: end,
                                  ).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Custom Widgets for better UI
class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final bool isLoading;
  final VoidCallback? onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 1,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            )
          else
            FaIcon(icon, size: 18),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Widget? suffixIcon;
  final Function(String)? onFieldSubmitted;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child:
          isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }
}
