import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/ai/ai_bloc.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_state.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_typography.dart';
import '../../../widgets/custom_tab_bar.dart';
import '../../ai/weight_loss_plan_screen.dart';
import '../../ai/meal_recommendation_screen.dart';
import '../../ai/workout_recommendation_screen.dart';
import '../../ai/diet_analysis_screen.dart';
import '../../ai/weight_forecast_screen.dart';
import '../../ai/progress_insights_screen.dart';
import '../../health_coach/health_coach_screen.dart';

class AiCoachTab extends StatefulWidget {
  const AiCoachTab({super.key});

  @override
  State<AiCoachTab> createState() => _AiCoachTabState();
}

class _AiCoachTabState extends State<AiCoachTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabTitles = [
    'Weight Loss',
    'Meals',
    'Workouts',
    'Analysis',
    'Forecast',
    'Insights',
    'Health Coach',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        if (userState is UserLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (userState is UserError) {
          return Center(child: Text('Error: ${userState.message}'));
        }

        if (userState is UserLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'AI Coach',
                style: AppTypography.heading4.copyWith(
                  color: AppColors.textPrimaryColor,
                ),
              ),
              bottom: CustomTabBar(
                controller: _tabController,
                tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () => _showAiCoachHelp(context),
                ),
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                WeightLossPlanScreen(user: userState.user),
                MealRecommendationScreen(user: userState.user),
                WorkoutRecommendationScreen(user: userState.user),
                DietAnalysisScreen(user: userState.user),
                WeightForecastScreen(user: userState.user),
                ProgressInsightsScreen(user: userState.user),
                const HealthCoachScreen(),
              ],
            ),
          );
        }

        // Default fallback
        return const Center(child: Text('Loading AI Coach...'));
      },
    );
  }

  void _showAiCoachHelp(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('AI Coach Features'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHelpSection(
                    'Weight Loss Plan',
                    'Get a personalized weight loss plan including calorie targets, macronutrients, meal ideas, and exercise recommendations.',
                    Icons.trending_down,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    'Meal Recommendations',
                    'Receive custom meal suggestions based on your calorie goals, dietary preferences, and available ingredients.',
                    Icons.restaurant_menu,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    'Workout Plans',
                    'Get personalized workout routines tailored to your fitness level, goals, and available equipment.',
                    Icons.fitness_center,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    'Diet Analysis',
                    'AI analysis of your eating habits from your food logs, identifying strengths and areas for improvement.',
                    Icons.analytics,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    'Weight Forecast',
                    'Projection of your future weight progress based on current trends and recommendations for staying on track.',
                    Icons.trending_up,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    'Progress Insights',
                    'AI-powered analysis of your health data with visualizations and personalized insights to help you understand your progress.',
                    Icons.insights,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    'Health Coach',
                    'Chat with an AI health coach powered by Microsoft MAI-DS-R1 model for personalized advice on nutrition, fitness, and wellness.',
                    Icons.health_and_safety,
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

  Widget _buildHelpSection(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(description, style: AppTypography.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
