import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserStarted extends UserEvent {}

class UserProfileUpdated extends UserEvent {
  final UserModel user;

  const UserProfileUpdated(this.user);

  @override
  List<Object> get props => [user];
}

class UserPhotoUpdated extends UserEvent {
  final String photoUrl;

  const UserPhotoUpdated(this.photoUrl);

  @override
  List<Object> get props => [photoUrl];
}

class UserPreferencesUpdated extends UserEvent {
  final List<String>? dietaryPreferences;
  final List<String>? allergies;

  const UserPreferencesUpdated({
    this.dietaryPreferences,
    this.allergies,
  });

  @override
  List<Object?> get props => [dietaryPreferences, allergies];
}

class UserGoalsUpdated extends UserEvent {
  final double? targetWeight;
  final int? dailyCalorieGoal;
  final Map<String, double>? macroTargets;

  const UserGoalsUpdated({
    this.targetWeight,
    this.dailyCalorieGoal,
    this.macroTargets,
  });

  @override
  List<Object?> get props => [targetWeight, dailyCalorieGoal, macroTargets];
}

class UserPremiumStatusUpdated extends UserEvent {
  final bool isPremium;
  final String? stripeCustomerId;

  const UserPremiumStatusUpdated({
    required this.isPremium,
    this.stripeCustomerId,
  });

  @override
  List<Object?> get props => [isPremium, stripeCustomerId];
}
