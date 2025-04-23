import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/food/food_bloc.dart';
import '../../../bloc/food/food_event.dart';
import '../../../bloc/food/food_state.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_state.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/app_typography.dart';
import '../../../../data/models/food_log_model.dart';
import '../../food/add_food_screen.dart';

class FoodTab extends StatefulWidget {
  const FoodTab({super.key});

  @override
  State<FoodTab> createState() => _FoodTabState();
}

class _FoodTabState extends State<FoodTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadFoodLogs();
  }

  void _loadFoodLogs() {
    final userState = context.read<UserBloc>().state;
    final authState = context.read<AuthBloc>().state;

    String userId = 'user123'; // Default fallback

    if (userState is UserLoaded) {
      userId = userState.user.id;
    } else if (authState is Authenticated) {
      userId = authState.user.id;
    }

    context.read<FoodBloc>().add(
      FoodLogsRequested(userId: userId, date: _selectedDate),
    );

    // Also request nutrition summary
    context.read<FoodBloc>().add(
      DailyNutritionSummaryRequested(userId: userId, date: _selectedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Diary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to food search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          _buildNutritionSummary(),
          Expanded(child: _buildFoodLogsList()),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                _loadFoodLogs();
              });
            },
          ),
          Text(
            _formatDate(_selectedDate),
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
                _loadFoodLogs();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSummary() {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is DailyNutritionSummaryLoaded) {
          final summary = state.summary;
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Goal',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Remaining',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('2000 cal', style: AppTypography.titleMedium),
                      Text(
                        '${2000 - (summary['totalCalories'] as num? ?? 0)} cal',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: ((summary['totalCalories'] as num? ?? 0) / 2000)
                        .clamp(0.0, 1.0),
                    backgroundColor: AppColors.primary.withAlpha(50),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroIndicator(
                        'Protein',
                        (summary['totalProtein'] as num? ?? 0).toDouble(),
                        120, // Target protein
                        AppColors.chartProtein,
                      ),
                      _buildMacroIndicator(
                        'Carbs',
                        (summary['totalCarbs'] as num? ?? 0).toDouble(),
                        250, // Target carbs
                        AppColors.chartCarbs,
                      ),
                      _buildMacroIndicator(
                        'Fat',
                        (summary['totalFat'] as num? ?? 0).toDouble(),
                        65, // Target fat
                        AppColors.chartFat,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMacroIndicator(
    String label,
    double value,
    double target,
    Color color,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                value: (value / target).clamp(0.0, 1.0),
                backgroundColor: color.withAlpha(50),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeWidth: 6,
              ),
            ),
            Text(
              '${value.toInt()}g',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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

  Widget _buildFoodLogsList() {
    return BlocBuilder<FoodBloc, FoodState>(
      builder: (context, state) {
        if (state is FoodLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FoodLogsLoaded) {
          final foodLogs = state.foodLogs;
          if (foodLogs.isEmpty) {
            return _buildEmptyState();
          }

          // Group food logs by meal type
          final groupedLogs = <String, List<FoodLogModel>>{};
          for (final log in foodLogs) {
            groupedLogs.putIfAbsent(log.mealType, () => []).add(log);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildMealSection('Breakfast', groupedLogs['breakfast'] ?? []),
              _buildMealSection('Lunch', groupedLogs['lunch'] ?? []),
              _buildMealSection('Dinner', groupedLogs['dinner'] ?? []),
              _buildMealSection('Snacks', groupedLogs['snack'] ?? []),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMealSection(String mealType, List<FoodLogModel> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                mealType,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (logs.isNotEmpty)
                Text(
                  '${logs.fold(0, (int sum, log) => sum + log.calories.toInt())} cal',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (logs.isEmpty)
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text('Add ${mealType.toLowerCase()}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => AddFoodScreen(
                          initialMealType: mealType.toLowerCase(),
                        ),
                  ),
                ).then((_) {
                  if (mounted) {
                    _loadFoodLogs();
                  }
                });
              },
            ),
          )
        else
          ...logs.map((log) => _buildFoodLogItem(log)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFoodLogItem(FoodLogModel log) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              log.photoUrl != null ? NetworkImage(log.photoUrl!) : null,
          child: log.photoUrl == null ? const Icon(Icons.restaurant) : null,
        ),
        title: Text(log.foodName),
        subtitle: Text(
          '${log.servingSize} ${log.servingUnit} • ${log.calories} cal',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (log.isFavorite)
              Icon(Icons.favorite, color: AppColors.error, size: 20),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                _showFoodLogOptions(log);
              },
            ),
          ],
        ),
        onTap: () {
          // TODO: Navigate to food details
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: AppColors.textSecondary.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'No food logs for this day',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your meals',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _loadFoodLogs();
      });
    }
  }

  void _showFoodLogOptions(FoodLogModel log) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
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
                      builder: (context) => AddFoodScreen(existingFood: log),
                    ),
                  ).then((_) {
                    if (mounted) {
                      _loadFoodLogs();
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<FoodBloc>().add(FoodLogDeleted(log.id));
                },
              ),
              ListTile(
                leading: Icon(
                  log.isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                title: Text(
                  log.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Toggle favorite status
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }
}
