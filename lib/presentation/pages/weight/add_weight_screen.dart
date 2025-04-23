import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../bloc/weight/weight_bloc.dart';
import '../../bloc/weight/weight_event.dart';
import '../../../presentation/bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_state.dart';
import '../../bloc/user/user_event.dart';
import '../../../data/models/weight_log_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_typography.dart';

class AddWeightScreen extends StatefulWidget {
  final WeightLogModel? existingWeight;

  const AddWeightScreen({super.key, this.existingWeight});

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _noteController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  double? _bmi;
  String? _bmiCategory;

  @override
  void initState() {
    super.initState();
    if (widget.existingWeight != null) {
      _weightController.text = widget.existingWeight!.weightInKg.toString();
      _heightController.text =
          widget.existingWeight!.heightInCm?.toString() ?? '';
      _noteController.text = widget.existingWeight!.note ?? '';
      _bodyFatController.text =
          widget.existingWeight!.bodyFatPercentage?.toString() ?? '';
      _muscleMassController.text =
          widget.existingWeight!.muscleMass?.toString() ?? '';
      _selectedDateTime = widget.existingWeight!.loggedAt;
      _updateBMI();
    }

    // Add listeners to update BMI when weight or height changes
    _weightController.addListener(_updateBMI);
    _heightController.addListener(_updateBMI);
  }

  void _updateBMI() {
    if (_weightController.text.isNotEmpty &&
        _heightController.text.isNotEmpty) {
      try {
        final weight = double.parse(_weightController.text);
        final height = double.parse(_heightController.text);
        if (weight > 0 && height > 0) {
          final heightInMeters = height / 100;
          final bmi = weight / (heightInMeters * heightInMeters);
          setState(() {
            _bmi = bmi;
            if (bmi < 18.5) {
              _bmiCategory = 'Underweight';
            } else if (bmi < 25) {
              _bmiCategory = 'Normal';
            } else if (bmi < 30) {
              _bmiCategory = 'Overweight';
            } else {
              _bmiCategory = 'Obese';
            }
          });
        } else {
          setState(() {
            _bmi = null;
            _bmiCategory = null;
          });
        }
      } catch (e) {
        setState(() {
          _bmi = null;
          _bmiCategory = null;
        });
      }
    } else {
      setState(() {
        _bmi = null;
        _bmiCategory = null;
      });
    }
  }

  @override
  void dispose() {
    _weightController.removeListener(_updateBMI);
    _heightController.removeListener(_updateBMI);
    _weightController.dispose();
    _heightController.dispose();
    _noteController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    super.dispose();
  }

  void _saveWeight() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final weight = double.parse(_weightController.text);
        final height =
            _heightController.text.isNotEmpty
                ? double.parse(_heightController.text)
                : null;
        final bodyFat =
            _bodyFatController.text.isNotEmpty
                ? double.parse(_bodyFatController.text)
                : null;
        final muscleMass =
            _muscleMassController.text.isNotEmpty
                ? double.parse(_muscleMassController.text)
                : null;

        final weightLog = WeightLogModel(
          id: widget.existingWeight?.id ?? const Uuid().v4(),
          userId: authState.user.id,
          weightInKg: weight,
          heightInCm: height,
          loggedAt: _selectedDateTime,
          note: _noteController.text.trim(),
          bodyFatPercentage: bodyFat,
          muscleMass: muscleMass,
          isSynced: false,
        );

        if (widget.existingWeight != null) {
          context.read<WeightBloc>().add(UpdateWeightLog(weightLog));
        } else {
          context.read<WeightBloc>().add(AddWeightLog(weightLog));
        }

        // Update user's current weight if needed
        final userState = context.read<UserBloc>().state;
        if (userState is UserLoaded) {
          final user = userState.user;
          if (user.currentWeight == null ||
              weightLog.loggedAt.isAfter(
                DateTime.now().subtract(const Duration(days: 1)),
              )) {
            // Update user's current weight with the latest weight
            context.read<UserBloc>().add(
              UserProfileUpdated(
                user.copyWith(currentWeight: weightLog.weightInKg),
              ),
            );
          }
        }

        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingWeight != null ? 'Edit Weight' : 'Add Weight',
        ),
        actions: [
          TextButton(onPressed: _saveWeight, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  suffixText: 'kg',
                  hintText: 'Enter your current weight',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null) {
                    return 'Please enter a valid number';
                  }
                  if (weight <= 0 || weight > 500) {
                    return 'Please enter a realistic weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  suffixText: 'cm',
                  hintText: 'Enter your height',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final height = double.tryParse(value);
                    if (height == null) {
                      return 'Please enter a valid number';
                    }
                    if (height <= 0 || height > 300) {
                      return 'Please enter a realistic height';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_bmi != null) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BMI Calculation',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your BMI',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  _bmi!.toStringAsFixed(1),
                                  style: AppTypography.headlineSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getBMIColor(_bmiCategory),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Category',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  _bmiCategory ?? 'Unknown',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _getBMIColor(_bmiCategory),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _getBMIProgressValue(_bmi!),
                          backgroundColor: AppColors.primaryColor.withAlpha(30),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getBMIColor(_bmiCategory),
                          ),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Underweight',
                              style: AppTypography.labelSmall,
                            ),
                            Text('Normal', style: AppTypography.labelSmall),
                            Text('Overweight', style: AppTypography.labelSmall),
                            Text('Obese', style: AppTypography.labelSmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ListTile(
                title: const Text('Date and Time'),
                subtitle: Text(_formatDateTime(_selectedDateTime)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDateTime,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'Add a note about this measurement',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Advanced Metrics (optional)',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bodyFatController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Body Fat Percentage',
                  suffixText: '%',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final bodyFat = double.tryParse(value);
                    if (bodyFat == null) {
                      return 'Please enter a valid number';
                    }
                    if (bodyFat < 0 || bodyFat > 100) {
                      return 'Please enter a percentage between 0 and 100';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _muscleMassController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Muscle Mass',
                  suffixText: 'kg',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final muscleMass = double.tryParse(value);
                    if (muscleMass == null) {
                      return 'Please enter a valid number';
                    }
                    if (muscleMass < 0 || muscleMass > 150) {
                      return 'Please enter a realistic muscle mass';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (widget.existingWeight?.photos != null &&
                  widget.existingWeight!.photos!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photos',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.existingWeight!.photos!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.existingWeight!.photos![index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ElevatedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Add Progress Photo'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
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

  Color _getBMIColor(String? category) {
    if (category == null) return AppColors.textSecondary;

    switch (category) {
      case 'Underweight':
        return Colors.blue;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  double _getBMIProgressValue(double bmi) {
    // Map BMI to a progress value between 0 and 1
    // Assuming BMI range from 15 to 40 for the progress bar
    if (bmi <= 15) return 0.0;
    if (bmi >= 40) return 1.0;

    // Calculate position on the scale
    // 15-18.5 (Underweight): 0-0.25
    // 18.5-25 (Normal): 0.25-0.5
    // 25-30 (Overweight): 0.5-0.75
    // 30-40 (Obese): 0.75-1.0

    if (bmi < 18.5) {
      return 0.25 * ((bmi - 15) / (18.5 - 15));
    } else if (bmi < 25) {
      return 0.25 + 0.25 * ((bmi - 18.5) / (25 - 18.5));
    } else if (bmi < 30) {
      return 0.5 + 0.25 * ((bmi - 25) / (30 - 25));
    } else {
      return 0.75 + 0.25 * ((bmi - 30) / (40 - 30));
    }
  }

  void _addPhoto() {
    // TODO: Implement photo picker and upload
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
}
