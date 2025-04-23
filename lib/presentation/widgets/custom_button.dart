import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final Function()? onPressed;
  final IconData? icon;
  final Color? color;
  final bool disabled;
  final String? tooltip;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.disabled = false,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;
    final isDisabled = disabled || onPressed == null;

    Widget button = ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.disabledColor,
        disabledForegroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: AppTypography.buttonText,
          ),
        ],
      ),
    );

    // Add tooltip if provided and button is disabled
    if (tooltip != null && isDisabled) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
