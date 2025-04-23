import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

// App constants and themes
import 'core/constants/app_constants.dart';
import 'presentation/themes/app_theme.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/weight_repository.dart';
import 'data/repositories/food_repository.dart';
import 'data/repositories/mock_auth_repository.dart';
import 'data/repositories/mock_weight_repository.dart';
import 'data/repositories/mock_food_repository.dart';
import 'data/repositories/auth_repository_interface.dart';
import 'data/repositories/weight_repository_interface.dart';
import 'data/repositories/food_repository_interface.dart';
import 'core/services/ai_service.dart' as ai_service;

// BLoCs
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/user/user_bloc.dart';
import 'presentation/bloc/weight/weight_bloc.dart';
import 'presentation/bloc/food/food_bloc.dart';
import 'presentation/bloc/ai/ai_bloc.dart';

// Screens
import 'presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Variables to track initialization status
  bool isFirebaseInitialized = false;
  bool isHiveInitialized = false;

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Continue without Firebase in development mode
  }

  // Initialize social login services
  final googleSignIn = GoogleSignIn();
  final facebookAuth = FacebookAuth.instance;

  // Initialize Hive with error handling
  try {
    await Hive.initFlutter();
    await Hive.openBox('foodLogs');
    await Hive.openBox('weightLogs');
    await Hive.openBox('userSettings');
    isHiveInitialized = true;
    print('Hive boxes opened successfully');
  } catch (e) {
    print('Failed to open Hive boxes: $e');
    // Continue without Hive in development mode
  }

  // Get shared preferences instance
  final sharedPreferences = await SharedPreferences.getInstance();

  // Run the app with providers and BLoC
  runApp(
    MyApp(
      sharedPreferences: sharedPreferences,
      googleSignIn: googleSignIn,
      facebookAuth: facebookAuth,
      isFirebaseInitialized: isFirebaseInitialized,
      isHiveInitialized: isHiveInitialized,
    ),
  );
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final GoogleSignIn googleSignIn;
  final FacebookAuth facebookAuth;
  final bool isFirebaseInitialized;
  final bool isHiveInitialized;

  const MyApp({
    Key? key,
    required this.sharedPreferences,
    required this.googleSignIn,
    required this.facebookAuth,
    required this.isFirebaseInitialized,
    required this.isHiveInitialized,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Platform detection
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS;

    // Initialize Firebase instances or mock implementations
    final firebaseAuth = isFirebaseInitialized ? FirebaseAuth.instance : null;
    final firestore = isFirebaseInitialized ? FirebaseFirestore.instance : null;

    // Initialize Dio for network requests
    final dio =
        Dio()
          ..options.connectTimeout = Duration(
            seconds: AppConstants.apiTimeoutDuration,
          )
          ..options.receiveTimeout = Duration(
            seconds: AppConstants.apiTimeoutDuration,
          );

    // Initialize repositories with mock implementations if needed
    final authRepository =
        isFirebaseInitialized
            ? AuthRepository(
              firebaseAuth: firebaseAuth!,
              firestore: firestore!,
              prefs: sharedPreferences,
              googleSignIn: googleSignIn,
              facebookAuth: facebookAuth,
            )
            : MockAuthRepository(prefs: sharedPreferences);

    final weightRepository =
        isFirebaseInitialized
            ? WeightRepository(firestore: firestore!)
            : MockWeightRepository();

    final foodRepository =
        isFirebaseInitialized
            ? FoodRepository(firestore: firestore!, dio: dio)
            : MockFoodRepository(dio: dio);

    // Initialize AI service
    final aiService = ai_service.AIService(
      openRouterApiKey: AppConstants.openRouterApiKey,
    );

    // Create a multi-provider app
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepositoryInterface>(
          create: (context) => authRepository,
        ),
        RepositoryProvider<WeightRepositoryInterface>(
          create: (context) => weightRepository,
        ),
        RepositoryProvider<FoodRepositoryInterface>(
          create: (context) => foodRepository,
        ),
        RepositoryProvider<ai_service.AIService>(
          create: (context) => aiService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository),
          ),
          BlocProvider<UserBloc>(
            create:
                (context) => UserBloc(
                  authRepository: authRepository,
                  sharedPreferences: sharedPreferences,
                ),
          ),
          BlocProvider<WeightBloc>(
            create: (context) => WeightBloc(weightRepository: weightRepository),
          ),
          BlocProvider<FoodBloc>(
            create: (context) => FoodBloc(foodRepository: foodRepository),
          ),
          BlocProvider<AiBloc>(
            create: (context) => AiBloc(aiService: aiService),
          ),
        ],
        child:
            isIOS
                ? CupertinoApp(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  theme: CupertinoThemeData(
                    brightness: Brightness.light,
                    primaryColor: CupertinoColors.systemBlue,
                  ),
                  home: const SplashScreen(),
                )
                : MaterialApp(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: ThemeMode.system,
                  home: const SplashScreen(),
                ),
      ),
    );
  }
}
