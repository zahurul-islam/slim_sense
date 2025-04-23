import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/ai/ai_bloc.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/markdown_viewer.dart';
import '../../../data/models/user_model.dart';

class WorkoutRecommendationScreen extends StatefulWidget {
  final UserModel user;

  const WorkoutRecommendationScreen({Key? key, required this.user})
    : super(key: key);

  @override
  State<WorkoutRecommendationScreen> createState() =>
      _WorkoutRecommendationScreenState();
}

class _WorkoutRecommendationScreenState
    extends State<WorkoutRecommendationScreen> {
  String _selectedFitnessLevel = 'Beginner';
  String _selectedGoal = 'Weight Loss';
  int _selectedDuration = 30;
  List<String> _selectedEquipment = [];
  bool _editingEquipment = false;

  final List<String> _fitnessLevels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _goals = [
    'Weight Loss',
    'Muscle Gain',
    'Endurance',
    'Strength',
    'Flexibility',
    'General Fitness',
  ];
  final List<int> _durations = [15, 30, 45, 60, 90];
  final List<String> _commonEquipment = [
    'None',
    'Dumbbells',
    'Resistance Bands',
    'Kettlebell',
    'Jump Rope',
    'Yoga Mat',
    'Pull-up Bar',
    'Bench',
    'Barbell',
    'Treadmill',
    'Exercise Bike',
    'Elliptical',
  ];

  @override
  void initState() {
    super.initState();
    // Set initial values based on user profile if available
    _setInitialValues();
  }

  void _setInitialValues() {
    // Set fitness level based on user's activity level
    if (widget.user.activityLevel != null) {
      final activityLevel = widget.user.activityLevel!.toLowerCase();
      if (activityLevel.contains('sedentary') ||
          activityLevel.contains('lightly')) {
        _selectedFitnessLevel = 'Beginner';
      } else if (activityLevel.contains('moderate')) {
        _selectedFitnessLevel = 'Intermediate';
      } else if (activityLevel.contains('very') ||
          activityLevel.contains('extremely')) {
        _selectedFitnessLevel = 'Advanced';
      }
    }

    // Set goal based on user's target weight vs current weight
    if (widget.user.targetWeight != null && widget.user.currentWeight != null) {
      if (widget.user.targetWeight! < widget.user.currentWeight!) {
        _selectedGoal = 'Weight Loss';
      } else if (widget.user.targetWeight! > widget.user.currentWeight!) {
        _selectedGoal = 'Muscle Gain';
      } else {
        _selectedGoal = 'General Fitness';
      }
    }

    // Default equipment to "None"
    _selectedEquipment = ['None'];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiBloc, AiState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFitnessLevelSelector(),
              const SizedBox(height: 20),
              _buildGoalSelector(),
              const SizedBox(height: 20),
              _buildDurationSelector(),
              const SizedBox(height: 20),
              _buildEquipmentSelector(),
              const SizedBox(height: 24),
              _buildGenerateButton(),
              const SizedBox(height: 32),
              _buildRecommendationSection(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFitnessLevelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fitness Level', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              _fitnessLevels.map((level) {
                return ChoiceChip(
                  label: Text(level),
                  selected: _selectedFitnessLevel == level,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFitnessLevel = level;
                      });
                    }
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color:
                        _selectedFitnessLevel == level
                            ? AppColors.primary
                            : AppColors.textSecondary,
                    fontWeight:
                        _selectedFitnessLevel == level
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildGoalSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Workout Goal', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _goals.map((goal) {
                return ChoiceChip(
                  label: Text(goal),
                  selected: _selectedGoal == goal,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedGoal = goal;
                      });
                    }
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.secondary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color:
                        _selectedGoal == goal
                            ? AppColors.secondary
                            : AppColors.textSecondary,
                    fontWeight:
                        _selectedGoal == goal
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Workout Duration (minutes)', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        Slider(
          value: _selectedDuration.toDouble(),
          min: 15,
          max: 90,
          divisions: 5,
          label: '$_selectedDuration min',
          onChanged: (value) {
            setState(() {
              _selectedDuration = value.round();
            });
          },
          activeColor: AppColors.primary,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              _durations.map((duration) {
                return Text(
                  '$duration',
                  style:
                      _selectedDuration == duration
                          ? AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          )
                          : AppTypography.bodySmall,
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildEquipmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Available Equipment', style: AppTypography.titleMedium),
            TextButton(
              onPressed: () {
                setState(() {
                  _editingEquipment = !_editingEquipment;
                });
              },
              child: Text(_editingEquipment ? 'Done' : 'Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_editingEquipment)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _commonEquipment.map((equipment) {
                  return FilterChip(
                    label: Text(equipment),
                    selected: _selectedEquipment.contains(equipment),
                    onSelected: (selected) {
                      setState(() {
                        if (equipment == 'None') {
                          if (selected) {
                            _selectedEquipment = ['None'];
                          } else {
                            _selectedEquipment = [];
                          }
                        } else {
                          if (selected) {
                            _selectedEquipment.remove('None');
                            _selectedEquipment.add(equipment);
                          } else {
                            _selectedEquipment.remove(equipment);
                            if (_selectedEquipment.isEmpty) {
                              _selectedEquipment = ['None'];
                            }
                          }
                        }
                      });
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _selectedEquipment.isEmpty
                    ? [const Text('No equipment selected')]
                    : _selectedEquipment.map((equipment) {
                      return Chip(
                        label: Text(equipment),
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                      );
                    }).toList(),
          ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return CustomButton(
      label: 'Generate Workout',
      onPressed: () {
        // Generate the workout recommendation
        context.read<AiBloc>().add(
          GetWorkoutRecommendation(
            fitnessLevel: _selectedFitnessLevel,
            goal: _selectedGoal,
            availableMinutes: _selectedDuration,
            availableEquipment: _selectedEquipment,
          ),
        );
      },
      icon: Icons.fitness_center,
    );
  }

  Widget _buildRecommendationSection(AiState state) {
    if (state is AiLoading) {
      return const Center(
        child: LoadingIndicator(
          message: 'Creating your personalized workout...',
        ),
      );
    } else if (state is WorkoutRecommendationLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Workout Plan', style: AppTypography.heading5),
          const SizedBox(height: 16),
          MarkdownViewer(markdown: state.recommendation),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Save Workout',
                  onPressed: () {
                    // TODO: Save the workout
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout saved successfully'),
                      ),
                    );
                  },
                  icon: Icons.save,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  label: 'Start Now',
                  onPressed: () {
                    // TODO: Navigate to workout timer
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Workout started')),
                    );
                  },
                  icon: Icons.play_arrow,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (state is AiError) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text('Error generating workout', style: AppTypography.titleMedium),
            const SizedBox(height: 8),
            Text(
              state.message,
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
            Icon(Icons.fitness_center, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Get your personalized workout!',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Set your preferences above and click "Generate Workout" to receive a tailored workout plan that fits your needs.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
