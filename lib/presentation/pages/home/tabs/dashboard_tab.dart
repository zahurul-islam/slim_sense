import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../data/models/weight_log_model.dart';
import '../../../../presentation/themes/app_colors.dart';
import '../../../../presentation/themes/app_typography.dart';
import '../../../../presentation/bloc/user/user_bloc.dart';
import '../../../../presentation/bloc/user/user_state.dart';
import '../../../../presentation/bloc/weight/weight_bloc.dart';
import '../../../../presentation/bloc/weight/weight_event.dart';
import '../../../../presentation/bloc/weight/weight_state.dart';
import '../../../../presentation/bloc/food/food_bloc.dart';
import '../../../../presentation/bloc/food/food_event.dart';
import '../../../../presentation/bloc/food/food_state.dart';
import '../../weight/add_weight_screen.dart';
import '../../food/add_food_screen.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    _refreshWeightData();
    _refreshFoodData();
  }

  void _refreshWeightData() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      context.read<WeightBloc>().add(
        LoadWeightLogs(
          userId: userState.user.id,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ),
      );
    }
  }

  void _refreshFoodData() {
    final userState = context.read<UserBloc>().state;
    if (userState is UserLoaded) {
      context.read<FoodBloc>().add(
        FoodLogsRequested(userId: userState.user.id, date: DateTime.now()),
      );

      context.read<FoodBloc>().add(
        DailyNutritionSummaryRequested(
          userId: userState.user.id,
          date: DateTime.now(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: AppColors.primaryColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Text(
                  'Hello, User!',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
                Text(
                  'Track your progress and stay motivated',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildQuickActionsSection(context),
                const SizedBox(height: 24),
                _buildWaterTrackingCard(),
                const SizedBox(height: 24),
                _buildNutritionSummaryCard(),
                const SizedBox(height: 24),
                _buildWeightTrendCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Quick Actions',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.monitor_weight,
                  title: 'Log Weight',
                  color: AppColors.chartBlue,
                  onTap: () {
                    // Navigate to add weight screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddWeightScreen(),
                      ),
                    ).then((_) {
                      // Refresh weight data when returning from add weight screen
                      if (!mounted) return;
                      _refreshWeightData();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.restaurant,
                  title: 'Log Food',
                  color: AppColors.chartGreen,
                  onTap: () {
                    // Navigate to add food screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddFoodScreen(),
                      ),
                    ).then((_) {
                      if (!mounted) return;
                      _refreshFoodData();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.insights,
                  title: 'Insights',
                  color: AppColors.chartPurple,
                  onTap: () {
                    // Switch to AI coach tab for insights
                    final tabController = DefaultTabController.of(context);
                    tabController.animateTo(3);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shadowColor: color.withAlpha(40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(25),
                      blurRadius: 8,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // State variables for water tracking
  int waterTarget = 8; // 8 cups per day
  int currentWaterIntake = 3; // Current cups consumed

  Widget _buildWaterTrackingCard() {
    double waterProgress = currentWaterIntake / waterTarget;

    return Card(
      elevation: 4,
      shadowColor: Colors.blue.withAlpha(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.water_drop, color: Colors.blue, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Water Intake',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Daily Goal',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$currentWaterIntake/$waterTarget',
                      style: AppTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'cups',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(waterProgress * 100).toInt()}%',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: waterProgress,
                backgroundColor: Colors.blue.withAlpha(30),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildWaterButton(Icons.remove, () {
                  setState(() {
                    if (currentWaterIntake > 0) {
                      currentWaterIntake--;
                    }
                  });
                }),
                Row(
                  children: List.generate(
                    waterTarget,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Icon(
                        Icons.water_drop,
                        size: 24,
                        color:
                            index < currentWaterIntake
                                ? Colors.blue.shade700
                                : Colors.blue.withAlpha(50),
                      ),
                    ),
                  ),
                ),
                _buildWaterButton(Icons.add, () {
                  setState(() {
                    if (currentWaterIntake < waterTarget) {
                      currentWaterIntake++;
                    }
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withAlpha(20),
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 24, color: Colors.blue.shade700),
        ),
      ),
    );
  }

  Widget _buildNutritionSummaryCard() {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is DailyNutritionSummaryLoaded) {
          final summary = state.summary;
          final totalCalories = summary['totalCalories'] as int? ?? 0;
          final totalProtein = summary['totalProtein'] as int? ?? 0;
          final totalCarbs = summary['totalCarbs'] as int? ?? 0;
          final totalFat = summary['totalFat'] as int? ?? 0;

          // Default calorie goal
          const calorieGoal = 2000;

          return Card(
            elevation: 4,
            shadowColor: AppColors.chartGreen.withAlpha(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            color: AppColors.chartGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Today\'s Nutrition',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.chartGreen.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${totalCalories.toString()} / $calorieGoal cal',
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.chartGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (totalCalories / calorieGoal).clamp(0.0, 1.0),
                      backgroundColor: AppColors.chartGreen.withAlpha(30),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.chartGreen,
                      ),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacronutrient(
                        'Protein',
                        totalProtein,
                        'g',
                        AppColors.chartBlue,
                      ),
                      _buildMacronutrient(
                        'Carbs',
                        totalCarbs,
                        'g',
                        AppColors.chartGreen,
                      ),
                      _buildMacronutrient(
                        'Fat',
                        totalFat,
                        'g',
                        AppColors.chartYellow,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // Navigate to food tab
                        final tabController = DefaultTabController.of(context);
                        tabController.animateTo(1);
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('View Food Diary'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Loading or no data state
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: AppColors.chartGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Today\'s Nutrition',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: AppColors.textSecondary.withAlpha(100),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No food logged today',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddFoodScreen(),
                            ),
                          ).then((_) {
                            if (!mounted) return;
                            _refreshFoodData();
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Log Food'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.chartGreen,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMacronutrient(String name, num value, String unit, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.pie_chart_rounded, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          '$value$unit',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        Text(
          name,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightTrendCard() {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, state) {
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Weight Trend',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to weight tab
                        final tabController = DefaultTabController.of(context);
                        tabController.animateTo(2);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'View All',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state is WeightLogsLoaded &&
                    state.weightLogs.isNotEmpty) ...[
                  _buildWeightChart(state.weightLogs),
                  const SizedBox(height: 16),
                  _buildWeightSummary(state.weightLogs),
                ] else if (state is WeightLoading) ...[
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.monitor_weight_outlined,
                            size: 48,
                            color: AppColors.textSecondary.withAlpha(100),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No weight data available',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddWeightScreen(),
                                ),
                              ).then((_) {
                                if (!mounted) return;
                                _refreshWeightData();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text('Log Weight'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeightChart(List<WeightLogModel> logs) {
    if (logs.isEmpty) return const SizedBox.shrink();

    // Sort logs by date
    final sortedLogs = List<WeightLogModel>.from(logs)
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

    // Get the last 7 logs or all if less than 7
    final displayLogs =
        sortedLogs.length > 7
            ? sortedLogs.sublist(sortedLogs.length - 7)
            : sortedLogs;

    // Create spots for the chart
    final spots =
        displayLogs
            .asMap()
            .entries
            .map(
              (entry) => FlSpot(entry.key.toDouble(), entry.value.weightInKg),
            )
            .toList();

    // Calculate min and max values for the chart
    final minWeight = displayLogs
        .map((log) => log.weightInKg)
        .reduce((a, b) => a < b ? a : b);
    final maxWeight = displayLogs
        .map((log) => log.weightInKg)
        .reduce((a, b) => a > b ? a : b);

    // Add some padding to the min and max values
    final minY = minWeight - 1;
    final maxY = maxWeight + 1;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
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
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < displayLogs.length) {
                    final date = displayLogs[value.toInt()].loggedAt;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd').format(date),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (displayLogs.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
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
                show: true,
                color: AppColors.primaryColor.withAlpha(50),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryColor.withAlpha(100),
                    AppColors.primaryColor.withAlpha(0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightSummary(List<WeightLogModel> logs) {
    if (logs.isEmpty) return const SizedBox.shrink();

    // Sort logs by date
    final sortedLogs = List<WeightLogModel>.from(logs)
      ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

    final firstWeight = sortedLogs.first.weightInKg;
    final currentWeight = sortedLogs.last.weightInKg;
    final weightChange = currentWeight - firstWeight;
    final isWeightLoss = weightChange < 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildWeightSummaryItem(
          'Starting',
          '${firstWeight.toStringAsFixed(1)} kg',
          Icons.flag,
          AppColors.textSecondary,
        ),
        _buildWeightSummaryItem(
          'Current',
          '${currentWeight.toStringAsFixed(1)} kg',
          Icons.monitor_weight,
          AppColors.primaryColor,
        ),
        _buildWeightSummaryItem(
          'Change',
          '${isWeightLoss ? '' : '+'}${weightChange.toStringAsFixed(1)} kg',
          isWeightLoss ? Icons.trending_down : Icons.trending_up,
          isWeightLoss ? AppColors.successColor : AppColors.errorColor,
        ),
      ],
    );
  }

  Widget _buildWeightSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
