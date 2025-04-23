import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRepositoryInterface {
  Stream<UserModel?> get authStateChanges;

  Future<UserCredential> signInWithGoogle();

  Future<UserCredential> signInWithFacebook();

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel> getCurrentUserData(String userId);

  // Additional methods needed by the user bloc
  User? getCurrentUser();

  Future<void> updateUserProfile(UserModel user);

  Future<void> updateUserPhoto(String photoUrl);
}
