import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';

class CustomTabBar extends PreferredSize {
  final TabController controller;
  final List<Widget> tabs;
  final double height;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;

  CustomTabBar({
    Key? key,
    required this.controller,
    required this.tabs,
    this.height = 48.0,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
  }) : super(
          key: key,
          preferredSize: Size.fromHeight(height),
          child: Container(),
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor,
            width: 1.0,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        labelColor: labelColor ?? AppColors.primary,
        unselectedLabelColor: unselectedLabelColor ?? AppColors.textSecondary,
        labelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: AppTypography.labelMedium,
        indicatorColor: indicatorColor ?? AppColors.primary,
        indicatorWeight: 3.0,
        indicatorSize: TabBarIndicatorSize.label,
        labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
        isScrollable: tabs.length > 3,
      ),
    );
  }
}
