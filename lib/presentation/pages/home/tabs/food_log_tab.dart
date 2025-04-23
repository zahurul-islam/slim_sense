import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../presentation/themes/app_colors.dart';
import '../../../../presentation/themes/app_typography.dart';
import '../../../../presentation/bloc/food/food_bloc.dart';
import '../../../../data/models/food_log_model.dart';
import '../../food/add_food_screen.dart';

class FoodLogTab extends StatefulWidget {
  const FoodLogTab({Key? key}) : super(key: key);

  @override
  State<FoodLogTab> createState() => _FoodLogTabState();
}

class _FoodLogTabState extends State<FoodLogTab> {
  // Selected date for calendar
  DateTime _selectedDate = DateTime.now();
  
  // Calendar format
  CalendarFormat _calendarFormat = CalendarFormat.week;
  
  @override
  void initState() {
    super.initState();
    _loadFoodLogs();
  }
  
  void _loadFoodLogs() {
    final date = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    context.read<FoodBloc>().add(LoadFoodLogsForDateEvent(date: date));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          'Food Journal',
          style: AppTypography.heading4,
        ),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            color: AppColors.textPrimaryColor,
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar
          _buildCalendar(),
          
          // Food logs list
          Expanded(
            child: BlocBuilder<FoodBloc, FoodState>(
              builder: (context, state) {
                if (state is FoodLogsLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is FoodLogsLoadedState) {
                  if (state.foodLogs.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildFoodLogsList(state.foodLogs);
                } else if (state is FoodLogsErrorState) {
                  return Center(
                    child: Text(
                      'Error: ${state.message}',
                      style: AppTypography.bodyMedium,
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddFoodScreen(selectedDate: _selectedDate)),
          ).then((_) => _loadFoodLogs());
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _selectedDate,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDate, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = selectedDay;
          });
          _loadFoodLogs();
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: true,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primaryLightColor,
            borderRadius: BorderRadius.circular(16),
          ),
          formatButtonTextStyle: AppTypography.buttonSmall.copyWith(
            color: AppColors.primaryDarkColor,
          ),
          titleTextStyle: AppTypography.heading5,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.textPrimaryColor,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.textPrimaryColor,
          ),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primaryLightColor,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textWhiteColor,
          ),
          todayTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.primaryDarkColor,
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    final formattedDate = DateFormat('MMMM d, yyyy').format(_selectedDate);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 80,
            color: AppColors.textTertiaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No meals logged for $formattedDate',
            style: AppTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your meals',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFoodScreen(selectedDate: _selectedDate)),
              ).then((_) => _loadFoodLogs());
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Meal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.textWhiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFoodLogsList(List<FoodLogModel> foodLogs) {
    // Group food logs by meal type
    final Map<String, List<FoodLogModel>> groupedLogs = {
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
      'Snack': [],
    };
    
    for (var log in foodLogs) {
      final mealType = log.mealType.toString().split('.').last;
      groupedLogs[mealType]?.add(log);
    }
    
    // Calculate total calories
    final int totalCalories = foodLogs.fold(0, (sum, item) => sum + item.calories);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total calories card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.secondaryColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Calories',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalCalories kcal',
                        style: AppTypography.heading4.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Food logs by meal type
          ...groupedLogs.entries.map((entry) {
            final mealType = entry.key;
            final logs = entry.value;
            
            if (logs.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal type header
                Row(
                  children: [
                    _getMealTypeIcon(mealType),
                    const SizedBox(width: 8),
                    Text(
                      mealType,
                      style: AppTypography.heading5,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Divider(thickness: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Meal items
                ...logs.map((log) => _buildFoodLogItem(log)),
                
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildFoodLogItem(FoodLogModel log) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          log.foodName,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${log.servingSize} ${log.servingUnit}',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildNutrientBadge('P: ${log.protein.toInt()}g', AppColors.chartBlue),
                const SizedBox(width: 8),
                _buildNutrientBadge('C: ${log.carbs.toInt()}g', AppColors.chartGreen),
                const SizedBox(width: 8),
                _buildNutrientBadge('F: ${log.fat.toInt()}g', AppColors.chartPurple),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${log.calories} kcal',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('h:mm a').format(log.loggedAt),
              style: AppTypography.caption,
            ),
          ],
        ),
        onTap: () {
          // View food details
        },
        onLongPress: () {
          // Show edit/delete options
          _showFoodLogOptions(log);
        },
      ),
    );
  }
  
  Widget _buildNutrientBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _getMealTypeIcon(String mealType) {
    IconData iconData;
    Color iconColor;
    
    switch (mealType) {
      case 'Breakfast':
        iconData = Icons.free_breakfast;
        iconColor = AppColors.chartOrange;
        break;
      case 'Lunch':
        iconData = Icons.lunch_dining;
        iconColor = AppColors.primaryColor;
        break;
      case 'Dinner':
        iconData = Icons.dinner_dining;
        iconColor = AppColors.chartPurple;
        break;
      case 'Snack':
        iconData = Icons.cookie;
        iconColor = AppColors.chartYellow;
        break;
      default:
        iconData = Icons.restaurant;
        iconColor = AppColors.primaryColor;
    }
    
    return Icon(
      iconData,
      size: 24,
      color: iconColor,
    );
  }
  
  void _showFoodLogOptions(FoodLogModel log) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to edit food log screen
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: AppColors.errorColor,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(
                    color: AppColors.errorColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteFoodLog(log);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _confirmDeleteFoodLog(FoodLogModel log) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Food Entry'),
          content: Text('Are you sure you want to delete ${log.foodName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'DELETE',
                style: TextStyle(
                  color: AppColors.errorColor,
                ),
              ),
            ),
          ],
        );
      },
    );
    
    if (confirm == true) {
      context.read<FoodBloc>().add(DeleteFoodLogEvent(foodLogId: log.id));
    }
  }
}
