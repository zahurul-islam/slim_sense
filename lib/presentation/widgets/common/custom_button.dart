import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final MainAxisAlignment contentAlignment;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
    this.padding,
    this.icon,
    this.contentAlignment = MainAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _backgroundColor = isOutlined 
        ? Colors.transparent 
        : (backgroundColor ?? AppColors.primaryColor);
    
    final _textColor = isOutlined 
        ? (textColor ?? AppColors.primaryColor) 
        : (textColor ?? AppColors.textWhiteColor);

    final buttonContent = Row(
      mainAxisAlignment: contentAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: AppTypography.buttonLarge.copyWith(color: _textColor),
        ),
      ],
    );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: _textColor,
              side: BorderSide(color: AppColors.primaryColor, width: 1.5),
              padding: padding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              minimumSize: Size(width ?? double.infinity, height),
            ),
            child: buttonContent,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _backgroundColor,
              foregroundColor: _textColor,
              padding: padding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              minimumSize: Size(width ?? double.infinity, height),
              elevation: 0,
            ),
            child: buttonContent,
          );

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          button,
          if (isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: _backgroundColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
