import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import '../../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository_interface.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryInterface authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<FacebookSignInRequested>(_onFacebookSignInRequested);
    on<SignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<SignUpWithEmailRequested>(_onSignUpWithEmailRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<SendPasswordResetEmailRequested>(_onSendPasswordResetEmailRequested);
    on<AuthStateChanged>(_onAuthStateChanged);
  }

  Future<UserModel> _convertToUserModel(User user) async {
    try {
      final userData = await authRepository.getCurrentUserData(user.uid);
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        currentWeight: userData.currentWeight,
        targetWeight: userData.targetWeight,
        height: userData.height,
        gender: userData.gender,
        dateOfBirth: userData.dateOfBirth,
        activityLevel: userData.activityLevel,
        dailyCalorieGoal: userData.dailyCalorieGoal,
      );
    } catch (e) {
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await authRepository.signInWithGoogle();
      final user = userCredential.user!;
      final userModel = await _convertToUserModel(user);
      emit(Authenticated(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onFacebookSignInRequested(
    FacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await authRepository.signInWithFacebook();
      final firebaseUser = userCredential.user!;
      final userModel = await _convertToUserModel(firebaseUser);
      emit(Authenticated(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithEmailRequested(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      final userModel = await _convertToUserModel(userCredential.user!);
      emit(Authenticated(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpWithEmailRequested(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      final userModel = await _convertToUserModel(userCredential.user!);
      emit(Authenticated(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendPasswordResetEmailRequested(
    SendPasswordResetEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.sendPasswordResetEmail(event.email);
      emit(PasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthStateChanged(
    AuthStateChanged event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final userModel = await authRepository.authStateChanges.first;
      if (userModel != null) {
        emit(Authenticated(userModel));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
