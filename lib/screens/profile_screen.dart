import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_time_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        final profile = provider.profile;

        return SafeArea(
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 4,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Premium Avatar & Info Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar with glowing ring
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surface,
                            ),
                            child: Center(
                              child: Text(
                                profile.name.isNotEmpty
                                    ? profile.name[0].toUpperCase()
                                    : 'H',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Name & Goal Badge
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name.isNotEmpty ? profile.name : 'Hydrator',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            // Daily Goal Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.waterBlue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(100), // Fully rounded like pill
                                border: Border.all(
                                  color: AppColors.waterBlue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.water_drop,
                                    size: 14,
                                    color: AppColors.waterBlue,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Daily Goal: ${provider.formatAmount(provider.dailyGoalMl)}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.waterBlue,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Recalculate suggestion
                GestureDetector(
                  onTap: () => _showRecalculated(context, provider),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_fix_high,
                            color: AppColors.secondary, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Recalculate Recommended Goal',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Personal Info Section
                _SectionHeader(title: 'Personal Information'),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: profile.name.isEmpty ? 'Not set' : profile.name,
                  onTap: () => _editName(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.cake_outlined,
                  label: 'Age',
                  value: '${profile.age} years',
                  onTap: () => _editAge(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.wc_outlined,
                  label: 'Gender',
                  value: _getGenderText(profile.gender),
                  onTap: () => _editGender(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.height,
                  label: 'Height',
                  value: UnitConverter.formatHeight(
                      profile.heightCm, profile.heightUnit),
                  onTap: () => _editHeight(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: UnitConverter.formatWeight(
                      profile.weightKg, profile.weightUnit),
                  onTap: () => _editWeight(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Wake Up Time',
                  value: _formatTime(profile.wakeTime),
                  onTap: () => _editTime(context, provider, true),
                ),
                _SettingsTile(
                  icon: Icons.nightlight_round_outlined,
                  label: 'Sleep Time',
                  value: _formatTime(profile.sleepTime),
                  onTap: () => _editTime(context, provider, false),
                ),

                const SizedBox(height: 24),
                
                // Additional Information Section
                _SectionHeader(title: 'Additional Information'),
                const SizedBox(height: 12),
                
                _SettingsTile(
                  icon: Icons.directions_run_outlined,
                  label: 'Activity Level',
                  value: _getActivityLevelText(profile.activityLevel),
                  onTap: () => _editActivityLevel(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.thermostat_outlined,
                  label: 'Climate',
                  value: _getClimateText(profile.climate),
                  onTap: () => _editClimate(context, provider),
                ),

                const SizedBox(height: 24),

                // Preferences Section
                _SectionHeader(title: 'Preferences'),
                const SizedBox(height: 12),

                _SettingsTile(
                  icon: Icons.science_outlined,
                  label: 'Liquid Unit',
                  value: profile.unit == MeasureUnit.ml
                      ? 'Milliliters (ml)'
                      : 'Ounces (oz)',
                  onTap: () => _toggleUnit(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.scale_outlined,
                  label: 'Weight Unit',
                  value: profile.weightUnit == WeightUnit.kg
                      ? 'Kilograms (kg)'
                      : 'Pounds (lbs)',
                  onTap: () => _toggleWeightUnit(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.straighten,
                  label: 'Height Unit',
                  value: profile.heightUnit == HeightUnit.cm
                      ? 'Centimeters (cm)'
                      : 'Feet/Inches (ft)',
                  onTap: () => _toggleHeightUnit(context, provider),
                ),
                _SettingsTile(
                  icon: Icons.flag_outlined,
                  label: 'Daily Goal',
                  value: provider.formatAmount(provider.dailyGoalMl),
                  onTap: () => _editGoal(context, provider),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  void _editName(BuildContext context, WaterProvider provider) {
    final controller = TextEditingController(text: provider.profile.name);
    _showEditDialog(
      context: context,
      title: 'Edit Name',
      child: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
        decoration: _inputDecoration('Your name'),
      ),
      onSave: () {
        final name = controller.text.trim();
        if (name.isNotEmpty) {
          provider.updateProfile(provider.profile.copyWith(name: name));
        }
        Navigator.pop(context);
      },
    );
  }

  String _getGenderText(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Prefer not to say';
    }
  }

  void _editGender(BuildContext context, WaterProvider provider) {
    HapticFeedback.lightImpact();
    _showSelectionDialog<Gender>(
      context: context,
      title: 'Select Gender',
      items: [
        const SelectionItem(Gender.male, 'Male'),
        const SelectionItem(Gender.female, 'Female'),
        const SelectionItem(Gender.other, 'Prefer not to say'),
      ],
      currentValue: provider.profile.gender,
      onSelect: (value) {
        provider.updateProfile(provider.profile.copyWith(gender: value));
      },
    );
  }

  String _getActivityLevelText(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.low:
        return 'Low Activity';
      case ActivityLevel.moderate:
        return 'Moderate Activity';
      case ActivityLevel.high:
        return 'High Activity';
      case ActivityLevel.athlete:
        return 'Athlete';
    }
  }

  void _editActivityLevel(BuildContext context, WaterProvider provider) {
    HapticFeedback.lightImpact();
    _showSelectionDialog<ActivityLevel>(
      context: context,
      title: 'Select Activity Level',
      items: [
        const SelectionItem(ActivityLevel.low, 'Low Activity', 'Sedentary lifestyle, mainly sitting'),
        const SelectionItem(ActivityLevel.moderate, 'Moderate Activity', 'Light daily movement or casual exercise'),
        const SelectionItem(ActivityLevel.high, 'High Activity', 'Regular intense workouts or active job'),
        const SelectionItem(ActivityLevel.athlete, 'Athlete', 'Extreme physical training or sports'),
      ],
      currentValue: provider.profile.activityLevel,
      onSelect: (value) {
        provider.updateProfile(provider.profile.copyWith(activityLevel: value));
      },
    );
  }

  String _getClimateText(Climate climate) {
    switch (climate) {
      case Climate.cool:
        return 'Cool';
      case Climate.moderate:
        return 'Moderate';
      case Climate.hot:
        return 'Hot';
    }
  }

  void _editClimate(BuildContext context, WaterProvider provider) {
    HapticFeedback.lightImpact();
    _showSelectionDialog<Climate>(
      context: context,
      title: 'Select Climate',
      items: [
        const SelectionItem(Climate.cool, 'Cool', 'Cold outside, or mostly air-conditioned'),
        const SelectionItem(Climate.moderate, 'Moderate', 'Mild, average comfortable temperatures'),
        const SelectionItem(Climate.hot, 'Hot', 'High temperatures, humid, or sunny'),
      ],
      currentValue: provider.profile.climate,
      onSelect: (value) {
        provider.updateProfile(provider.profile.copyWith(climate: value));
      },
    );
  }

  void _showSelectionDialog<T>({
    required BuildContext context,
    required String title,
    required List<SelectionItem<T>> items,
    required T currentValue,
    required ValueChanged<T> onSelect,
  }) {
    showDialog(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.8),
      builder: (ctx) {
        T tempValue = currentValue;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...items.map((item) {
                      final isSelected = item.value == tempValue;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setDialogState(() => tempValue = item.value);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primary.withValues(alpha: 0.1) 
                                : AppColors.surfaceLight.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.primary 
                                  : AppColors.primary.withValues(alpha: 0.1),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                    ),
                                    if (item.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description!,
                                        style: TextStyle(
                                          color: isSelected 
                                              ? AppColors.primary.withValues(alpha: 0.8) 
                                              : AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            onSelect(tempValue);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editAge(BuildContext context, WaterProvider provider) {
    final controller =
        TextEditingController(text: provider.profile.age.toString());
    _showEditDialog(
      context: context,
      title: 'Edit Age',
      child: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
        decoration: _inputDecoration('Age in years'),
      ),
      onSave: () {
        final age = int.tryParse(controller.text);
        if (age != null && age > 0 && age <= 120) {
          provider.updateProfile(provider.profile.copyWith(age: age));
        }
        Navigator.pop(context);
      },
    );
  }

  void _editHeight(BuildContext context, WaterProvider provider) {
    final bool isCm = provider.profile.heightUnit == HeightUnit.cm;
    final double initialVal = isCm
        ? provider.profile.heightCm
        : UnitConverter.cmToInches(provider.profile.heightCm);

    final controller = TextEditingController(text: initialVal.round().toString());
    _showEditDialog(
      context: context,
      title: 'Edit Height',
      child: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
        decoration: _inputDecoration(isCm ? 'Height in cm' : 'Height in total inches'),
      ),
      onSave: () {
        final val = double.tryParse(controller.text);
        if (val != null && val > 0) {
          final newCm = isCm ? val : UnitConverter.inchesToCm(val);
          provider.updateProfile(provider.profile.copyWith(heightCm: newCm));
        }
        Navigator.pop(context);
      },
    );
  }

  void _editWeight(BuildContext context, WaterProvider provider) {
    final bool isKg = provider.profile.weightUnit == WeightUnit.kg;
    final double initialVal = isKg
        ? provider.profile.weightKg
        : UnitConverter.kgToLbs(provider.profile.weightKg);

    final controller = TextEditingController(text: initialVal.round().toString());
    _showEditDialog(
      context: context,
      title: 'Edit Weight',
      child: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
        decoration: _inputDecoration(isKg ? 'Weight in kg' : 'Weight in lbs'),
      ),
      onSave: () {
        final val = double.tryParse(controller.text);
        if (val != null && val > 0) {
          final newKg = isKg ? val : UnitConverter.lbsToKg(val);
          provider.updateProfile(provider.profile.copyWith(weightKg: newKg));
        }
        Navigator.pop(context);
      },
    );
  }

  String _formatTime(String timeString) {
    if (timeString.isEmpty) return 'Not set';
    final parts = timeString.split(':');
    if (parts.length != 2) return timeString;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);
    
    // We cannot use context easily here for formatTimeOfDay without passing it, 
    // but a simple 12-hour format manually is fine too
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    int hourOfPeriod = timeOfDay.hourOfPeriod;
    if (hourOfPeriod == 0) hourOfPeriod = 12;
    final minStr = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hourOfPeriod:$minStr $period';
  }

  Future<void> _editTime(BuildContext context, WaterProvider provider, bool isWakeTime) async {
    final currentTimeString = isWakeTime ? provider.profile.wakeTime : provider.profile.sleepTime;
    TimeOfDay initialTime = const TimeOfDay(hour: 7, minute: 0);
    
    if (currentTimeString.isNotEmpty) {
      final parts = currentTimeString.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 7;
        final minute = int.tryParse(parts[1]) ?? 0;
        initialTime = TimeOfDay(hour: hour, minute: minute);
      }
    }

    TimeOfDay selectedTime = initialTime;

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 30, top: 20, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isWakeTime ? 'Edit Wake Up Time' : 'Edit Sleep Time',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              CustomTimePicker(
                initialTime: initialTime,
                onChanged: (time) {
                  selectedTime = time;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx, selectedTime);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).then((picked) {
      if (picked != null && picked is TimeOfDay && picked != initialTime) {
        final newTimeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        if (isWakeTime) {
          provider.updateProfile(provider.profile.copyWith(wakeTime: newTimeString));
        } else {
          provider.updateProfile(provider.profile.copyWith(sleepTime: newTimeString));
        }
      }
    });
  }

  void _toggleUnit(BuildContext context, WaterProvider provider) {
    final newUnit = provider.profile.unit == MeasureUnit.ml
        ? MeasureUnit.oz
        : MeasureUnit.ml;
    HapticFeedback.lightImpact();
    provider.updateProfile(provider.profile.copyWith(unit: newUnit));
  }

  void _toggleWeightUnit(BuildContext context, WaterProvider provider) {
    final newUnit = provider.profile.weightUnit == WeightUnit.kg
        ? WeightUnit.lbs
        : WeightUnit.kg;
    HapticFeedback.lightImpact();
    provider.updateProfile(provider.profile.copyWith(weightUnit: newUnit));
  }

  void _toggleHeightUnit(BuildContext context, WaterProvider provider) {
    final newUnit = provider.profile.heightUnit == HeightUnit.cm
        ? HeightUnit.ft
        : HeightUnit.cm;
    HapticFeedback.lightImpact();
    provider.updateProfile(provider.profile.copyWith(heightUnit: newUnit));
  }

  void _editGoal(BuildContext context, WaterProvider provider) {
    final isOz = provider.profile.unit == MeasureUnit.oz;
    final displayValue = isOz 
        ? UnitConverter.mlToOz(provider.dailyGoalMl.toDouble()).round()
        : provider.dailyGoalMl;
    
    final controller = TextEditingController(text: displayValue.toString());
    final options = isOz ? [64, 84, 100] : [2000, 2500, 3000];
    final unitLabel = isOz ? 'oz' : 'ml';

    _showEditDialog(
      context: context,
      title: 'Edit Daily Goal ($unitLabel)',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
                color: AppColors.textPrimary, 
                fontSize: 32, 
                fontWeight: FontWeight.w700),
            decoration: _inputDecoration('Target amount'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              for (int i = 0; i < options.length; i++) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      controller.text = options[i].toString();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${options[i]}$unitLabel',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (i < options.length - 1) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
      onSave: () {
        final value = int.tryParse(controller.text);
        if (value != null && value > 0) {
          final mlValue = isOz ? UnitConverter.ozToMl(value.toDouble()).round() : value;
          provider.setDailyGoal(mlValue);
        }
        Navigator.pop(context);
      },
    );
  }

  void _showRecalculated(BuildContext context, WaterProvider provider) {
    final recommended = provider.profile.recommendedIntakeMl;
    final unitLabel = provider.profile.unit == MeasureUnit.oz
        ? '${UnitConverter.mlToOz(recommended.toDouble()).round()} oz'
        : '$recommended ml';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: const Text(
          'Recommended Goal',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              unitLabel,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 36,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on your age, height, and weight',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Keep Current',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.setDailyGoal(recommended);
              Navigator.pop(ctx);
            },
            child: const Text(
              'Apply',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog({
    required BuildContext context,
    required String title,
    required Widget child,
    required VoidCallback onSave,
  }) {
    showDialog(
      context: context,
      barrierColor: AppColors.background.withValues(alpha: 0.8),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),
              child,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textTertiary.withValues(alpha: 0.5),
        fontSize: 15,
      ),
      filled: true,
      fillColor: AppColors.surfaceLight.withValues(alpha: 0.35),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.surfaceLight.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class SelectionItem<T> {
  final T value;
  final String title;
  final String? description;

  const SelectionItem(this.value, this.title, [this.description]);
}
