import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/weight_log_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import 'package:intl/intl.dart';

class GoalProgressChart extends StatelessWidget {
  final List<WeightLogModel> weightLogs;
  final double startWeight;
  final double currentWeight;
  final double targetWeight;
  final double height;

  const GoalProgressChart({
    Key? key,
    required this.weightLogs,
    required this.startWeight,
    required this.currentWeight,
    required this.targetWeight,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (weightLogs.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No weight data available',
            style: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    // Sort logs by date
    final sortedLogs = List<WeightLogModel>.from(weightLogs)
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

    // Calculate total progress
    final totalChange = targetWeight - startWeight;
    final currentChange = currentWeight - startWeight;
    final progressPercentage =
        totalChange != 0
            ? (currentChange / totalChange).abs().clamp(0.0, 1.0)
            : 0.0;

    // Create spots for the chart
    final spots =
        sortedLogs.asMap().entries.map((entry) {
          final logChange = entry.value.weightInKg - startWeight;
          final logProgress =
              totalChange != 0
                  ? (logChange / totalChange).abs().clamp(0.0, 1.0)
                  : 0.0;
          return FlSpot(entry.key.toDouble(), logProgress);
        }).toList();

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.borderColor,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < sortedLogs.length) {
                          // Show date for first, middle and last points
                          if (value.toInt() == 0 ||
                              value.toInt() == sortedLogs.length - 1 ||
                              value.toInt() ==
                                  (sortedLogs.length / 2).floor()) {
                            final date = sortedLogs[value.toInt()].loggedAt;
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
                      interval: 0.2,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${(value * 100).toStringAsFixed(0)}%',
                            style: AppTypography.labelSmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (sortedLogs.length - 1).toDouble(),
                minY: 0,
                maxY: 1,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index >= 0 && index < sortedLogs.length) {
                          final log = sortedLogs[index];
                          final logChange = log.weightInKg - startWeight;
                          final logProgress =
                              totalChange != 0
                                  ? (logChange / totalChange).abs()
                                  : 0.0;
                          return LineTooltipItem(
                            '${(logProgress * 100).toStringAsFixed(1)}%\n${DateFormat('MMM d, y').format(log.loggedAt)}',
                            AppTypography.labelMedium.copyWith(
                              color: AppColors.textPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.secondaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.secondaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.secondaryColor.withAlpha(76), // 0.3 opacity
                          AppColors.secondaryColor.withAlpha(0), // 0.0 opacity
                        ],
                      ),
                    ),
                  ),
                  // Target line (100%)
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 1),
                      FlSpot((sortedLogs.length - 1).toDouble(), 1),
                    ],
                    isCurved: false,
                    color: AppColors.chartGreen.withAlpha(128), // 0.5 opacity
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeightItem('Start', startWeight, AppColors.textSecondary),
              _buildWeightItem(
                'Current',
                currentWeight,
                AppColors.secondaryColor,
              ),
              _buildWeightItem('Target', targetWeight, AppColors.chartGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightItem(String label, double weight, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${weight.toStringAsFixed(1)} kg',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
