import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/weight_log_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import 'package:intl/intl.dart';

class WeightTrendChart extends StatelessWidget {
  final List<WeightLogModel> weightLogs;
  final double? targetWeight;
  final bool showTarget;
  final bool showLabels;
  final bool showGrid;
  final double height;
  final bool showGradient;
  final bool animate;

  const WeightTrendChart({
    Key? key,
    required this.weightLogs,
    this.targetWeight,
    this.showTarget = true,
    this.showLabels = true,
    this.showGrid = true,
    this.height = 250,
    this.showGradient = true,
    this.animate = true,
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

    // Create spots for the chart
    final spots =
        sortedLogs.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.weightInKg);
        }).toList();

    // Calculate min and max values for the chart
    final minWeight = sortedLogs
        .map((log) => log.weightInKg)
        .reduce((a, b) => a < b ? a : b);
    final maxWeight = sortedLogs
        .map((log) => log.weightInKg)
        .reduce((a, b) => a > b ? a : b);

    // Add target weight to min/max calculation if available
    double minY = minWeight - 1;
    double maxY = maxWeight + 1;

    if (targetWeight != null && showTarget) {
      minY = minY < targetWeight! ? minY : targetWeight! - 1;
      maxY = maxY > targetWeight! ? maxY : targetWeight! + 1;
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: showGrid,
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
            show: showLabels,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showLabels,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < sortedLogs.length) {
                    // Show date for first, middle and last points
                    if (value.toInt() == 0 ||
                        value.toInt() == sortedLogs.length - 1 ||
                        value.toInt() == (sortedLogs.length / 2).floor()) {
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
                showTitles: showLabels,
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
          maxX: (sortedLogs.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= 0 && index < sortedLogs.length) {
                    final log = sortedLogs[index];
                    return LineTooltipItem(
                      '${log.weightInKg.toStringAsFixed(1)} kg\n${DateFormat('MMM d, y').format(log.loggedAt)}',
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
            // Weight log line
            LineChartBarData(
              spots: spots,
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
              belowBarData: BarAreaData(
                show: showGradient,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryColor.withAlpha(76), // 0.3 opacity
                    AppColors.primaryColor.withAlpha(0), // 0.0 opacity
                  ],
                ),
              ),
            ),
            // Target weight line (if available)
            if (targetWeight != null && showTarget)
              LineChartBarData(
                spots: [
                  FlSpot(0, targetWeight!),
                  FlSpot((sortedLogs.length - 1).toDouble(), targetWeight!),
                ],
                isCurved: false,
                color: AppColors.secondaryColor,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                dashArray: [5, 5],
              ),
          ],
        ),
      ),
    );
  }
}
