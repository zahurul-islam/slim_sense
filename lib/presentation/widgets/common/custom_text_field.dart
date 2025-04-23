import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final bool autofocus;
  final Color? fillColor;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint = '',
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding,
    this.autofocus = false,
    this.fillColor,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText && _obscureText,
          enabled: widget.enabled,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          autofocus: widget.autofocus,
          textCapitalization: widget.textCapitalization,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimaryColor,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textTertiaryColor,
            ),
            filled: true,
            fillColor: widget.fillColor ?? AppColors.surfaceColor,
            contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondaryColor,
                    ),
                    onPressed: _toggleObscureText,
                  )
                : widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderColor,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.borderColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.errorColor,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.dividerColor,
                width: 1,
              ),
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
