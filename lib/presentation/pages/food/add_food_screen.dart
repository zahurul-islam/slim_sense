import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/food_log_model.dart';
import '../../bloc/food/food_bloc.dart';
import '../../bloc/food/food_event.dart';
import '../../bloc/food/food_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';

class AddFoodScreen extends StatefulWidget {
  final FoodLogModel? existingFood;
  final String? initialMealType;

  const AddFoodScreen({super.key, this.existingFood, this.initialMealType});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _servingUnitController = TextEditingController();

  late String _selectedMealType;
  DateTime _selectedDateTime = DateTime.now();
  File? _foodImage;
  bool _isProcessingImage = false;
  String? _recognizedFood;
  Map<String, dynamic>? _nutritionInfo;
  bool _isFavorite = false;

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  void initState() {
    super.initState();

    // Initialize meal type from parameters or default to breakfast
    _selectedMealType = widget.initialMealType ?? 'breakfast';

    if (widget.existingFood != null) {
      _foodNameController.text = widget.existingFood!.foodName;
      _caloriesController.text = widget.existingFood!.calories.toString();
      _proteinController.text = widget.existingFood!.protein.toString();
      _carbsController.text = widget.existingFood!.carbs.toString();
      _fatController.text = widget.existingFood!.fat.toString();
      _fiberController.text = widget.existingFood!.fiber?.toString() ?? '';
      _servingSizeController.text =
          widget.existingFood!.servingSize?.toString() ?? '';
      _servingUnitController.text = widget.existingFood!.servingUnit ?? '';
      _selectedMealType = widget.existingFood!.mealType;
      _selectedDateTime = widget.existingFood!.loggedAt;
      _isFavorite = widget.existingFood!.isFavorite;
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _servingSizeController.dispose();
    _servingUnitController.dispose();
    super.dispose();
  }

  void _saveFood() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final foodLog = FoodLogModel(
          id: widget.existingFood?.id ?? const Uuid().v4(),
          userId: authState.user.id,
          foodName: _foodNameController.text.trim(),
          calories: double.parse(_caloriesController.text),
          protein: double.parse(_proteinController.text),
          carbs: double.parse(_carbsController.text),
          fat: double.parse(_fatController.text),
          mealType: _selectedMealType,
          loggedAt: _selectedDateTime,
          fiber:
              _fiberController.text.isNotEmpty
                  ? double.parse(_fiberController.text)
                  : null,
          photoUrl: widget.existingFood?.photoUrl,
          servingSize:
              _servingSizeController.text.isNotEmpty
                  ? double.parse(_servingSizeController.text)
                  : null,
          servingUnit:
              _servingUnitController.text.isNotEmpty
                  ? _servingUnitController.text
                  : null,
          isFavorite: _isFavorite,
        );

        if (widget.existingFood != null) {
          context.read<FoodBloc>().add(FoodLogUpdated(foodLog));
        } else {
          context.read<FoodBloc>().add(FoodLogAdded(foodLog));
        }

        Navigator.pop(context);
      }
    }
  }

  Future<void> _takeFoodPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _foodImage = File(image.path);
        _isProcessingImage = true;
      });

      // Simulate food recognition and nutrition info retrieval
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would send the image to a food recognition API
      // and get back nutrition information
      setState(() {
        _isProcessingImage = false;
        _recognizedFood = 'Apple';
        _nutritionInfo = {
          'calories': 95.0,
          'protein': 0.5,
          'carbs': 25.0,
          'fat': 0.3,
          'fiber': 4.0,
          'serving_size': 1.0,
          'serving_unit': 'medium apple',
        };

        // Auto-fill the form with the recognized food info
        _foodNameController.text = _recognizedFood!;
        _caloriesController.text = _nutritionInfo!['calories'].toString();
        _proteinController.text = _nutritionInfo!['protein'].toString();
        _carbsController.text = _nutritionInfo!['carbs'].toString();
        _fatController.text = _nutritionInfo!['fat'].toString();
        _fiberController.text = _nutritionInfo!['fiber'].toString();
        _servingSizeController.text =
            _nutritionInfo!['serving_size'].toString();
        _servingUnitController.text = _nutritionInfo!['serving_unit'];
      });
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return 'Yesterday at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingFood != null ? 'Edit Food' : 'Add Food'),
        actions: [TextButton(onPressed: _saveFood, child: const Text('Save'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_foodImage != null) ...[
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _foodImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_isProcessingImage)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Analyzing food image...'),
                      ],
                    ),
                  ),
                if (_recognizedFood != null && !_isProcessingImage)
                  Center(
                    child: Chip(
                      label: Text('Recognized: $_recognizedFood'),
                      backgroundColor: AppColors.primaryColor.withAlpha(50),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _takeFoodPhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement food search
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Food search not implemented yet'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search),
                      label: const Text('Search Food'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Food Details',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(
                  labelText: 'Food Name',
                  hintText: 'Enter food name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _servingSizeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Serving Size',
                        hintText: 'e.g., 1, 0.5',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _servingUnitController,
                      decoration: const InputDecoration(
                        labelText: 'Serving Unit',
                        hintText: 'e.g., cup, piece',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMealType,
                decoration: const InputDecoration(labelText: 'Meal Type'),
                items:
                    _mealTypes.map((mealType) {
                      return DropdownMenuItem(
                        value: mealType,
                        child: Text(
                          mealType[0].toUpperCase() + mealType.substring(1),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMealType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date and Time'),
                subtitle: Text(_formatDateTime(_selectedDateTime)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDateTime,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              Text(
                'Nutrition Information',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  suffixText: 'kcal',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  final calories = double.tryParse(value);
                  if (calories == null) {
                    return 'Please enter a valid number';
                  }
                  if (calories < 0) {
                    return 'Calories cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Protein',
                        suffixText: 'g',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final protein = double.tryParse(value);
                        if (protein == null) {
                          return 'Invalid';
                        }
                        if (protein < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Carbs',
                        suffixText: 'g',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final carbs = double.tryParse(value);
                        if (carbs == null) {
                          return 'Invalid';
                        }
                        if (carbs < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Fat',
                        suffixText: 'g',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final fat = double.tryParse(value);
                        if (fat == null) {
                          return 'Invalid';
                        }
                        if (fat < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _fiberController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Fiber',
                        suffixText: 'g',
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final fiber = double.tryParse(value);
                          if (fiber == null) {
                            return 'Invalid';
                          }
                          if (fiber < 0) {
                            return 'Invalid';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Add to Favorites'),
                value: _isFavorite,
                onChanged: (value) {
                  setState(() {
                    _isFavorite = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
