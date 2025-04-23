import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../presentation/themes/app_colors.dart';
import '../../../../presentation/themes/app_typography.dart';
import '../../../../presentation/bloc/weight/weight_bloc.dart';
import '../../../../presentation/bloc/weight/weight_event.dart';
import '../../../../presentation/bloc/weight/weight_state.dart';
import '../../../../presentation/bloc/user/user_bloc.dart';
import '../../../../data/models/weight_log_model.dart';
import '../../../../data/models/user_model.dart';
import '../../weight/add_weight_screen.dart';

class WeightTab extends StatefulWidget {
  final String userId;

  const WeightTab({Key? key, required this.userId}) : super(key: key);

  @override
  State<WeightTab> createState() => _WeightTabState();
}

class _WeightTabState extends State<WeightTab> {
  String _selectedTimeRange = '1M'; // 1W, 1M, 3M, 6M, 1Y, All

  @override
  void initState() {
    super.initState();
    context.read<WeightBloc>().add(
      LoadWeightLogs(
        userId: widget.userId,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text('Weight Tracker', style: AppTypography.heading4),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: AppColors.textPrimaryColor,
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<WeightBloc>().add(
            LoadWeightLogs(
              userId: widget.userId,
              startDate: DateTime.now().subtract(const Duration(days: 30)),
              endDate: DateTime.now(),
            ),
          );
        },
        // Simplified until user bloc is fully implemented
        child: _buildContent(
          UserModel(
            id: widget.userId,
            email: 'user@example.com',
            displayName: 'User',
            createdAt: DateTime.now(),
            currentWeight: 70.0,
            targetWeight: 65.0,
            height: 170.0,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWeightScreen()),
          ).then((_) {
            context.read<WeightBloc>().add(
              LoadWeightLogs(
                userId: widget.userId,
                startDate: DateTime.now().subtract(const Duration(days: 30)),
                endDate: DateTime.now(),
              ),
            );
          });
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(UserModel user) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeightSummaryCard(user),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weight Trend', style: AppTypography.heading5),
              _buildTimeRangeSelector(),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeightChart(),
          const SizedBox(height: 24),
          Text('Recent Logs', style: AppTypography.heading5),
          const SizedBox(height: 16),
          _buildRecentWeightLogs(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildWeightSummaryCard(UserModel user) {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, state) {
        double currentWeight = user.currentWeight ?? 0;
        double startWeight = user.currentWeight ?? 0;
        double targetWeight = user.targetWeight ?? 0;
        String weightUnit = AppConstants.metricUnit;

        if (state is WeightLogsLoaded && state.weightLogs.isNotEmpty) {
          final sortedLogs = List<WeightLogModel>.from(state.weightLogs)
            ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

          if (sortedLogs.isNotEmpty) {
            startWeight = sortedLogs.first.weightInKg;
            currentWeight = sortedLogs.last.weightInKg;
          }
        }

        final double weightChange = currentWeight - startWeight;
        final String changeDirection = weightChange >= 0 ? '+' : '';
        final Color changeColor =
            weightChange < 0 ? AppColors.successColor : AppColors.errorColor;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Current Weight', style: AppTypography.labelLarge),
                const SizedBox(height: 8),
                Text(
                  '${currentWeight.toStringAsFixed(1)} $weightUnit',
                  style: AppTypography.statsLarge,
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Total Change', style: AppTypography.labelMedium),
                        const SizedBox(height: 8),
                        Text(
                          '$changeDirection${weightChange.abs().toStringAsFixed(1)} $weightUnit',
                          style: AppTypography.statsMedium.copyWith(
                            color: changeColor,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Target Weight', style: AppTypography.labelMedium),
                        const SizedBox(height: 8),
                        Text(
                          '${targetWeight.toStringAsFixed(1)} $weightUnit',
                          style: AppTypography.statsMedium.copyWith(
                            color: AppColors.secondaryColor,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BMI', style: AppTypography.labelMedium),
                          const SizedBox(height: 4),
                          Text(
                            (user.bmi ?? 0).toStringAsFixed(1),
                            style: AppTypography.statsSmall.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Status', style: AppTypography.labelMedium),
                          const SizedBox(height: 4),
                          Text(
                            user.bmiCategory ?? 'Unknown',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _getBmiStatusColor(
                                user.bmiCategory ?? 'Unknown',
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildTimeRangeSelector() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTimeRangeButton('1W'),
          _buildTimeRangeButton('1M'),
          _buildTimeRangeButton('3M'),
          _buildTimeRangeButton('6M'),
          _buildTimeRangeButton('1Y'),
          _buildTimeRangeButton('All'),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(String range) {
    final bool isSelected = _selectedTimeRange == range;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeRange = range;
          final now = DateTime.now();
          DateTime startDate;

          switch (range) {
            case '1W':
              startDate = now.subtract(const Duration(days: 7));
              break;
            case '1M':
              startDate = DateTime(now.year, now.month - 1, now.day);
              break;
            case '3M':
              startDate = DateTime(now.year, now.month - 3, now.day);
              break;
            case '6M':
              startDate = DateTime(now.year, now.month - 6, now.day);
              break;
            case '1Y':
              startDate = DateTime(now.year - 1, now.month, now.day);
              break;
            case 'All':
            default:
              startDate = DateTime(2000);
              break;
          }

          context.read<WeightBloc>().add(
            LoadWeightLogs(
              userId: widget.userId,
              startDate: startDate,
              endDate: now,
            ),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          range,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color:
                isSelected
                    ? AppColors.textWhiteColor
                    : AppColors.textPrimaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildWeightChart() {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, state) {
        if (state is WeightLogsLoaded) {
          final logs = state.weightLogs;
          if (logs.isEmpty) {
            return Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              child: const Center(child: Text('No weight data available')),
            );
          }

          final sortedLogs = List<WeightLogModel>.from(logs)
            ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

          final spots =
              sortedLogs
                  .asMap()
                  .entries
                  .map(
                    (entry) =>
                        FlSpot(entry.key.toDouble(), entry.value.weightInKg),
                  )
                  .toList();

          return SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (spots.length - 1).toDouble(),
                minY:
                    sortedLogs
                        .map((log) => log.weightInKg)
                        .reduce((a, b) => a < b ? a : b) -
                    2,
                maxY:
                    sortedLogs
                        .map((log) => log.weightInKg)
                        .reduce((a, b) => a > b ? a : b) +
                    2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primaryColor,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(show: true),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox(
          height: 250,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildRecentWeightLogs() {
    return BlocBuilder<WeightBloc, WeightState>(
      builder: (context, state) {
        if (state is WeightLogsLoaded) {
          final logs = state.weightLogs.take(5).toList();
          if (logs.isEmpty) {
            return const Center(child: Text('No recent weight logs'));
          }

          return Column(
            children: logs.map((log) => _buildWeightLogItem(log)).toList(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildWeightLogItem(WeightLogModel log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(
          Icons.monitor_weight,
          color: AppColors.primaryColor,
        ),
        title: Text(DateFormat('MMM d, yyyy').format(log.loggedAt)),
        subtitle: Text(DateFormat('h:mm a').format(log.loggedAt)),
        trailing: Text('${log.weightInKg.toStringAsFixed(1)} kg'),
        onTap: () => _showWeightLogOptions(log),
      ),
    );
  }

  void _showWeightLogOptions(WeightLogModel log) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddWeightScreen(existingWeight: log),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteWeightLog(log);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteWeightLog(WeightLogModel log) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Weight Log'),
            content: const Text(
              'Are you sure you want to delete this weight log?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      context.read<WeightBloc>().add(
        DeleteWeightLog(weightLogId: log.id, userId: widget.userId),
      );
    }
  }

  Color _getBmiStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'underweight':
        return Colors.orange;
      case 'normal':
        return Colors.green;
      case 'overweight':
        return Colors.orange;
      case 'obese':
        return Colors.red;
      default:
        return AppColors.textPrimaryColor;
    }
  }
}
