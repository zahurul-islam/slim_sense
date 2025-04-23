import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/weight/weight_bloc.dart';
import '../../bloc/weight/weight_event.dart';
import '../../bloc/food/food_bloc.dart';
import '../../bloc/food/food_event.dart';
import '../../themes/app_colors.dart';
import '../weight/add_weight_screen.dart';
import '../food/add_food_screen.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/food_tab.dart';
import 'tabs/weight_tab.dart';
import 'tabs/ai_coach_tab.dart';
import 'tabs/profile_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);

    // Load user data
    // TODO: Implement LoadUserData event
    // For now, let's use a placeholder userId
    setState(() {
      _userId = 'user123';
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserLoaded) {
          setState(() {
            _userId = state.user.id;
          });
        }
      },
      child: DefaultTabController(
        length: 5,
        initialIndex: _selectedIndex,
        child: Scaffold(
          body:
              _userId == null
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const DashboardTab(),
                      const FoodTab(),
                      WeightTab(userId: _userId!),
                      const AiCoachTab(),
                      const ProfileTab(),
                    ],
                  ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                  _tabController.animateTo(index);
                });
              },
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: AppColors.textSecondary,
              elevation: 8,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant_menu),
                  label: 'Food',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monitor_weight),
                  label: 'Weight',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.psychology),
                  label: 'AI Coach',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_selectedIndex == 1) {
      // Food tab - Add food log
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFoodScreen()),
          ).then((_) {
            if (!mounted) return;
            // Refresh food logs
            if (_userId != null) {
              context.read<FoodBloc>().add(
                FoodLogsRequested(userId: _userId!, date: DateTime.now()),
              );
            }
          });
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      );
    } else if (_selectedIndex == 2) {
      // Weight tab - Add weight log
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddWeightScreen()),
          ).then((_) {
            if (!mounted) return;
            // Refresh weight logs
            if (_userId != null) {
              context.read<WeightBloc>().add(
                LoadWeightLogs(
                  userId: _userId!,
                  startDate: DateTime.now().subtract(const Duration(days: 30)),
                  endDate: DateTime.now(),
                ),
              );
            }
          });
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add),
      );
    }
    return null;
  }
}
