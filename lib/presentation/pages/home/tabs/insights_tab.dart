import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/weight/weight_bloc.dart';
import '../../../bloc/weight/weight_state.dart';
import '../../../bloc/weight/weight_event.dart';
import '../../../bloc/food/food_bloc.dart';
import '../../../bloc/food/food_state.dart';
import '../../../bloc/food/food_event.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_state.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_typography.dart';
import '../../../widgets/loading_indicator.dart';
import '../../../widgets/insights/insight_card.dart';
import '../../../widgets/charts/weight_trend_chart.dart';
import '../../../widgets/charts/nutrition_radar_chart.dart';
import '../../../widgets/charts/calorie_breakdown_chart.dart';
import '../../../widgets/charts/progress_chart.dart';
import '../../../../data/services/insights_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/models/weight_log_model.dart';
import '../../../../data/models/food_log_model.dart';
import 'package:intl/intl.dart';

class InsightsTab extends StatefulWidget {
  const InsightsTab({Key? key}) : super(key: key);

  @override
  State<InsightsTab> createState() => _InsightsTabState();
}

class _InsightsTabState extends State<InsightsTab> {
  final InsightsService _insightsService = InsightsService();
  String _selectedTimeRange = '1M'; // Default to 1 month

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    // Load weight data
    context.read<WeightBloc>().add(
      LoadWeightLogs(
        userId:
            context.read<UserBloc>().state is UserLoaded
                ? (context.read<UserBloc>().state as UserLoaded).user.id
                : '',
        startDate: _getStartDate(),
        endDate: DateTime.now(),
      ),
    );

    // Load food data
    context.read<FoodBloc>().add(const LoadFoodLogs());
  }

  DateTime _getStartDate() {
    final now = DateTime.now();
    switch (_selectedTimeRange) {
      case '1W':
        return now.subtract(const Duration(days: 7));
      case '1M':
        return now.subtract(const Duration(days: 30));
      case '3M':
        return now.subtract(const Duration(days: 90));
      case '6M':
        return now.subtract(const Duration(days: 180));
      case '1Y':
        return now.subtract(const Duration(days: 365));
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, userState) {
        if (userState is UserLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Insights',
                style: AppTypography.heading4.copyWith(
                  color: AppColors.textPrimaryColor,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _refreshData,
                  tooltip: 'Refresh Data',
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                _refreshData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeRangeSelector(),
                    const SizedBox(height: 16),
                    _buildHealthSummary(userState.user),
                    const SizedBox(height: 24),
                    _buildWeightInsights(userState.user),
                    const SizedBox(height: 24),
                    _buildNutritionInsights(userState.user),
                    const SizedBox(height: 24),
                    _buildAIRecommendations(userState.user),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        }

        return const Center(
          child: LoadingIndicator(message: 'Loading insights...'),
        );
      },
    );
  }

  Widget _buildTimeRangeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTimeRangeButton('1W', '1 Week'),
          const SizedBox(width: 8),
          _buildTimeRangeButton('1M', '1 Month'),
          const SizedBox(width: 8),
          _buildTimeRangeButton('3M', '3 Months'),
          const SizedBox(width: 8),
          _buildTimeRangeButton('6M', '6 Months'),
          const SizedBox(width: 8),
          _buildTimeRangeButton('1Y', '1 Year'),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(String range, String label) {
    final isSelected = _selectedTimeRange == range;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedTimeRange = range;
        });
        _refreshData();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildHealthSummary(UserModel user) {
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

              // Get weight insights
              final weightInsights = _insightsService.getWeightTrendInsights(
                weightState.weightLogs,
                user,
              );

              // Get nutrition insights
              final nutritionInsights = _insightsService.getNutritionInsights(
                foodState.foodLogs,
                user,
              );

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
                        'Health Summary',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (weightState.weightLogs.isNotEmpty) ...[
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
                      ] else ...[
                        const Center(
                          child: Text(
                            'No data available for the selected time range',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            } else {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: LoadingIndicator(message: 'Loading health summary...'),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildWeightInsights(UserModel user) {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, state) {
        if (state is WeightLogsLoaded) {
          if (state.weightLogs.isEmpty) {
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
                    const Center(
                      child: Text(
                        'No weight data available for the selected time range',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final weightInsights = _insightsService.getWeightTrendInsights(
            state.weightLogs,
            user,
          );

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
                  SizedBox(
                    height: 200,
                    child: WeightTrendChart(
                      weightLogs: state.weightLogs,
                      targetWeight: user.targetWeight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    weightInsights['insightMessage'],
                    style: AppTypography.bodyMedium,
                  ),
                  if (weightInsights['progressMessage'].isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      weightInsights['progressMessage'],
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
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

  Widget _buildNutritionInsights(UserModel user) {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is FoodLogsLoaded) {
          if (state.foodLogs.isEmpty) {
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
                    const Center(
                      child: Text(
                        'No nutrition data available for the selected time range',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final nutritionInsights = _insightsService.getNutritionInsights(
            state.foodLogs,
            user,
          );

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
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Macronutrient Balance',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            NutritionRadarChart(
                              proteinPercentage:
                                  nutritionInsights['proteinPercentage'],
                              carbsPercentage:
                                  nutritionInsights['carbsPercentage'],
                              fatPercentage: nutritionInsights['fatPercentage'],
                              size: 150,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Calorie Breakdown',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CalorieBreakdownChart(
                              proteinCalories:
                                  nutritionInsights['avgProtein'] * 4,
                              carbsCalories: nutritionInsights['avgCarbs'] * 4,
                              fatCalories: nutritionInsights['avgFat'] * 9,
                              calorieGoal: user.dailyCalorieGoal?.toDouble(),
                              size: 150,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nutritionInsights['macroInsight'],
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nutritionInsights['calorieInsight'],
                    style: AppTypography.bodyMedium,
                  ),
                ],
              ),
            ),
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

  Widget _buildAIRecommendations(UserModel user) {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, weightState) {
        return BlocBuilder<FoodBloc, FoodState>(
          builder: (context, foodState) {
            if (weightState is WeightLogsLoaded &&
                foodState is FoodLogsLoaded) {
              final weightInsights = _insightsService.getWeightTrendInsights(
                weightState.weightLogs,
                user,
              );

              final nutritionInsights = _insightsService.getNutritionInsights(
                foodState.foodLogs,
                user,
              );

              final aiInsights = _insightsService.getAIHealthInsights(
                weightInsights,
                nutritionInsights,
                user,
              );

              if (aiInsights.isEmpty) {
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
                          'AI Recommendations',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            'Not enough data to generate AI recommendations',
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
                    'AI Recommendations',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...aiInsights
                      .map(
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
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
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
                      )
                      .toList(),
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
