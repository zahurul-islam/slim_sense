import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';

class CalorieBreakdownChart extends StatelessWidget {
  final double proteinCalories;
  final double carbsCalories;
  final double fatCalories;
  final double? calorieGoal;
  final double size;

  const CalorieBreakdownChart({
    Key? key,
    required this.proteinCalories,
    required this.carbsCalories,
    required this.fatCalories,
    this.calorieGoal,
    this.size = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalCalories = proteinCalories + carbsCalories + fatCalories;
    
    // Calculate percentages
    final proteinPercentage = totalCalories > 0 ? proteinCalories / totalCalories : 0;
    final carbsPercentage = totalCalories > 0 ? carbsCalories / totalCalories : 0;
    final fatPercentage = totalCalories > 0 ? fatCalories / totalCalories : 0;
    
    // Calculate progress towards goal
    final goalProgress = calorieGoal != null && calorieGoal! > 0 
        ? (totalCalories / calorieGoal!).clamp(0.0, 1.0) 
        : null;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Pie chart
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: size / 4,
              sections: [
                PieChartSectionData(
                  value: proteinCalories,
                  title: '${(proteinPercentage * 100).toStringAsFixed(0)}%',
                  color: AppColors.chartBlue,
                  radius: size / 3,
                  titleStyle: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: carbsCalories,
                  title: '${(carbsPercentage * 100).toStringAsFixed(0)}%',
                  color: AppColors.chartGreen,
                  radius: size / 3,
                  titleStyle: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: fatCalories,
                  title: '${(fatPercentage * 100).toStringAsFixed(0)}%',
                  color: AppColors.chartYellow,
                  radius: size / 3,
                  titleStyle: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            swapAnimationDuration: const Duration(milliseconds: 500),
          ),
          
          // Center text
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  totalCalories.toStringAsFixed(0),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'calories',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (goalProgress != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${(goalProgress * 100).toStringAsFixed(0)}% of goal',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
