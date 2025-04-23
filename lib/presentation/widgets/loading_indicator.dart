import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.size = 40.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
