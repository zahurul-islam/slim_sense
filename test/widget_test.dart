import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:slim_sense/main.dart';
import 'package:slim_sense/presentation/pages/splash_screen.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() =>
      super.noSuchMethod(
            Invocation.method(#signIn, []),
            returnValue: Future.value(null),
          )
          as Future<GoogleSignInAccount?>;
}

class MockFacebookAuth extends Mock implements FacebookAuth {
  @override
  Future<LoginResult> login({
    List<String>? permissions,
    LoginBehavior? loginBehavior,
  }) =>
      super.noSuchMethod(
            Invocation.method(#login, [], {
              #permissions: permissions,
              #loginBehavior: loginBehavior,
            }),
            returnValue: Future.value(
              LoginResult(
                status: LoginStatus.failed,
                message: 'Mock login failed',
              ),
            ),
          )
          as Future<LoginResult>;
}

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Initialize mocks
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    final googleSignIn = MockGoogleSignIn();
    final facebookAuth = MockFacebookAuth();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MyApp(
        sharedPreferences: sharedPreferences,
        googleSignIn: googleSignIn,
        facebookAuth: facebookAuth,
      ),
    );
    await tester.pumpAndSettle();

    // Verify the splash screen is shown initially
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
