import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/weight_log_model.dart';
import '../../../data/models/food_log_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import 'package:intl/intl.dart';

class ProgressChart extends StatelessWidget {
  final List<WeightLogModel> weightLogs;
  final Map<String, List<FoodLogModel>> foodLogsByDate;
  final double height;
  final int daysToShow;

  const ProgressChart({
    Key? key,
    required this.weightLogs,
    required this.foodLogsByDate,
    this.height = 250,
    this.daysToShow = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (weightLogs.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No progress data available',
            style: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    // Sort logs by date
    final sortedLogs = List<WeightLogModel>.from(weightLogs)
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

    // Get the last N days of data
    final recentLogs =
        sortedLogs.length > daysToShow
            ? sortedLogs.sublist(sortedLogs.length - daysToShow)
            : sortedLogs;

    // Create weight spots for the chart
    final weightSpots =
        recentLogs.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.weightInKg);
        }).toList();

    // Calculate min and max values for weight
    final minWeight = recentLogs
        .map((log) => log.weightInKg)
        .reduce((a, b) => a < b ? a : b);
    final maxWeight = recentLogs
        .map((log) => log.weightInKg)
        .reduce((a, b) => a > b ? a : b);

    // Add some padding to the min and max values
    final minY = minWeight - 1;
    final maxY = maxWeight + 1;

    // Create calorie spots for the chart
    final calorieSpots = <FlSpot>[];

    // Calculate max calories for scaling
    double maxCalories = 0;

    for (int i = 0; i < recentLogs.length; i++) {
      final date = DateFormat('yyyy-MM-dd').format(recentLogs[i].loggedAt);
      if (foodLogsByDate.containsKey(date)) {
        final logs = foodLogsByDate[date]!;
        double totalCalories = 0;
        for (var log in logs) {
          totalCalories += log.calories;
        }

        if (totalCalories > maxCalories) {
          maxCalories = totalCalories;
        }

        // Scale calories to fit on the same chart as weight
        final scaledCalories = _scaleCaloriesToWeight(
          totalCalories,
          maxCalories,
          minY,
          maxY,
        );

        calorieSpots.add(FlSpot(i.toDouble(), scaledCalories));
      } else {
        // No food logs for this date
        calorieSpots.add(FlSpot(i.toDouble(), 0));
      }
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.borderColor,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < recentLogs.length) {
                    // Show date for first, middle and last points
                    if (value.toInt() == 0 ||
                        value.toInt() == recentLogs.length - 1 ||
                        value.toInt() == (recentLogs.length / 2).floor()) {
                      final date = recentLogs[value.toInt()].loggedAt;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('MMM d').format(date),
                          style: AppTypography.labelSmall,
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value.toStringAsFixed(0),
                      style: AppTypography.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (recentLogs.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= 0 && index < recentLogs.length) {
                    final log = recentLogs[index];
                    final date = DateFormat('yyyy-MM-dd').format(log.loggedAt);

                    if (spot.barIndex == 0) {
                      // Weight spot
                      return LineTooltipItem(
                        'Weight: ${log.weightInKg.toStringAsFixed(1)} kg\n${DateFormat('MMM d').format(log.loggedAt)}',
                        AppTypography.labelMedium.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      // Calorie spot
                      if (foodLogsByDate.containsKey(date)) {
                        final logs = foodLogsByDate[date]!;
                        double totalCalories = 0;
                        for (var log in logs) {
                          totalCalories += log.calories;
                        }

                        return LineTooltipItem(
                          'Calories: ${totalCalories.toStringAsFixed(0)}\n${DateFormat('MMM d').format(log.loggedAt)}',
                          AppTypography.labelMedium.copyWith(
                            color: AppColors.chartGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                    }
                  }
                  return null;
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            // Weight line
            LineChartBarData(
              spots: weightSpots,
              isCurved: true,
              color: AppColors.primaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primaryColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
            // Calories line
            LineChartBarData(
              spots: calorieSpots,
              isCurved: true,
              color: AppColors.chartGreen,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.chartGreen,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to scale calories to fit on the same chart as weight
  double _scaleCaloriesToWeight(
    double calories,
    double maxCalories,
    double minWeight,
    double maxWeight,
  ) {
    if (maxCalories == 0) return minWeight;

    // Scale calories to the weight range
    final weightRange = maxWeight - minWeight;
    final scaledValue =
        minWeight + (calories / maxCalories) * weightRange * 0.8;

    return scaledValue;
  }
}
