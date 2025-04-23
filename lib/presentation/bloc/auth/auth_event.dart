import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class GoogleSignInRequested extends AuthEvent {
  const GoogleSignInRequested();
}

class FacebookSignInRequested extends AuthEvent {
  const FacebookSignInRequested();
}

class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailRequested({required this.email, required this.password});
  
  @override
  List<Object?> get props => [email, password];
}

class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.name,
  });
  
  @override
  List<Object?> get props => [email, password, name];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class SendPasswordResetEmailRequested extends AuthEvent {
  final String email;

  const SendPasswordResetEmailRequested(this.email);
  
  @override
  List<Object?> get props => [email];
}

class AuthStateChanged extends AuthEvent {
  const AuthStateChanged();
}
