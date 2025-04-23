import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/ai/ai_bloc.dart';
import '../../bloc/food/food_bloc.dart';
import '../../bloc/food/food_state.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/information_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/markdown_viewer.dart';
import '../../../data/models/user_model.dart';

class DietAnalysisScreen extends StatefulWidget {
  final UserModel user;

  const DietAnalysisScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<DietAnalysisScreen> createState() => _DietAnalysisScreenState();
}

class _DietAnalysisScreenState extends State<DietAnalysisScreen> {
  int _selectedDays = 7;
  final List<int> _dayOptions = [3, 7, 14, 30];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiBloc, AiState>(
      builder: (context, aiState) {
        return BlocBuilder<FoodBloc, FoodState>(
          builder: (context, foodState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDietOverview(foodState),
                  const SizedBox(height: 24),
                  _buildAnalysisOptions(),
                  const SizedBox(height: 24),
                  _buildGenerateButton(foodState),
                  const SizedBox(height: 32),
                  _buildAnalysisSection(aiState, foodState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDietOverview(FoodState foodState) {
    int totalLogs = 0;
    int daysWithLogs = 0;
    double avgCaloriesPerDay = 0;

    if (foodState is DailyNutritionSummaryLoaded) {
      totalLogs = foodState.summary['totalLogs'] ?? 0;
      daysWithLogs = foodState.summary['daysWithLogs'] ?? 0;
      avgCaloriesPerDay = foodState.summary['avgCaloriesPerDay'] ?? 0;
    }

    return InformationCard(
      title: 'Food Log Overview',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                'Total Logs',
                totalLogs.toString(),
                Icons.list_alt,
              ),
              _buildStatColumn(
                'Days Tracked',
                daysWithLogs.toString(),
                Icons.calendar_today,
              ),
              _buildStatColumn(
                'Avg. Calories',
                '${avgCaloriesPerDay.toStringAsFixed(0)} cal',
                Icons.local_fire_department,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'For accurate analysis, we recommend logging your food for at least 3 days. The more days you log, the more accurate the analysis will be.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Analysis Period', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Select how many days of food logs to analyze',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          children:
              _dayOptions.map((days) {
                return ChoiceChip(
                  label: Text('$days days'),
                  selected: _selectedDays == days,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDays = days;
                      });
                    }
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color:
                        _selectedDays == days
                            ? AppColors.primary
                            : AppColors.textSecondary,
                    fontWeight:
                        _selectedDays == days
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(FoodState foodState) {
    // Determine if we have enough logs for analysis
    bool hasEnoughLogs = false;
    if (foodState is DailyNutritionSummaryLoaded) {
      hasEnoughLogs = (foodState.summary['daysWithLogs'] ?? 0) >= 3;
    }

    return CustomButton(
      label: 'Analyze My Diet',
      onPressed:
          hasEnoughLogs
              ? () {
                // Generate dietary analysis
                context.read<AiBloc>().add(
                  AnalyzeDietaryHabits(days: _selectedDays),
                );
              }
              : null,
      icon: Icons.analytics,
      disabled: !hasEnoughLogs,
      tooltip:
          !hasEnoughLogs
              ? 'Log your food for at least 3 days to enable analysis'
              : null,
    );
  }

  Widget _buildAnalysisSection(AiState aiState, FoodState foodState) {
    // Determine if we have enough logs for analysis
    bool hasEnoughLogs = false;
    if (foodState is DailyNutritionSummaryLoaded) {
      hasEnoughLogs = (foodState.summary['daysWithLogs'] ?? 0) >= 3;
    }

    if (!hasEnoughLogs) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.no_food, color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Not enough food logs for analysis',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please log your meals for at least 3 days to enable AI diet analysis.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Go to Food Log',
              onPressed: () {
                // Navigate to food log tab
                Navigator.of(context).pop();
                // TODO: Navigate to food tab
              },
              icon: Icons.restaurant_menu,
              color: AppColors.secondary,
            ),
          ],
        ),
      );
    }

    if (aiState is AiLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Analyzing your dietary habits...'),
      );
    } else if (aiState is DietaryAnalysisLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Diet Analysis', style: AppTypography.heading5),
          const SizedBox(height: 16),
          MarkdownViewer(markdown: aiState.analysis),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Save Analysis',
            onPressed: () {
              // TODO: Save the analysis
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analysis saved successfully')),
              );
            },
            icon: Icons.save,
            color: AppColors.success,
          ),
        ],
      );
    } else if (aiState is AiError) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text('Error analyzing your diet', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Text(
              aiState.message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Try Again',
              onPressed: () {
                // Reset the state
                context.read<AiBloc>().add(ResetAiState());
              },
              icon: Icons.refresh,
              color: AppColors.secondary,
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          children: [
            Icon(Icons.analytics, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Ready to analyze your diet!',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Select your analysis period above and click "Analyze My Diet" to get insights on your eating habits.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
