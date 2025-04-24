import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/openrouter_service.dart';
import '../../../data/models/chat_message_model.dart';
import 'health_coach_event.dart';
import 'health_coach_state.dart';

class HealthCoachBloc extends Bloc<HealthCoachEvent, HealthCoachState> {
  final OpenRouterService _openRouterService;
  final _uuid = const Uuid();
  
  HealthCoachBloc({required OpenRouterService openRouterService}) 
      : _openRouterService = openRouterService,
        super(HealthCoachInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<ClearChatHistory>(_onClearChatHistory);
    on<AddMessage>(_onAddMessage);
  }
  
  FutureOr<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<HealthCoachState> emit,
  ) async {
    emit(HealthCoachLoading());
    
    try {
      // In a real app, you would load messages from a database or storage
      // For now, we'll just initialize with a welcome message
      final welcomeMessage = ChatMessageModel(
        id: _uuid.v4(),
        content: "Hello! I'm your AI Health Coach. How can I help you with your health and fitness goals today?",
        role: 'assistant',
        timestamp: DateTime.now(),
      );
      
      emit(HealthCoachLoaded(messages: [welcomeMessage]));
    } catch (e) {
      emit(HealthCoachError('Failed to load chat history: $e'));
    }
  }
  
  FutureOr<void> _onSendMessage(
    SendMessage event,
    Emitter<HealthCoachState> emit,
  ) async {
    if (state is HealthCoachLoaded) {
      final currentState = state as HealthCoachLoaded;
      
      // Add user message to the chat
      final userMessage = ChatMessageModel(
        id: _uuid.v4(),
        content: event.message,
        role: 'user',
        timestamp: DateTime.now(),
      );
      
      // Update state to show user message and typing indicator
      emit(currentState.copyWith(
        messages: List.from(currentState.messages)..add(userMessage),
        isTyping: true,
      ));
      
      try {
        // Convert messages to the format expected by the API
        final history = currentState.messages
            .map((msg) => msg.toApiFormat())
            .toList();
        
        // Get response from AI
        final response = await _openRouterService.getHealthCoachResponse(
          event.message,
          history: history,
        );
        
        // Create assistant message
        final assistantMessage = ChatMessageModel(
          id: _uuid.v4(),
          content: response,
          role: 'assistant',
          timestamp: DateTime.now(),
        );
        
        // Update state with assistant response
        emit(currentState.copyWith(
          messages: List.from(currentState.messages)..add(assistantMessage),
          isTyping: false,
        ));
      } catch (e) {
        // If there's an error, add an error message from the assistant
        final errorMessage = ChatMessageModel(
          id: _uuid.v4(),
          content: "I'm sorry, I encountered an error. Please try again later.",
          role: 'assistant',
          timestamp: DateTime.now(),
        );
        
        emit(currentState.copyWith(
          messages: List.from(currentState.messages)..add(errorMessage),
          isTyping: false,
        ));
      }
    }
  }
  
  FutureOr<void> _onClearChatHistory(
    ClearChatHistory event,
    Emitter<HealthCoachState> emit,
  ) async {
    emit(HealthCoachLoading());
    
    try {
      // In a real app, you would clear messages from a database or storage
      final welcomeMessage = ChatMessageModel(
        id: _uuid.v4(),
        content: "Hello! I'm your AI Health Coach. How can I help you with your health and fitness goals today?",
        role: 'assistant',
        timestamp: DateTime.now(),
      );
      
      emit(HealthCoachLoaded(messages: [welcomeMessage]));
    } catch (e) {
      emit(HealthCoachError('Failed to clear chat history: $e'));
    }
  }
  
  FutureOr<void> _onAddMessage(
    AddMessage event,
    Emitter<HealthCoachState> emit,
  ) async {
    if (state is HealthCoachLoaded) {
      final currentState = state as HealthCoachLoaded;
      emit(currentState.copyWith(
        messages: List.from(currentState.messages)..add(event.message),
      ));
    }
  }
}
