import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';

class InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final double? progress;
  final Map<String, dynamic>? data;
  final String? actionText;
  final VoidCallback? onAction;

  const InsightCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.progress,
    this.data,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: AppTypography.bodyMedium,
            ),
            if (progress != null) ...[
              const SizedBox(height: 16),
              Center(
                child: CircularPercentIndicator(
                  radius: 60,
                  lineWidth: 10,
                  percent: progress!,
                  center: Text(
                    '${(progress! * 100).toStringAsFixed(0)}%',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  progressColor: color,
                  backgroundColor: color.withOpacity(0.2),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1500,
                ),
              ),
            ],
            if (data != null && data!.containsKey('protein')) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroIndicator(
                    'Protein',
                    data!['protein'],
                    AppColors.chartBlue,
                  ),
                  _buildMacroIndicator(
                    'Carbs',
                    data!['carbs'],
                    AppColors.chartGreen,
                  ),
                  _buildMacroIndicator(
                    'Fat',
                    data!['fat'],
                    AppColors.chartYellow,
                  ),
                ],
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionText!,
                    style: TextStyle(color: color),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMacroIndicator(String label, double value, Color color) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 30,
          lineWidth: 5,
          percent: value,
          center: Text(
            '${(value * 100).toStringAsFixed(0)}%',
            style: AppTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          progressColor: color,
          backgroundColor: color.withOpacity(0.2),
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall,
        ),
      ],
    );
  }
}
