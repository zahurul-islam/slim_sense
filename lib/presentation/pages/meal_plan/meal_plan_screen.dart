import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/recipe_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import 'recipe_detail_screen.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDietType = 'All';
  
  final List<String> _dietTypes = [
    'All',
    'Weight Loss',
    'Keto',
    'Vegan',
    'Vegetarian',
    'Paleo',
    'Low Carb',
  ];
  
  // Sample recipes for demonstration
  final List<RecipeModel> _recipes = [
    // Breakfast recipes
    RecipeModel(
      id: '1',
      title: 'Greek Yogurt Parfait',
      description: 'A protein-packed breakfast parfait with Greek yogurt, berries, and granola.',
      ingredients: [
        '1 cup Greek yogurt',
        '1/2 cup mixed berries',
        '1/4 cup low-sugar granola',
        '1 tbsp honey',
        '1 tbsp chia seeds',
      ],
      instructions: [
        'Layer half of the yogurt in a glass or bowl.',
        'Add half of the berries and granola.',
        'Repeat with remaining yogurt, berries, and granola.',
        'Drizzle with honey and sprinkle with chia seeds.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 5,
      cookTimeMinutes: 0,
      servings: 1,
      calories: 320,
      protein: 22,
      carbs: 40,
      fat: 8,
      tags: ['quick', 'protein', 'breakfast'],
      mealType: 'breakfast',
      dietType: 'Weight Loss',
    ),
    RecipeModel(
      id: '2',
      title: 'Avocado Toast with Egg',
      description: 'Whole grain toast topped with avocado and a perfectly poached egg.',
      ingredients: [
        '1 slice whole grain bread',
        '1/2 avocado',
        '1 egg',
        'Salt and pepper to taste',
        'Red pepper flakes (optional)',
      ],
      instructions: [
        'Toast the bread until golden brown.',
        'Mash the avocado and spread on toast.',
        'Poach or fry the egg to your liking.',
        'Place egg on top of avocado.',
        'Season with salt, pepper, and red pepper flakes if desired.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 5,
      cookTimeMinutes: 5,
      servings: 1,
      calories: 280,
      protein: 12,
      carbs: 20,
      fat: 18,
      tags: ['quick', 'breakfast', 'healthy fats'],
      mealType: 'breakfast',
      dietType: 'Weight Loss',
    ),
    RecipeModel(
      id: '3',
      title: 'Keto Breakfast Bowl',
      description: 'A low-carb breakfast bowl with eggs, avocado, and bacon.',
      ingredients: [
        '2 eggs',
        '2 slices bacon',
        '1/2 avocado',
        '1/4 cup spinach',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Cook bacon until crispy, then crumble.',
        'Scramble eggs in the bacon fat.',
        'Place eggs in a bowl and top with bacon, sliced avocado, and spinach.',
        'Season with salt and pepper.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1529564879024-c54e7c2dd0e5?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 5,
      cookTimeMinutes: 10,
      servings: 1,
      calories: 420,
      protein: 22,
      carbs: 5,
      fat: 35,
      tags: ['keto', 'low-carb', 'breakfast'],
      mealType: 'breakfast',
      dietType: 'Keto',
    ),
    
    // Lunch recipes
    RecipeModel(
      id: '4',
      title: 'Mediterranean Salad',
      description: 'A refreshing salad with cucumbers, tomatoes, olives, and feta cheese.',
      ingredients: [
        '2 cups mixed greens',
        '1/2 cucumber, diced',
        '1 tomato, diced',
        '1/4 cup Kalamata olives',
        '1/4 cup feta cheese',
        '2 tbsp olive oil',
        '1 tbsp lemon juice',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Combine all vegetables in a large bowl.',
        'Crumble feta cheese over the top.',
        'Whisk together olive oil, lemon juice, salt, and pepper.',
        'Drizzle dressing over salad and toss to combine.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 10,
      cookTimeMinutes: 0,
      servings: 1,
      calories: 320,
      protein: 8,
      carbs: 12,
      fat: 28,
      tags: ['salad', 'lunch', 'mediterranean'],
      mealType: 'lunch',
      dietType: 'Weight Loss',
    ),
    RecipeModel(
      id: '5',
      title: 'Chicken and Quinoa Bowl',
      description: 'A protein-packed bowl with grilled chicken, quinoa, and roasted vegetables.',
      ingredients: [
        '4 oz grilled chicken breast',
        '1/2 cup cooked quinoa',
        '1 cup roasted vegetables (bell peppers, zucchini, onions)',
        '1 tbsp olive oil',
        '1 tsp Italian seasoning',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Cook quinoa according to package instructions.',
        'Season chicken with Italian seasoning, salt, and pepper.',
        'Grill chicken until cooked through.',
        'Toss vegetables in olive oil and roast at 400°F for 20 minutes.',
        'Combine quinoa, chicken, and vegetables in a bowl.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1546793665-c74683f339c1?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 10,
      cookTimeMinutes: 25,
      servings: 1,
      calories: 420,
      protein: 35,
      carbs: 30,
      fat: 15,
      tags: ['protein', 'lunch', 'meal prep'],
      mealType: 'lunch',
      dietType: 'Weight Loss',
    ),
    RecipeModel(
      id: '6',
      title: 'Vegan Buddha Bowl',
      description: 'A colorful bowl filled with plant-based goodness.',
      ingredients: [
        '1/2 cup cooked brown rice',
        '1/2 cup roasted sweet potatoes',
        '1/2 cup chickpeas',
        '1 cup mixed greens',
        '1/4 avocado, sliced',
        '2 tbsp tahini dressing',
      ],
      instructions: [
        'Cook brown rice according to package instructions.',
        'Roast sweet potatoes at 400°F for 25 minutes.',
        'Rinse and drain chickpeas.',
        'Arrange rice, sweet potatoes, chickpeas, and greens in a bowl.',
        'Top with avocado and drizzle with tahini dressing.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 15,
      cookTimeMinutes: 30,
      servings: 1,
      calories: 450,
      protein: 12,
      carbs: 65,
      fat: 18,
      tags: ['vegan', 'lunch', 'plant-based'],
      mealType: 'lunch',
      dietType: 'Vegan',
    ),
    
    // Dinner recipes
    RecipeModel(
      id: '7',
      title: 'Baked Salmon with Asparagus',
      description: 'Oven-baked salmon fillet with roasted asparagus and lemon.',
      ingredients: [
        '6 oz salmon fillet',
        '1 bunch asparagus',
        '1 lemon',
        '1 tbsp olive oil',
        '2 cloves garlic, minced',
        'Salt and pepper to taste',
        'Fresh dill (optional)',
      ],
      instructions: [
        'Preheat oven to 400°F.',
        'Place salmon and asparagus on a baking sheet.',
        'Drizzle with olive oil and sprinkle with garlic, salt, and pepper.',
        'Slice half the lemon and place on top of salmon.',
        'Squeeze the other half over asparagus.',
        'Bake for 12-15 minutes until salmon is cooked through.',
        'Garnish with fresh dill if desired.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 10,
      cookTimeMinutes: 15,
      servings: 1,
      calories: 380,
      protein: 34,
      carbs: 10,
      fat: 22,
      tags: ['seafood', 'dinner', 'omega-3'],
      mealType: 'dinner',
      dietType: 'Weight Loss',
    ),
    RecipeModel(
      id: '8',
      title: 'Turkey Meatballs with Zucchini Noodles',
      description: 'Lean turkey meatballs served over zucchini noodles with marinara sauce.',
      ingredients: [
        '4 oz ground turkey',
        '1/4 cup breadcrumbs',
        '1 egg',
        '1 tsp Italian seasoning',
        '2 zucchinis, spiralized',
        '1/2 cup marinara sauce',
        '1 tbsp grated Parmesan cheese',
      ],
      instructions: [
        'Mix ground turkey, breadcrumbs, egg, and Italian seasoning.',
        'Form into 1-inch meatballs.',
        'Bake at 375°F for 15-20 minutes until cooked through.',
        'Spiralize zucchini into noodles.',
        'Sauté zucchini noodles for 2-3 minutes until slightly tender.',
        'Heat marinara sauce and add meatballs.',
        'Serve sauce and meatballs over zucchini noodles.',
        'Top with Parmesan cheese.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1529042410759-befb1204b468?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 15,
      cookTimeMinutes: 20,
      servings: 1,
      calories: 350,
      protein: 30,
      carbs: 20,
      fat: 15,
      tags: ['low-carb', 'dinner', 'protein'],
      mealType: 'dinner',
      dietType: 'Weight Loss',
    ),
    RecipeModel(
      id: '9',
      title: 'Vegetarian Chili',
      description: 'Hearty vegetarian chili packed with beans and vegetables.',
      ingredients: [
        '1 can black beans, drained and rinsed',
        '1 can kidney beans, drained and rinsed',
        '1 onion, diced',
        '1 bell pepper, diced',
        '2 cloves garlic, minced',
        '1 can diced tomatoes',
        '2 tbsp chili powder',
        '1 tsp cumin',
        '1/2 tsp paprika',
        'Salt and pepper to taste',
      ],
      instructions: [
        'Sauté onion, bell pepper, and garlic until soft.',
        'Add beans, tomatoes, and spices.',
        'Simmer for 20-30 minutes.',
        'Serve with optional toppings like avocado, Greek yogurt, or cheese.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 10,
      cookTimeMinutes: 30,
      servings: 4,
      calories: 280,
      protein: 15,
      carbs: 45,
      fat: 5,
      tags: ['vegetarian', 'dinner', 'meal prep'],
      mealType: 'dinner',
      dietType: 'Vegetarian',
    ),
    
    // Snack recipes
    RecipeModel(
      id: '10',
      title: 'Apple with Almond Butter',
      description: 'A simple, satisfying snack with the perfect balance of carbs and healthy fats.',
      ingredients: [
        '1 medium apple',
        '1 tbsp almond butter',
        'Cinnamon (optional)',
      ],
      instructions: [
        'Slice the apple into wedges.',
        'Serve with almond butter for dipping.',
        'Sprinkle with cinnamon if desired.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 2,
      cookTimeMinutes: 0,
      servings: 1,
      calories: 170,
      protein: 4,
      carbs: 25,
      fat: 8,
      tags: ['quick', 'snack', 'fruit'],
      mealType: 'snack',
      dietType: 'Weight Loss',
    ),
    RecipeModel(
      id: '11',
      title: 'Protein Energy Balls',
      description: 'No-bake energy balls perfect for a pre-workout snack or afternoon pick-me-up.',
      ingredients: [
        '1 cup rolled oats',
        '1/2 cup peanut butter',
        '1/3 cup honey',
        '1/4 cup protein powder',
        '1/4 cup mini chocolate chips',
        '1 tsp vanilla extract',
      ],
      instructions: [
        'Mix all ingredients in a large bowl until well combined.',
        'Roll into 1-inch balls.',
        'Refrigerate for at least 30 minutes before serving.',
        'Store in an airtight container in the refrigerator.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1604497181015-76590d828b75?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 15,
      cookTimeMinutes: 0,
      servings: 12,
      calories: 120,
      protein: 5,
      carbs: 15,
      fat: 6,
      tags: ['no-bake', 'snack', 'protein'],
      mealType: 'snack',
      dietType: 'Weight Loss',
    ),
    RecipeModel(
      id: '12',
      title: 'Keto Fat Bombs',
      description: 'High-fat, low-carb snack perfect for those following a ketogenic diet.',
      ingredients: [
        '1/2 cup coconut oil',
        '1/2 cup almond butter',
        '1/4 cup cocoa powder',
        '2 tbsp erythritol or stevia',
        '1 tsp vanilla extract',
        'Pinch of salt',
      ],
      instructions: [
        'Melt coconut oil and almond butter together.',
        'Stir in cocoa powder, sweetener, vanilla, and salt.',
        'Pour into silicone molds or a lined mini muffin tin.',
        'Freeze for 30 minutes until solid.',
        'Store in the refrigerator or freezer.',
      ],
      imageUrl: 'https://images.unsplash.com/photo-1582284540020-8acbe03f4924?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      prepTimeMinutes: 10,
      cookTimeMinutes: 0,
      servings: 12,
      calories: 150,
      protein: 3,
      carbs: 2,
      fat: 15,
      tags: ['keto', 'snack', 'low-carb'],
      mealType: 'snack',
      dietType: 'Keto',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<RecipeModel> _getFilteredRecipes(String mealType) {
    if (_selectedDietType == 'All') {
      return _recipes.where((recipe) => recipe.mealType == mealType.toLowerCase()).toList();
    } else {
      return _recipes.where((recipe) => 
        recipe.mealType == mealType.toLowerCase() && 
        recipe.dietType == _selectedDietType
      ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDietTypeSelector(),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryColor,
            tabs: const [
              Tab(text: 'Breakfast'),
              Tab(text: 'Lunch'),
              Tab(text: 'Dinner'),
              Tab(text: 'Snacks'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecipeGrid(_getFilteredRecipes('breakfast')),
                _buildRecipeGrid(_getFilteredRecipes('lunch')),
                _buildRecipeGrid(_getFilteredRecipes('dinner')),
                _buildRecipeGrid(_getFilteredRecipes('snack')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietTypeSelector() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _dietTypes.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final dietType = _dietTypes[index];
          final isSelected = dietType == _selectedDietType;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(dietType),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDietType = dietType;
                  });
                }
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primaryColor.withAlpha(50),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryColor : AppColors.borderColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeGrid(List<RecipeModel> recipes) {
    if (recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.textSecondary.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text(
              'No recipes found',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different diet type',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return _buildRecipeCard(recipe);
      },
    );
  }

  Widget _buildRecipeCard(RecipeModel recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                recipe.imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: AppColors.primaryColor.withAlpha(50),
                    child: const Center(
                      child: Icon(Icons.image_not_supported, color: AppColors.primaryColor),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    recipe.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: AppColors.chartOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.calories.toInt()} cal',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.prepTimeMinutes + recipe.cookTimeMinutes} min',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
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
  }
}
