import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/user/user_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user/user_state.dart';
import '../themes/app_colors.dart';
import '../themes/app_typography.dart';
import 'home/home_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final _heightController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedActivityLevel;
  DateTime? _selectedBirthDate;
  List<String> _selectedDietaryPreferences = [];
  List<String> _selectedAllergies = [];

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _activityLevels = [
    'Sedentary (little or no exercise)',
    'Light (exercise 1-3 times/week)',
    'Moderate (exercise 3-5 times/week)',
    'Active (exercise 6-7 times/week)',
    'Very Active (hard exercise daily)',
  ];

  final List<String> _dietaryOptions = [
    'Vegetarian',
    'Vegan',
    'Keto',
    'Paleo',
    'Low Carb',
    'Mediterranean',
    'Halal',
    'Kosher',
  ];

  final List<String> _allergyOptions = [
    'Peanuts',
    'Tree Nuts',
    'Milk',
    'Eggs',
    'Soy',
    'Wheat',
    'Fish',
    'Shellfish',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    // TODO: Save all onboarding data to user profile
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 30),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _ageController.text = _calculateAge(picked).toString();
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 5,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryColor,
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPersonalInfoPage(),
                  _buildBodyMetricsPage(),
                  _buildGoalsPage(),
                  _buildDietaryPreferencesPage(),
                  _buildActivityLevelPage(),
                ],
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(_currentPage == 4 ? 'Complete' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let\'s get to know you better',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // Gender selection
          Text('Gender', style: AppTypography.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                _genderOptions.map((gender) {
                  return ChoiceChip(
                    label: Text(gender),
                    selected: _selectedGender == gender,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGender = selected ? gender : null;
                      });
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 24),
          // Birth date
          TextFormField(
            controller: _ageController,
            readOnly: true,
            onTap: _selectBirthDate,
            decoration: const InputDecoration(
              labelText: 'Age',
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Body Metrics',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us understand your current status',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              suffixIcon: Icon(Icons.straighten),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _currentWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Current Weight (kg)',
              suffixIcon: Icon(Icons.monitor_weight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Goals',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to achieve?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _targetWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target Weight (kg)',
              suffixIcon: Icon(Icons.flag),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary Preferences',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select your dietary preferences',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _dietaryOptions.map((diet) {
                  return FilterChip(
                    label: Text(diet),
                    selected: _selectedDietaryPreferences.contains(diet),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDietaryPreferences.add(diet);
                        } else {
                          _selectedDietaryPreferences.remove(diet);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
          const SizedBox(height: 32),
          Text('Allergies', style: AppTypography.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _allergyOptions.map((allergy) {
                  return FilterChip(
                    label: Text(allergy),
                    selected: _selectedAllergies.contains(allergy),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAllergies.add(allergy);
                        } else {
                          _selectedAllergies.remove(allergy);
                        }
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Level',
            style: AppTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How active are you?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ..._activityLevels.map((level) {
            return RadioListTile<String>(
              title: Text(level),
              value: level,
              groupValue: _selectedActivityLevel,
              onChanged: (value) {
                setState(() {
                  _selectedActivityLevel = value;
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
