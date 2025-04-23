import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/user_model.dart';
import 'auth_repository_interface.dart';

class AuthRepository implements AuthRepositoryInterface {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    required FirebaseFirestore firestore,
    required SharedPreferences prefs,
    required GoogleSignIn googleSignIn,
    required FacebookAuth facebookAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore,
       _prefs = prefs,
       _googleSignIn = googleSignIn,
       _facebookAuth = facebookAuth;

  @override
  Future<UserCredential> signInWithGoogle() async {
    // TODO: Implement Google Sign In
    throw UnimplementedError();
  }

  @override
  Future<UserCredential> signInWithFacebook() async {
    // TODO: Implement Facebook Sign In
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user?.updateDisplayName(name);
    return userCredential;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Stream<UserModel?> get authStateChanges =>
      _firebaseAuth.authStateChanges().asyncMap((user) {
        if (user == null) {
          return null;
        }
        try {
          return getCurrentUserData(user.uid);
        } catch (e) {
          print('Error mapping auth state: $e');
          return null;
        }
      });

  @override
  Future<UserModel> getCurrentUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromMap({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    // TODO: Implement updating user profile in Firestore
  }

  @override
  Future<void> updateUserPhoto(String photoUrl) async {
    // TODO: Implement updating user photo in Firestore
  }
}
