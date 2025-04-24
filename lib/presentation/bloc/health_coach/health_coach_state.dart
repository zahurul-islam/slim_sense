import 'package:equatable/equatable.dart';
import '../../../data/models/chat_message_model.dart';

abstract class HealthCoachState extends Equatable {
  const HealthCoachState();
  
  @override
  List<Object> get props => [];
}

class HealthCoachInitial extends HealthCoachState {}

class HealthCoachLoading extends HealthCoachState {}

class HealthCoachLoaded extends HealthCoachState {
  final List<ChatMessageModel> messages;
  final bool isTyping;
  
  const HealthCoachLoaded({
    required this.messages,
    this.isTyping = false,
  });
  
  HealthCoachLoaded copyWith({
    List<ChatMessageModel>? messages,
    bool? isTyping,
  }) {
    return HealthCoachLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
  
  @override
  List<Object> get props => [messages, isTyping];
}

class HealthCoachError extends HealthCoachState {
  final String message;
  
  const HealthCoachError(this.message);
  
  @override
  List<Object> get props => [message];
}
