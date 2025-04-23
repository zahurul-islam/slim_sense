import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_constants.dart';
import '../../../presentation/themes/app_colors.dart';
import '../../../presentation/themes/app_typography.dart';
import '../../../presentation/bloc/auth/auth_bloc.dart';
import '../../../presentation/bloc/user/user_bloc.dart';
import '../../../presentation/bloc/weight/weight_bloc.dart';
import '../../../presentation/bloc/food/food_bloc.dart';
import '../../../presentation/bloc/ai/ai_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/weight_log_model.dart';
import '../../../data/models/food_log_model.dart';

import 'tabs/dashboard_tab.dart';
import 'tabs/food_log_tab.dart';
import 'tabs/weight_tab.dart';
import 'tabs/insights_tab.dart';
import 'tabs/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // List of tabs
  late final List<Widget> _tabs;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tabs
    _tabs = [
      const DashboardTab(),
      const FoodLogTab(),
      const WeightTab(),
      const InsightsTab(),
      const ProfileTab(),
    ];
    
    // Load user data
    context.read<UserBloc>().add(LoadUserEvent());
    
    // Load weight data
    context.read<WeightBloc>().add(LoadWeightLogsEvent());
    
    // Load food logs for today
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    context.read<FoodBloc>().add(LoadFoodLogsForDateEvent(date: today));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundLight,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textGrayColor,
        selectedLabelStyle: AppTypography.bodySmall,
        unselectedLabelStyle: AppTypography.bodySmall,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_outlined),
            activeIcon: Icon(Icons.restaurant),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight_outlined),
            activeIcon: Icon(Icons.monitor_weight),
            label: 'Weight',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
