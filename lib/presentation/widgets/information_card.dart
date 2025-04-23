import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';

class InformationCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;

  const InformationCard({
    Key? key,
    required this.title,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? AppColors.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
