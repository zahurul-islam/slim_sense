import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';

class NutritionRadarChart extends StatelessWidget {
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatPercentage;
  final double fiberPercentage;
  final double sugarPercentage;
  final double sodiumPercentage;
  final double size;

  const NutritionRadarChart({
    Key? key,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
    this.fiberPercentage = 0,
    this.sugarPercentage = 0,
    this.sodiumPercentage = 0,
    this.size = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              tickCount: 5,
              ticksTextStyle: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              radarBorderData: const BorderSide(color: Colors.transparent),
              gridBorderData: BorderSide(
                color: AppColors.borderColor.withOpacity(0.3),
                width: 1,
              ),
              titlePositionPercentageOffset: 0.2,
              titleTextStyle: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
              getTitle: (index) {
                switch (index) {
                  case 0:
                    return 'Protein';
                  case 1:
                    return 'Carbs';
                  case 2:
                    return 'Fat';
                  case 3:
                    return fiberPercentage > 0 ? 'Fiber' : '';
                  case 4:
                    return sugarPercentage > 0 ? 'Sugar' : '';
                  case 5:
                    return sodiumPercentage > 0 ? 'Sodium' : '';
                  default:
                    return '';
                }
              },
              dataSets: [
                RadarDataSet(
                  fillColor: AppColors.primaryColor.withOpacity(0.2),
                  borderColor: AppColors.primaryColor,
                  borderWidth: 2,
                  entryRadius: 5,
                  dataEntries: [
                    RadarEntry(value: proteinPercentage * 10), // Scale to 0-10
                    RadarEntry(value: carbsPercentage * 10),
                    RadarEntry(value: fatPercentage * 10),
                    RadarEntry(value: fiberPercentage > 0 ? fiberPercentage * 10 : 0),
                    RadarEntry(value: sugarPercentage > 0 ? sugarPercentage * 10 : 0),
                    RadarEntry(value: sodiumPercentage > 0 ? sodiumPercentage * 10 : 0),
                  ],
                ),
                // Ideal macronutrient distribution
                RadarDataSet(
                  fillColor: Colors.transparent,
                  borderColor: AppColors.accentColor.withOpacity(0.5),
                  borderWidth: 1,
                  entryRadius: 0,
                  dataEntries: [
                    const RadarEntry(value: 3), // 30% protein
                    const RadarEntry(value: 5), // 50% carbs
                    const RadarEntry(value: 2), // 20% fat
                    const RadarEntry(value: fiberPercentage > 0 ? 3 : 0), // Ideal fiber
                    const RadarEntry(value: sugarPercentage > 0 ? 1 : 0), // Ideal sugar (low)
                    const RadarEntry(value: sodiumPercentage > 0 ? 2 : 0), // Ideal sodium
                  ],
                ),
              ],
            ),
            swapAnimationDuration: const Duration(milliseconds: 500),
          ),
          // Legend
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Your Diet', AppColors.primaryColor),
                const SizedBox(width: 16),
                _buildLegendItem('Recommended', AppColors.accentColor.withOpacity(0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall,
        ),
      ],
    );
  }
}
