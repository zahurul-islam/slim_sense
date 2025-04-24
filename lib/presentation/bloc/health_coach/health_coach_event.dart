import 'package:equatable/equatable.dart';
import '../../../data/models/chat_message_model.dart';

abstract class HealthCoachEvent extends Equatable {
  const HealthCoachEvent();

  @override
  List<Object> get props => [];
}

class SendMessage extends HealthCoachEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object> get props => [message];
}

class LoadChatHistory extends HealthCoachEvent {}

class ClearChatHistory extends HealthCoachEvent {}

class AddMessage extends HealthCoachEvent {
  final ChatMessageModel message;

  const AddMessage(this.message);

  @override
  List<Object> get props => [message];
}
