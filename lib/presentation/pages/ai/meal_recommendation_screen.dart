import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/ai/ai_bloc.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/markdown_viewer.dart';
import '../../../data/models/user_model.dart';
import '../meal_plan/meal_plan_screen.dart';

class MealRecommendationScreen extends StatefulWidget {
  final UserModel user;

  const MealRecommendationScreen({super.key, required this.user});

  @override
  State<MealRecommendationScreen> createState() =>
      _MealRecommendationScreenState();
}

class _MealRecommendationScreenState extends State<MealRecommendationScreen> {
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _restrictionController = TextEditingController();

  String _selectedMealType = 'Lunch';
  List<String> _selectedRestrictions = [];
  List<String> _availableIngredients = [];
  bool _editingRestrictions = false;
  bool _editingIngredients = false;

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  final List<String> _commonRestrictions = [
    'Vegetarian',
    'Vegan',
    'Gluten-free',
    'Dairy-free',
    'Nut-free',
    'Low-carb',
    'Keto',
    'Low-sodium',
    'Low-fat',
  ];

  @override
  void initState() {
    super.initState();
    // Default calories based on meal type
    _updateCaloriesForMealType();
    // Initial dietary restrictions from user profile
    _selectedRestrictions = List.from(widget.user.dietaryPreferences ?? []);
  }

  void _updateCaloriesForMealType() {
    // Set default calories based on meal type (percentages of daily calories)
    final dailyCalories = widget.user.calorie_goal ?? 2000;

    switch (_selectedMealType) {
      case 'Breakfast':
        _caloriesController.text = (dailyCalories * 0.25).round().toString();
        break;
      case 'Lunch':
        _caloriesController.text = (dailyCalories * 0.35).round().toString();
        break;
      case 'Dinner':
        _caloriesController.text = (dailyCalories * 0.3).round().toString();
        break;
      case 'Snack':
        _caloriesController.text = (dailyCalories * 0.1).round().toString();
        break;
    }
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _ingredientController.dispose();
    _restrictionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Recipe Generator'),
              Tab(text: 'Meal Plans'),
            ],
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryColor,
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Recipe Generator Tab
                BlocBuilder<AiBloc, AiState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMealTypeSelector(),
                          const SizedBox(height: 20),
                          _buildCaloriesInput(),
                          const SizedBox(height: 20),
                          _buildDietaryRestrictions(),
                          const SizedBox(height: 20),
                          _buildAvailableIngredients(),
                          const SizedBox(height: 24),
                          _buildGenerateButton(),
                          const SizedBox(height: 32),
                          _buildRecommendationSection(state),
                        ],
                      ),
                    );
                  },
                ),

                // Meal Plans Tab
                const MealPlanScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meal Type', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              _mealTypes.map((mealType) {
                return ChoiceChip(
                  label: Text(mealType),
                  selected: _selectedMealType == mealType,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMealType = mealType;
                        _updateCaloriesForMealType();
                      });
                    }
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color:
                        _selectedMealType == mealType
                            ? AppColors.primary
                            : AppColors.textSecondary,
                    fontWeight:
                        _selectedMealType == mealType
                            ? FontWeight.bold
                            : FontWeight.normal,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCaloriesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Target Calories', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: _caloriesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter target calories',
            suffixText: 'calories',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildDietaryRestrictions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Dietary Restrictions', style: AppTypography.titleMedium),
            TextButton(
              onPressed: () {
                setState(() {
                  _editingRestrictions = !_editingRestrictions;
                });
              },
              child: Text(_editingRestrictions ? 'Done' : 'Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_editingRestrictions)
          Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _commonRestrictions.map((restriction) {
                      return FilterChip(
                        label: Text(restriction),
                        selected: _selectedRestrictions.contains(restriction),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedRestrictions.add(restriction);
                            } else {
                              _selectedRestrictions.remove(restriction);
                            }
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.secondary.withOpacity(0.2),
                        checkmarkColor: AppColors.secondary,
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _restrictionController,
                      decoration: InputDecoration(
                        hintText: 'Add custom restriction',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onFieldSubmitted: (value) {
                        if (value.isNotEmpty &&
                            !_selectedRestrictions.contains(value)) {
                          setState(() {
                            _selectedRestrictions.add(value);
                          });
                          (context as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      // Get the text from the TextField directly
                      final controller = _restrictionController;
                      if (controller.text.isNotEmpty &&
                          !_selectedRestrictions.contains(controller.text)) {
                        setState(() {
                          _selectedRestrictions.add(controller.text);
                          controller.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _selectedRestrictions.isEmpty
                    ? [const Text('No restrictions set')]
                    : _selectedRestrictions.map((restriction) {
                      return Chip(
                        label: Text(restriction),
                        backgroundColor: AppColors.secondary.withOpacity(0.2),
                      );
                    }).toList(),
          ),
      ],
    );
  }

  Widget _buildAvailableIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Ingredients (Optional)',
              style: AppTypography.titleMedium,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _editingIngredients = !_editingIngredients;
                });
              },
              child: Text(_editingIngredients ? 'Done' : 'Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_editingIngredients)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientController,
                      decoration: InputDecoration(
                        hintText: 'Add ingredient (e.g., chicken, rice)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (_ingredientController.text.isNotEmpty) {
                        setState(() {
                          _availableIngredients.add(_ingredientController.text);
                          _ingredientController.clear();
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    color: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _availableIngredients.map((ingredient) {
                      return Chip(
                        label: Text(ingredient),
                        onDeleted: () {
                          setState(() {
                            _availableIngredients.remove(ingredient);
                          });
                        },
                        backgroundColor: AppColors.surface,
                      );
                    }).toList(),
              ),
            ],
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _availableIngredients.isEmpty
                    ? [
                      const Text(
                        'No ingredients specified (will use common ingredients)',
                      ),
                    ]
                    : _availableIngredients.map((ingredient) {
                      return Chip(
                        label: Text(ingredient),
                        backgroundColor: AppColors.surface,
                      );
                    }).toList(),
          ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return CustomButton(
      label: 'Generate Recipe',
      onPressed: () {
        // Validate calories
        if (_caloriesController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter target calories')),
          );
          return;
        }

        final double? calories = double.tryParse(_caloriesController.text);
        if (calories == null || calories <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter valid calories')),
          );
          return;
        }

        // Generate the meal recommendation
        context.read<AiBloc>().add(
          GetMealRecommendation(
            calories: calories,
            mealType: _selectedMealType,
            dietaryRestrictions: _selectedRestrictions,
            availableIngredients: _availableIngredients,
          ),
        );
      },
      icon: Icons.restaurant_menu,
    );
  }

  Widget _buildRecommendationSection(AiState state) {
    if (state is AiLoading) {
      return const Center(
        child: LoadingIndicator(message: 'Generating your recipe...'),
      );
    } else if (state is MealRecommendationLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Recipe', style: AppTypography.heading5),
          const SizedBox(height: 16),
          MarkdownViewer(markdown: state.recommendation),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Save Recipe',
                  onPressed: () {
                    // TODO: Save the recipe
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recipe saved successfully'),
                      ),
                    );
                  },
                  icon: Icons.bookmark,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomButton(
                  label: 'Add to Food Log',
                  onPressed: () {
                    // TODO: Navigate to add food log screen with this recipe
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to food log')),
                    );
                  },
                  icon: Icons.add_circle_outline,
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
            Text('Error generating recipe', style: AppTypography.titleMedium),
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
            Icon(Icons.dinner_dining, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Get personalized recipe ideas!',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Set your preferences above and click "Generate Recipe" to get a delicious recipe that fits your dietary needs.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
