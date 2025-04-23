import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;

  const UserLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}

class UserUpdateSuccess extends UserState {
  final UserModel user;
  final String message;

  const UserUpdateSuccess({
    required this.user,
    required this.message,
  });

  @override
  List<Object> get props => [user, message];
}
