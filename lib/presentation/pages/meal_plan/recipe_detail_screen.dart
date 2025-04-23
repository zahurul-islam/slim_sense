import 'package:flutter/material.dart';
import '../../../data/models/recipe_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecipeInfo(),
                  const SizedBox(height: 24),
                  _buildNutritionInfo(),
                  const SizedBox(height: 24),
                  _buildIngredients(),
                  const SizedBox(height: 24),
                  _buildInstructions(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add recipe to meal plan or food log
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe added to your food log'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add to Food Log'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          recipe.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primaryColor.withAlpha(50),
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 64, color: AppColors.primaryColor),
              ),
            );
          },
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border),
          onPressed: () {
            // TODO: Add to favorites
          },
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Share recipe
          },
        ),
      ],
    );
  }

  Widget _buildRecipeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.title,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          recipe.description,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildInfoChip(Icons.access_time, '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min'),
            const SizedBox(width: 12),
            _buildInfoChip(Icons.restaurant, '${recipe.servings} servings'),
            const SizedBox(width: 12),
            _buildInfoChip(Icons.local_fire_department, '${recipe.calories.toInt()} cal'),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTagChip(recipe.dietType),
            _buildTagChip(recipe.mealType.capitalize()),
            ...recipe.tags.map((tag) => _buildTagChip(tag.capitalize())).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      backgroundColor: Colors.grey.shade200,
      labelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.textPrimaryColor,
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildNutritionInfo() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Information',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientInfo('Calories', '${recipe.calories.toInt()}', 'kcal', AppColors.chartOrange),
                _buildNutrientInfo('Protein', '${recipe.protein.toInt()}', 'g', AppColors.chartBlue),
                _buildNutrientInfo('Carbs', '${recipe.carbs.toInt()}', 'g', AppColors.chartGreen),
                _buildNutrientInfo('Fat', '${recipe.fat.toInt()}', 'g', AppColors.chartYellow),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
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
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredients() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ...recipe.ingredients.map((ingredient) => _buildIngredientItem(ingredient)).toList(),
      ],
    );
  }

  Widget _buildIngredientItem(String ingredient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructions',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ...recipe.instructions.asMap().entries.map(
              (entry) => _buildInstructionStep(entry.key + 1, entry.value),
            ).toList(),
      ],
    );
  }

  Widget _buildInstructionStep(int stepNumber, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber.toString(),
                style: AppTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
