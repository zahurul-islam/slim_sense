import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/weight/weight_bloc.dart';
import '../../bloc/weight/weight_state.dart';
import '../../bloc/food/food_bloc.dart';
import '../../bloc/food/food_state.dart';
import '../../bloc/ai/ai_bloc.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/charts/weight_trend_chart.dart';
import '../../widgets/charts/goal_progress_chart.dart';
import '../../widgets/charts/progress_chart.dart';
import '../../widgets/charts/nutrition_radar_chart.dart';
import '../../widgets/insights/insight_card.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/weight_log_model.dart';
import '../../../data/models/food_log_model.dart';
import '../../../data/services/insights_service.dart';
import 'package:intl/intl.dart';

class ProgressInsightsScreen extends StatefulWidget {
  final UserModel user;

  const ProgressInsightsScreen({Key? key, required this.user})
    : super(key: key);

  @override
  State<ProgressInsightsScreen> createState() => _ProgressInsightsScreenState();
}

class _ProgressInsightsScreenState extends State<ProgressInsightsScreen> {
  final InsightsService _insightsService = InsightsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress Insights',
                style: AppTypography.heading4.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI-powered analysis of your health journey',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildProgressOverview(),
              const SizedBox(height: 24),
              _buildWeightInsights(),
              const SizedBox(height: 24),
              _buildNutritionInsights(),
              const SizedBox(height: 24),
              _buildAIRecommendations(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverview() {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, weightState) {
        return BlocBuilder<FoodBloc, FoodState>(
          builder: (context, foodState) {
            if (weightState is WeightLogsLoaded &&
                foodState is FoodLogsLoaded) {
              // Group food logs by date
              final Map<String, List<FoodLogModel>> foodLogsByDate = {};
              for (var log in foodState.foodLogs) {
                final dateKey = DateFormat('yyyy-MM-dd').format(log.loggedAt);
                if (!foodLogsByDate.containsKey(dateKey)) {
                  foodLogsByDate[dateKey] = [];
                }
                foodLogsByDate[dateKey]!.add(log);
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress Overview',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 250,
                        child: ProgressChart(
                          weightLogs: weightState.weightLogs,
                          foodLogsByDate: foodLogsByDate,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildLegendItem('Weight', AppColors.primaryColor),
                          const SizedBox(width: 24),
                          _buildLegendItem('Calories', AppColors.chartGreen),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: LoadingIndicator(message: 'Loading progress data...'),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildWeightInsights() {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, state) {
        if (state is WeightLogsLoaded) {
          final weightInsights = _insightsService.getWeightTrendInsights(
            state.weightLogs,
            widget.user,
          );

          if (!weightInsights['hasData']) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight Insights',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        weightInsights['message'],
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weight Insights',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weight Trend',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: WeightTrendChart(
                          weightLogs: weightInsights['weightLogs'],
                          targetWeight: widget.user.targetWeight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        weightInsights['insightMessage'],
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.user.targetWeight != null) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goal Progress',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: GoalProgressChart(
                            weightLogs: weightInsights['weightLogs'],
                            startWeight: weightInsights['firstWeight'],
                            currentWeight: weightInsights['currentWeight'],
                            targetWeight: widget.user.targetWeight!,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          weightInsights['progressMessage'],
                          style: AppTypography.bodyMedium,
                        ),
                        if (weightInsights['estimatedCompletion']
                            .isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            weightInsights['estimatedCompletion'],
                            style: AppTypography.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        } else {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: LoadingIndicator(message: 'Analyzing weight data...'),
            ),
          );
        }
      },
    );
  }

  Widget _buildNutritionInsights() {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is FoodLogsLoaded) {
          final nutritionInsights = _insightsService.getNutritionInsights(
            state.foodLogs,
            widget.user,
          );

          if (!nutritionInsights['hasData']) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition Insights',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        nutritionInsights['message'],
                        style: AppTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutrition Insights',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Macronutrient Balance',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: NutritionRadarChart(
                          proteinPercentage:
                              nutritionInsights['proteinPercentage'],
                          carbsPercentage: nutritionInsights['carbsPercentage'],
                          fatPercentage: nutritionInsights['fatPercentage'],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        nutritionInsights['macroInsight'],
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calorie Intake',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Average daily calories: ${nutritionInsights['avgCalories'].toStringAsFixed(0)}',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on ${nutritionInsights['daysTracked']} days of tracking',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        nutritionInsights['calorieInsight'],
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: LoadingIndicator(message: 'Analyzing nutrition data...'),
            ),
          );
        }
      },
    );
  }

  Widget _buildAIRecommendations() {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, weightState) {
        return BlocBuilder<FoodBloc, FoodState>(
          builder: (context, foodState) {
            if (weightState is WeightLogsLoaded &&
                foodState is FoodLogsLoaded) {
              final weightInsights = _insightsService.getWeightTrendInsights(
                weightState.weightLogs,
                widget.user,
              );

              final nutritionInsights = _insightsService.getNutritionInsights(
                foodState.foodLogs,
                widget.user,
              );

              final aiInsights = _insightsService.getAIHealthInsights(
                weightInsights,
                nutritionInsights,
                widget.user,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Recommendations',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...aiInsights.map(
                    (insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InsightCard(
                        title: insight['title'],
                        description: insight['description'],
                        icon: insight['icon'],
                        color: insight['color'],
                        progress: insight['progress'],
                        data: insight['data'],
                        actionText: insight['actionText'],
                        onAction:
                            insight['actionText'] != null
                                ? () {
                                  // Handle action
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Action: ${insight['actionText']}',
                                      ),
                                    ),
                                  );
                                }
                                : null,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: LoadingIndicator(
                    message: 'Generating AI recommendations...',
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }
}
