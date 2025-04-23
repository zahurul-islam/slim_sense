import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/ai/ai_bloc.dart';
import '../../bloc/weight/weight_bloc.dart';
import '../../bloc/weight/weight_state.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/information_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/markdown_viewer.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/weight_log_model.dart';
import 'package:intl/intl.dart';

class WeightForecastScreen extends StatefulWidget {
  final UserModel user;

  const WeightForecastScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<WeightForecastScreen> createState() => _WeightForecastScreenState();
}

class _WeightForecastScreenState extends State<WeightForecastScreen> {
  final TextEditingController _targetWeightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _targetWeightController.text = widget.user.targetWeight?.toString() ?? '';
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiBloc, AiState>(
      builder: (context, aiState) {
        return BlocBuilder<WeightBloc, WeightState>(
          builder: (context, weightState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeightOverview(weightState),
                  const SizedBox(height: 24),
                  _buildTargetWeightInput(),
                  const SizedBox(height: 24),
                  _buildGenerateButton(weightState),
                  const SizedBox(height: 32),
                  _buildForecastSection(aiState, weightState),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeightOverview(WeightState weightState) {
    // Extract weight data for the chart
    List<WeightLogModel> logs = [];
    double startWeight = widget.user.starting_weight ?? 0;
    double currentWeight = widget.user.current_weight ?? 0;
    double targetWeight = widget.user.target_weight ?? 0;
    String trend = 'Stable';

    if (weightState is WeightLogsLoaded) {
      logs = weightState.weightLogs;

      if (logs.isNotEmpty) {
        logs.sort((a, b) => a.logged_at.compareTo(b.logged_at));

        if (logs.length >= 2) {
          final first = logs.first;
          final last = logs.last;

          if (last.weight_kg < first.weight_kg) {
            trend = 'Losing';
          } else if (last.weight_kg > first.weight_kg) {
            trend = 'Gaining';
          }
        }
      }
    }

    return InformationCard(
      title: 'Weight Progress Overview',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                'Starting Weight',
                '${startWeight.toStringAsFixed(1)} kg',
                Icons.play_arrow,
              ),
              _buildStatColumn(
                'Current Weight',
                '${currentWeight.toStringAsFixed(1)} kg',
                Icons.person,
              ),
              _buildStatColumn(
                'Target Weight',
                '${targetWeight.toStringAsFixed(1)} kg',
                Icons.flag,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTrend(trend),
          const SizedBox(height: 16),
          if (logs.length >= 2) _buildMiniChart(logs),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTrend(String trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case 'Losing':
        icon = Icons.trending_down;
        color = AppColors.success;
        break;
      case 'Gaining':
        icon = Icons.trending_up;
        color =
            trend == 'Gaining' &&
                    widget.user.targetWeight! > widget.user.currentWeight!
                ? AppColors
                    .success // If goal is to gain weight
                : AppColors.error; // If goal is to lose weight
        break;
      case 'Stable':
      default:
        icon = Icons.trending_flat;
        color = AppColors.warning;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          'Current Trend: $trend',
          style: AppTypography.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniChart(List<WeightLogModel> logs) {
    // We want to show max 10 points for the mini chart
    final displayLogs =
        logs.length > 10 ? logs.sublist(logs.length - 10) : logs;

    // Calculate min and max for the chart
    final minWeight = displayLogs
        .map((log) => log.weight_kg)
        .reduce((a, b) => a < b ? a : b);
    final maxWeight = displayLogs
        .map((log) => log.weight_kg)
        .reduce((a, b) => a > b ? a : b);

    // Pad the range a bit
    final minY = minWeight - 1;
    final maxY = maxWeight + 1;

    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minX: 0,
          maxX: (displayLogs.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots:
                  displayLogs.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value.weight_kg);
                  }).toList(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetWeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Target Weight (kg)', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _targetWeightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter your target weight',
            suffixText: 'kg',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton(WeightState weightState) {
    // Determine if we have enough logs for analysis
    bool hasEnoughLogs = false;
    if (weightState is WeightLogsLoaded) {
      hasEnoughLogs = weightState.weightLogs.length >= 2;
    }

    return CustomButton(
      label: 'Forecast Progress',
      onPressed:
          hasEnoughLogs
              ? () {
                // Validate target weight
                if (_targetWeightController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a target weight'),
                    ),
                  );
                  return;
                }

                final double? targetWeight = double.tryParse(
                  _targetWeightController.text,
                );
                if (targetWeight == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid target weight'),
                    ),
                  );
                  return;
                }

                // Generate weight forecast
                context.read<AiBloc>().add(
                  ForecastWeightProgress(targetWeight: targetWeight),
                );
              }
              : null,
      icon: Icons.insights,
      disabled: !hasEnoughLogs,
      tooltip:
          !hasEnoughLogs
              ? 'Log your weight at least twice to enable forecasting'
              : null,
    );
  }

  Widget _buildForecastSection(AiState aiState, WeightState weightState) {
    // Determine if we have enough logs for analysis
    bool hasEnoughLogs = false;
    if (weightState is WeightLogsLoaded) {
      hasEnoughLogs = weightState.weightLogs.length >= 2;
    }

    if (!hasEnoughLogs) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.scale, color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Not enough weight data for forecasting',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please log your weight at least twice to enable progress forecasting.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Go to Weight Log',
              onPressed: () {
                // Navigate to weight log tab
                Navigator.of(context).pop();
                // TODO: Navigate to weight tab
              },
              icon: Icons.monitor_weight,
              color: AppColors.secondary,
            ),
          ],
        ),
      );
    }

    if (aiState is AiLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Forecasting your weight progress...'),
      );
    } else if (aiState is WeightForecastLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Weight Progress Forecast', style: AppTypography.heading5),
          const SizedBox(height: 16),
          MarkdownViewer(markdown: aiState.forecast),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Save Forecast',
            onPressed: () {
              // TODO: Save the forecast
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Forecast saved successfully')),
              );
            },
            icon: Icons.save,
            color: AppColors.success,
          ),
        ],
      );
    } else if (aiState is AiError) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error forecasting your progress',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              aiState.message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Try Again',
              onPressed: () {
                // Reset the state
                context.read<AiBloc>().add(ResetAiState());
              },
              icon: Icons.refresh,
              color: AppColors.secondary,
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          children: [
            Icon(Icons.insights, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Get your weight progress forecast!',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Set your target weight above and click "Forecast Progress" to see predictions about your weight loss journey.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
