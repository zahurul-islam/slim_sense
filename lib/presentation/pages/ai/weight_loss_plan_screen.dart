import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/ai/ai_bloc.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/information_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/markdown_viewer.dart';
import '../../../data/models/user_model.dart';

class WeightLossPlanScreen extends StatefulWidget {
  final UserModel user;

  const WeightLossPlanScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<WeightLossPlanScreen> createState() => _WeightLossPlanScreenState();
}

class _WeightLossPlanScreenState extends State<WeightLossPlanScreen> {
  final TextEditingController _targetWeightController = TextEditingController();
  final TextEditingController _preferenceController = TextEditingController();
  List<String> _selectedPreferences = [];
  bool _editingPreferences = false;

  @override
  void initState() {
    super.initState();
    _targetWeightController.text = widget.user.targetWeight?.toString() ?? '';
    _selectedPreferences = List.from(widget.user.dietaryPreferences ?? []);
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    _preferenceController.dispose();
    super.dispose();
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
              _buildCurrentStats(),
              const SizedBox(height: 24),
              _buildTargetWeightInput(),
              const SizedBox(height: 16),
              _buildDietaryPreferences(),
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

  Widget _buildCurrentStats() {
    return InformationCard(
      title: 'Current Stats',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatRow(
            'Current Weight',
            '${widget.user.currentWeight?.toStringAsFixed(1) ?? "N/A"} kg',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Height',
            '${widget.user.height_cm?.toStringAsFixed(1) ?? "N/A"} cm',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'BMI',
            '${widget.user.bmi?.toStringAsFixed(1) ?? "N/A"} (${widget.user.bmiCategory ?? "Unknown"})',
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            'Activity Level',
            widget.user.activityLevel ?? 'Unknown',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
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

  Widget _buildDietaryPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Dietary Preferences', style: AppTypography.titleMedium),
            TextButton(
              onPressed: () {
                setState(() {
                  _editingPreferences = !_editingPreferences;
                });
              },
              child: Text(_editingPreferences ? 'Done' : 'Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_editingPreferences)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _preferenceController,
                      decoration: InputDecoration(
                        hintText: 'Add preference (e.g., vegetarian)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (_preferenceController.text.isNotEmpty) {
                        setState(() {
                          _selectedPreferences.add(_preferenceController.text);
                          _preferenceController.clear();
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
                    _selectedPreferences.map((preference) {
                      return Chip(
                        label: Text(preference),
                        onDeleted: () {
                          setState(() {
                            _selectedPreferences.remove(preference);
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
                _selectedPreferences.isEmpty
                    ? [const Text('No preferences set')]
                    : _selectedPreferences.map((preference) {
                      return Chip(
                        label: Text(preference),
                        backgroundColor: AppColors.surface,
                      );
                    }).toList(),
          ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return CustomButton(
      label: 'Generate Weight Loss Plan',
      onPressed: () {
        // Validate target weight
        if (_targetWeightController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a target weight')),
          );
          return;
        }

        final double? targetWeight = double.tryParse(
          _targetWeightController.text,
        );
        if (targetWeight == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid target weight')),
          );
          return;
        }

        // Generate the weight loss plan
        context.read<AiBloc>().add(
          GetWeightLossRecommendation(
            currentWeight: widget.user.currentWeight ?? 0,
            targetWeight: targetWeight,
            gender: widget.user.gender ?? 'Unknown',
            age: widget.user.age ?? 30,
            activityLevel: widget.user.activityLevel ?? 'Moderate',
            dietaryPreferences: _selectedPreferences,
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
          message: 'Generating your personalized weight loss plan...',
        ),
      );
    } else if (state is WeightLossRecommendationLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Personalized Weight Loss Plan',
            style: AppTypography.heading5,
          ),
          const SizedBox(height: 16),
          MarkdownViewer(markdown: state.recommendation),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Save Plan',
            onPressed: () {
              // TODO: Save the weight loss plan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Plan saved successfully')),
              );
            },
            icon: Icons.save,
            color: AppColors.success,
          ),
        ],
      );
    } else if (state is AiError) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error generating weight loss plan',
              style: AppTypography.titleMedium,
            ),
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
            Icon(Icons.tips_and_updates, color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text(
              'Get your personalized weight loss plan!',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in your details above and click "Generate Weight Loss Plan" to receive personalized recommendations for your weight loss journey.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
