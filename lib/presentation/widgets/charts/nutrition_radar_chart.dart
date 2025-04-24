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
    // Simplified version for compatibility with fl_chart 0.71.0
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomPaint(
              size: Size(size - 32, size - 32),
              painter: RadarChartPainter(
                proteinPercentage: proteinPercentage,
                carbsPercentage: carbsPercentage,
                fatPercentage: fatPercentage,
              ),
            ),
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
                _buildLegendItem(
                  'Recommended',
                  AppColors.secondaryColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
          // Labels
          Positioned(
            top: size * 0.1,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Protein',
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.25,
            right: size * 0.15,
            child: Text(
              'Carbs',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.25,
            left: size * 0.15,
            child: Text(
              'Fat',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }
}

// Custom painter for radar chart
class RadarChartPainter extends CustomPainter {
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatPercentage;

  RadarChartPainter({
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background grid
    _drawGrid(canvas, center, radius);

    // Draw actual values
    _drawValues(canvas, center, radius);

    // Draw ideal values
    _drawIdealValues(canvas, center, radius);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // Draw outer triangle
    final outerPath = Path();
    outerPath.moveTo(center.dx, center.dy - radius); // Top
    outerPath.lineTo(
      center.dx + radius * 0.866,
      center.dy + radius * 0.5,
    ); // Bottom right
    outerPath.lineTo(
      center.dx - radius * 0.866,
      center.dy + radius * 0.5,
    ); // Bottom left
    outerPath.close();
    canvas.drawPath(outerPath, gridPaint);

    // Draw inner triangles (grid)
    for (int i = 1; i <= 3; i++) {
      final innerRadius = radius * i / 4;
      final innerPath = Path();
      innerPath.moveTo(center.dx, center.dy - innerRadius); // Top
      innerPath.lineTo(
        center.dx + innerRadius * 0.866,
        center.dy + innerRadius * 0.5,
      ); // Bottom right
      innerPath.lineTo(
        center.dx - innerRadius * 0.866,
        center.dy + innerRadius * 0.5,
      ); // Bottom left
      innerPath.close();
      canvas.drawPath(innerPath, gridPaint);
    }

    // Draw axes
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius),
      gridPaint,
    ); // Vertical
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.866, center.dy + radius * 0.5),
      gridPaint,
    ); // Bottom right
    canvas.drawLine(
      center,
      Offset(center.dx - radius * 0.866, center.dy + radius * 0.5),
      gridPaint,
    ); // Bottom left
  }

  void _drawValues(Canvas canvas, Offset center, double radius) {
    final valuePaint =
        Paint()
          ..color = AppColors.primaryColor.withOpacity(0.7)
          ..style = PaintingStyle.fill;

    final borderPaint =
        Paint()
          ..color = AppColors.primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Scale values to fit within the chart (0-1 to 0-radius)
    final proteinRadius = radius * proteinPercentage;
    final carbsRadius = radius * carbsPercentage;
    final fatRadius = radius * fatPercentage;

    // Calculate points
    final proteinPoint = Offset(center.dx, center.dy - proteinRadius);
    final carbsPoint = Offset(
      center.dx + carbsRadius * 0.866,
      center.dy + carbsRadius * 0.5,
    );
    final fatPoint = Offset(
      center.dx - fatRadius * 0.866,
      center.dy + fatRadius * 0.5,
    );

    // Draw value area
    final valuePath = Path();
    valuePath.moveTo(proteinPoint.dx, proteinPoint.dy);
    valuePath.lineTo(carbsPoint.dx, carbsPoint.dy);
    valuePath.lineTo(fatPoint.dx, fatPoint.dy);
    valuePath.close();

    canvas.drawPath(valuePath, valuePaint);
    canvas.drawPath(valuePath, borderPaint);

    // Draw points
    canvas.drawCircle(proteinPoint, 4, Paint()..color = AppColors.primaryColor);
    canvas.drawCircle(carbsPoint, 4, Paint()..color = AppColors.primaryColor);
    canvas.drawCircle(fatPoint, 4, Paint()..color = AppColors.primaryColor);
  }

  void _drawIdealValues(Canvas canvas, Offset center, double radius) {
    final idealPaint =
        Paint()
          ..color = AppColors.secondaryColor.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // Ideal macronutrient distribution (30% protein, 50% carbs, 20% fat)
    final idealProteinRadius = radius * 0.3;
    final idealCarbsRadius = radius * 0.5;
    final idealFatRadius = radius * 0.2;

    // Calculate points
    final proteinPoint = Offset(center.dx, center.dy - idealProteinRadius);
    final carbsPoint = Offset(
      center.dx + idealCarbsRadius * 0.866,
      center.dy + idealCarbsRadius * 0.5,
    );
    final fatPoint = Offset(
      center.dx - idealFatRadius * 0.866,
      center.dy + idealFatRadius * 0.5,
    );

    // Draw ideal value area
    final idealPath = Path();
    idealPath.moveTo(proteinPoint.dx, proteinPoint.dy);
    idealPath.lineTo(carbsPoint.dx, carbsPoint.dy);
    idealPath.lineTo(fatPoint.dx, fatPoint.dy);
    idealPath.close();

    canvas.drawPath(idealPath, idealPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
