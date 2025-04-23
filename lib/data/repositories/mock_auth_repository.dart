import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'auth_repository_interface.dart';

// Mock classes for Firebase Auth
class MockUser implements User {
  @override
  final String uid;

  @override
  final String? email;

  @override
  final String? displayName;

  @override
  final String? photoURL;

  MockUser({required this.uid, this.email, this.displayName, this.photoURL});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserCredential implements UserCredential {
  @override
  final User? user;

  MockUserCredential({this.user});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthRepository implements AuthRepositoryInterface {
  final SharedPreferences prefs;
  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  MockAuthRepository({required this.prefs}) {
    // Initialize with a demo user for development
    _authStateController.add(_createDemoUser());
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  UserModel _createDemoUser() {
    return UserModel(
      id: 'demo-user-id',
      email: 'demo@example.com',
      displayName: 'Demo User',
      photoUrl:
          'https://ui-avatars.com/api/?name=Demo+User&background=6200EE&color=fff',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      currentWeight: 70.0,
      targetWeight: 65.0,
      height: 170.0,
      gender: 'Male',
      dateOfBirth: DateTime(1990, 1, 1),
      activityLevel: 'Moderate',
      dailyCalorieGoal: 2000,
    );
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    // Simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Create a demo user with Google profile
      final user = _createDemoUser().copyWith(
        displayName: 'Google User',
        email: 'google_user@example.com',
        photoUrl:
            'https://ui-avatars.com/api/?name=Google+User&background=4285F4&color=fff',
      );

      // Add to auth state stream
      _authStateController.add(user);

      // Return a mock UserCredential
      return MockUserCredential(
        user: MockUser(
          uid: user.id,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoUrl,
        ),
      );
    } catch (e) {
      debugPrint('Error in mock Google sign in: $e');
      rethrow;
    }
  }

  @override
  Future<UserCredential> signInWithFacebook() async {
    // Simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Create a demo user with Facebook profile
      final user = _createDemoUser().copyWith(
        displayName: 'Facebook User',
        email: 'facebook_user@example.com',
        photoUrl:
            'https://ui-avatars.com/api/?name=Facebook+User&background=1877F2&color=fff',
      );

      // Add to auth state stream
      _authStateController.add(user);

      // Return a mock UserCredential
      return MockUserCredential(
        user: MockUser(
          uid: user.id,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoUrl,
        ),
      );
    } catch (e) {
      debugPrint('Error in mock Facebook sign in: $e');
      rethrow;
    }
  }

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Create a demo user with email profile
      final user = _createDemoUser().copyWith(
        displayName: email.split('@')[0],
        email: email,
        photoUrl:
            'https://ui-avatars.com/api/?name=${email.split('@')[0]}&background=6200EE&color=fff',
      );

      // Add to auth state stream
      _authStateController.add(user);

      // Return a mock UserCredential
      return MockUserCredential(
        user: MockUser(
          uid: user.id,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoUrl,
        ),
      );
    } catch (e) {
      debugPrint('Error in mock email sign in: $e');
      rethrow;
    }
  }

  @override
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    // Simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Create a new user with the provided name
      final user = UserModel(
        id: 'demo-user-id',
        email: email,
        displayName: name,
        photoUrl:
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=6200EE&color=fff',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        // Profile is incomplete - user will be directed to onboarding
      );

      _authStateController.add(user);

      // Return a mock UserCredential
      return MockUserCredential(
        user: MockUser(
          uid: user.id,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoUrl,
        ),
      );
    } catch (e) {
      debugPrint('Error in mock email sign up: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    // Simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    // Clear the current user
    _authStateController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would send an email
    debugPrint('Mock: Password reset email sent to $email');
  }

  @override
  Future<UserModel> getCurrentUserData(String userId) async {
    // Return the demo user data
    return _createDemoUser();
  }

  void dispose() {
    _authStateController.close();
  }

  @override
  User? getCurrentUser() {
    // Mock implementation doesn't have a real Firebase User
    return null;
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Update the current user in the stream
    _authStateController.add(user);
  }

  @override
  Future<void> updateUserPhoto(String photoUrl) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Get the current user
    final currentUser = await authStateChanges.first;

    if (currentUser != null) {
      // Update the photo URL
      final updatedUser = currentUser.copyWith(photoUrl: photoUrl);

      // Update the stream
      _authStateController.add(updatedUser);
    }
  }
}
