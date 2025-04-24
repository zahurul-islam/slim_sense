import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/services/openrouter_service.dart';
import '../../../data/models/chat_message_model.dart';
import '../../bloc/health_coach/health_coach_bloc.dart';
import '../../bloc/health_coach/health_coach_event.dart';
import '../../bloc/health_coach/health_coach_state.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/loading_indicator.dart';

class HealthCoachScreen extends StatefulWidget {
  const HealthCoachScreen({super.key});

  @override
  State<HealthCoachScreen> createState() => _HealthCoachScreenState();
}

class _HealthCoachScreenState extends State<HealthCoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late HealthCoachBloc _healthCoachBloc;

  @override
  void initState() {
    super.initState();
    _healthCoachBloc = HealthCoachBloc(
      openRouterService: OpenRouterService(),
    );
    _healthCoachBloc.add(LoadChatHistory());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      _healthCoachBloc.add(SendMessage(message));
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _healthCoachBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'AI Health Coach',
            style: AppTypography.heading4.copyWith(
              color: AppColors.textPrimaryColor,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _healthCoachBloc.add(ClearChatHistory());
              },
              tooltip: 'Start New Conversation',
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(context),
              tooltip: 'About AI Health Coach',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<HealthCoachBloc, HealthCoachState>(
                listener: (context, state) {
                  if (state is HealthCoachLoaded) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  if (state is HealthCoachInitial || state is HealthCoachLoading && (state as HealthCoachLoading).props.isEmpty) {
                    return const Center(
                      child: LoadingIndicator(
                        message: 'Loading your health coach...',
                      ),
                    );
                  } else if (state is HealthCoachLoaded) {
                    return _buildChatList(state);
                  } else if (state is HealthCoachError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error',
                            style: AppTypography.titleLarge.copyWith(
                              color: AppColors.errorColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: AppTypography.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _healthCoachBloc.add(LoadChatHistory());
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(HealthCoachLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.messages.length + (state.isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.messages.length) {
          return _buildMessageItem(state.messages[index]);
        } else {
          // Show typing indicator
          return _buildTypingIndicator();
        }
      },
    );
  }

  Widget _buildMessageItem(ChatMessageModel message) {
    final isUser = message.role == 'user';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primaryColor : AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.content,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isUser ? Colors.white : AppColors.textPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildAvatar(isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser ? AppColors.primaryColor.withOpacity(0.2) : AppColors.secondaryColor.withOpacity(0.2),
      child: Icon(
        isUser ? Icons.person : Icons.health_and_safety,
        size: 20,
        color: isUser ? AppColors.primaryColor : AppColors.secondaryColor,
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(1),
                _buildDot(2),
                _buildDot(3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask your health coach...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<HealthCoachBloc, HealthCoachState>(
            builder: (context, state) {
              final isLoading = state is HealthCoachLoaded && state.isTyping;
              
              return FloatingActionButton(
                onPressed: isLoading ? null : _sendMessage,
                backgroundColor: AppColors.primaryColor,
                elevation: 0,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About AI Health Coach'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your AI Health Coach is powered by Microsoft\'s MAI-DS-R1 model and can help you with:',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildFeatureItem(
                icon: Icons.fitness_center,
                title: 'Fitness Advice',
                description: 'Get personalized workout recommendations based on your goals.',
              ),
              _buildFeatureItem(
                icon: Icons.restaurant_menu,
                title: 'Nutrition Guidance',
                description: 'Learn about balanced eating and meal planning for your health goals.',
              ),
              _buildFeatureItem(
                icon: Icons.self_improvement,
                title: 'Wellness Tips',
                description: 'Discover strategies for better sleep, stress management, and overall wellbeing.',
              ),
              _buildFeatureItem(
                icon: Icons.track_changes,
                title: 'Progress Tracking',
                description: 'Get insights on how to effectively monitor your health journey.',
              ),
              const SizedBox(height: 16),
              Text(
                'Note: While our AI coach provides evidence-based information, it should not replace professional medical advice.',
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
