import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/repositories/auth_repository_interface.dart';
import '../../../data/models/user_model.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthRepositoryInterface authRepository;
  final SharedPreferences sharedPreferences;

  UserBloc({required this.authRepository, required this.sharedPreferences})
    : super(UserInitial()) {
    on<UserStarted>(_onUserStarted);
    on<UserProfileUpdated>(_onUserProfileUpdated);
    on<UserPhotoUpdated>(_onUserPhotoUpdated);
    on<UserPreferencesUpdated>(_onUserPreferencesUpdated);
    on<UserGoalsUpdated>(_onUserGoalsUpdated);
    on<UserPremiumStatusUpdated>(_onUserPremiumStatusUpdated);
  }

  Future<void> _onUserStarted(
    UserStarted event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final firebaseUser = authRepository.getCurrentUser();
      if (firebaseUser == null) {
        emit(const UserError('User not authenticated'));
        return;
      }

      final user = await authRepository.getCurrentUserData(firebaseUser.uid);
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(const UserError('User data not found'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserProfileUpdated(
    UserProfileUpdated event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      await authRepository.updateUserProfile(event.user);
      emit(
        UserUpdateSuccess(
          user: event.user,
          message: 'Profile updated successfully',
        ),
      );
      emit(UserLoaded(event.user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserPhotoUpdated(
    UserPhotoUpdated event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (state is UserLoaded) {
        final currentUser = (state as UserLoaded).user;
        emit(UserLoading());

        await authRepository.updateUserPhoto(event.photoUrl);

        final updatedUser = currentUser.copyWith(photoUrl: event.photoUrl);
        await authRepository.updateUserProfile(updatedUser);

        emit(
          UserUpdateSuccess(
            user: updatedUser,
            message: 'Profile photo updated successfully',
          ),
        );
        emit(UserLoaded(updatedUser));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserPreferencesUpdated(
    UserPreferencesUpdated event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (state is UserLoaded) {
        final currentUser = (state as UserLoaded).user;
        emit(UserLoading());

        final updatedUser = currentUser.copyWith(
          dietaryPreferences:
              event.dietaryPreferences ?? currentUser.dietaryPreferences,
          allergies: event.allergies ?? currentUser.allergies,
        );

        await authRepository.updateUserProfile(updatedUser);

        emit(
          UserUpdateSuccess(
            user: updatedUser,
            message: 'Preferences updated successfully',
          ),
        );
        emit(UserLoaded(updatedUser));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserGoalsUpdated(
    UserGoalsUpdated event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (state is UserLoaded) {
        final currentUser = (state as UserLoaded).user;
        emit(UserLoading());

        final updatedUser = currentUser.copyWith(
          targetWeight: event.targetWeight ?? currentUser.targetWeight,
          dailyCalorieGoal:
              event.dailyCalorieGoal ?? currentUser.dailyCalorieGoal,
          macroTargets: event.macroTargets ?? currentUser.macroTargets,
        );

        await authRepository.updateUserProfile(updatedUser);

        emit(
          UserUpdateSuccess(
            user: updatedUser,
            message: 'Goals updated successfully',
          ),
        );
        emit(UserLoaded(updatedUser));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUserPremiumStatusUpdated(
    UserPremiumStatusUpdated event,
    Emitter<UserState> emit,
  ) async {
    try {
      if (state is UserLoaded) {
        final currentUser = (state as UserLoaded).user;
        emit(UserLoading());

        final updatedUser = currentUser.copyWith(
          isPremium: event.isPremium,
          stripeCustomerId: event.stripeCustomerId,
        );

        await authRepository.updateUserProfile(updatedUser);

        emit(
          UserUpdateSuccess(
            user: updatedUser,
            message: 'Premium status updated successfully',
          ),
        );
        emit(UserLoaded(updatedUser));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
