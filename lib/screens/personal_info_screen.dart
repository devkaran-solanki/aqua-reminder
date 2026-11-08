import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/custom_time_picker.dart';
import '../widgets/profile_inputs.dart';

/// Dedicated screen for viewing and editing all personal and additional information fields
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _feetController;
  late final TextEditingController _inchesController;
  late final TextEditingController _weightController;

  late final FocusNode _nameFocus;
  late final FocusNode _ageFocus;
  late final FocusNode _heightFocus;
  late final FocusNode _feetFocus;
  late final FocusNode _inchesFocus;
  late final FocusNode _weightFocus;

  String? _openDropdownId;
  bool _isTransitionComplete = false;
  Animation<double>? _routeAnimation;

  void _closeDropdowns() {
    if (_openDropdownId != null) {
      setState(() {
        _openDropdownId = null;
      });
    }
  }

  void _toggleDropdown(String id) {
    FocusScope.of(context).unfocus();
    setState(() {
      _openDropdownId = (_openDropdownId == id) ? null : id;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _feetController = TextEditingController();
    _inchesController = TextEditingController();
    _weightController = TextEditingController();

    _nameFocus = FocusNode();
    _ageFocus = FocusNode();
    _heightFocus = FocusNode();
    _feetFocus = FocusNode();
    _inchesFocus = FocusNode();
    _weightFocus = FocusNode();

    // Auto-save listeners on unfocus
    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) _closeDropdowns();
      if (!_nameFocus.hasFocus && mounted) {
        final provider = Provider.of<WaterProvider>(context, listen: false);
        _saveName(provider);
      }
      if (mounted) setState(() {});
    });

    _ageFocus.addListener(() {
      if (_ageFocus.hasFocus) _closeDropdowns();
      if (!_ageFocus.hasFocus && mounted) {
        final provider = Provider.of<WaterProvider>(context, listen: false);
        _saveAge(provider);
      }
      if (mounted) setState(() {});
    });

    _heightFocus.addListener(() {
      if (_heightFocus.hasFocus) _closeDropdowns();
      if (!_heightFocus.hasFocus && mounted) {
        final provider = Provider.of<WaterProvider>(context, listen: false);
        _saveHeight(provider);
      }
      if (mounted) setState(() {});
    });

    _feetFocus.addListener(() {
      if (_feetFocus.hasFocus) _closeDropdowns();
      if (!_feetFocus.hasFocus && !_inchesFocus.hasFocus && mounted) {
        final provider = Provider.of<WaterProvider>(context, listen: false);
        _saveHeightFt(provider);
      }
      if (mounted) setState(() {});
    });

    _inchesFocus.addListener(() {
      if (_inchesFocus.hasFocus) _closeDropdowns();
      if (!_feetFocus.hasFocus && !_inchesFocus.hasFocus && mounted) {
        final provider = Provider.of<WaterProvider>(context, listen: false);
        _saveHeightFt(provider);
      }
      if (mounted) setState(() {});
    });

    _weightFocus.addListener(() {
      if (_weightFocus.hasFocus) _closeDropdowns();
      if (!_weightFocus.hasFocus && mounted) {
        final provider = Provider.of<WaterProvider>(context, listen: false);
        _saveWeight(provider);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final profile = provider.profile;

    // Track route transition animation status to achieve 120fps fluid transitions
    final route = ModalRoute.of(context);
    if (route != null && route.animation != null) {
      if (_routeAnimation != route.animation) {
        _routeAnimation?.removeStatusListener(_onTransitionStatus);
        _routeAnimation = route.animation;
        if (_routeAnimation!.isCompleted) {
          _isTransitionComplete = true;
        } else {
          _routeAnimation!.addStatusListener(_onTransitionStatus);
        }
      }
    } else {
      _isTransitionComplete = true;
    }

    if (!_nameFocus.hasFocus && _nameController.text != profile.name) {
      _nameController.text = profile.name;
    }
    if (!_ageFocus.hasFocus) {
      final ageStr = profile.age > 0 ? profile.age.toString() : '';
      if (_ageController.text != ageStr) {
        _ageController.text = ageStr;
      }
    }
    if (profile.heightUnit == HeightUnit.cm) {
      if (!_heightFocus.hasFocus) {
        final hStr = profile.heightCm.round().toString();
        if (_heightController.text != hStr) {
          _heightController.text = hStr;
        }
      }
    } else {
      if (!_feetFocus.hasFocus && !_inchesFocus.hasFocus) {
        final totalInches = UnitConverter.cmToInches(profile.heightCm).round();
        final feetStr = (totalInches ~/ UnitConverter.inchesPerFoot).toString();
        final inchesStr = (totalInches % UnitConverter.inchesPerFoot).toString();
        if (_feetController.text != feetStr) {
          _feetController.text = feetStr;
        }
        if (_inchesController.text != inchesStr) {
          _inchesController.text = inchesStr;
        }
      }
    }
    if (!_weightFocus.hasFocus) {
      final isKg = profile.weightUnit == WeightUnit.kg;
      final wStr = isKg
          ? profile.weightKg.round().toString()
          : UnitConverter.kgToLbs(profile.weightKg).round().toString();
      if (_weightController.text != wStr) {
        _weightController.text = wStr;
      }
    }
  }

  void _onTransitionStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _routeAnimation?.removeStatusListener(_onTransitionStatus);
      if (mounted) {
        setState(() {
          _isTransitionComplete = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onTransitionStatus);
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _feetController.dispose();
    _inchesController.dispose();
    _weightController.dispose();

    _nameFocus.dispose();
    _ageFocus.dispose();
    _heightFocus.dispose();
    _feetFocus.dispose();
    _inchesFocus.dispose();
    _weightFocus.dispose();
    super.dispose();
  }

  void _saveName(WaterProvider provider) {
    final name = _nameController.text.trim();
    if (name.isNotEmpty && name != provider.profile.name) {
      provider.updateProfile(provider.profile.copyWith(name: name));
    }
  }

  void _saveAge(WaterProvider provider) {
    final text = _ageController.text.trim();
    final age = int.tryParse(text);
    if (age != null && age > 0 && age <= 120) {
      if (age != provider.profile.age) {
        provider.updateProfile(provider.profile.copyWith(age: age));
      }
    } else {
      _ageController.text = provider.profile.age.toString();
    }
  }

  void _saveHeight(WaterProvider provider) {
    final text = _heightController.text.trim();
    final val = double.tryParse(text);
    if (val != null && val > 0) {
      if ((val - provider.profile.heightCm).abs() > 0.05) {
        provider.updateProfile(provider.profile.copyWith(heightCm: val));
      }
    } else {
      _heightController.text = provider.profile.heightCm.round().toString();
    }
  }

  void _saveHeightFt(WaterProvider provider) {
    final feetVal = int.tryParse(_feetController.text.trim()) ?? 0;
    final inchesVal = int.tryParse(_inchesController.text.trim()) ?? 0;
    final totalInches = feetVal * UnitConverter.inchesPerFoot + inchesVal;
    if (totalInches > 0) {
      final newCm = UnitConverter.inchesToCm(totalInches.toDouble());
      if ((newCm - provider.profile.heightCm).abs() > 0.05) {
        provider.updateProfile(provider.profile.copyWith(heightCm: newCm));
      }
      final normFeet = totalInches ~/ UnitConverter.inchesPerFoot;
      final normInches = totalInches % UnitConverter.inchesPerFoot;
      _feetController.text = normFeet.toString();
      _inchesController.text = normInches.toString();
    } else {
      final totalInches = UnitConverter.cmToInches(provider.profile.heightCm).round();
      _feetController.text = (totalInches ~/ UnitConverter.inchesPerFoot).toString();
      _inchesController.text = (totalInches % UnitConverter.inchesPerFoot).toString();
    }
  }

  void _saveWeight(WaterProvider provider) {
    final text = _weightController.text.trim();
    final val = double.tryParse(text);
    if (val != null && val > 0) {
      final isKg = provider.profile.weightUnit == WeightUnit.kg;
      final newKg = isKg ? val : UnitConverter.lbsToKg(val);
      if ((newKg - provider.profile.weightKg).abs() > 0.05) {
        provider.updateProfile(provider.profile.copyWith(weightKg: newKg));
      }
      _weightController.text = val.round().toString();
    } else {
      final isKg = provider.profile.weightUnit == WeightUnit.kg;
      final wStr = isKg
          ? provider.profile.weightKg.round().toString()
          : UnitConverter.kgToLbs(provider.profile.weightKg).round().toString();
      _weightController.text = wStr;
    }
  }

  String _formatTime(String timeString) {
    if (timeString.isEmpty) return 'Not set';
    final parts = timeString.split(':');
    if (parts.length != 2) return timeString;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final timeOfDay = TimeOfDay(hour: hour, minute: minute);

    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    final hourOfPeriod = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minuteString = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hourOfPeriod:$minuteString $period';
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
                accentColor: isWakeTime ? AppColors.warning : AppColors.cyanBright,
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
                      backgroundColor:
                          isWakeTime ? AppColors.warning : AppColors.primary,
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
    ).then((result) {
      if (result != null && result is TimeOfDay) {
        final newTimeString =
            '${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')}';
        if (isWakeTime) {
          provider.updateProfile(provider.profile.copyWith(wakeTime: newTimeString));
        } else {
          provider.updateProfile(provider.profile.copyWith(sleepTime: newTimeString));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: AtmosphericBackground(
            child: RepaintBoundary(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Top Custom Header Navigation (matching Reminder Schedule screen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Row(
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderSubtle,
                              width: 1.0,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Title
                      const Expanded(
                        child: Text(
                          'Personal information',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      _closeDropdowns();
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recalculate Recommended Goal Button at the top
                          RecalculateGoalButton(
                            onTap: () {
                              _closeDropdowns();
                              showRecalculateGoalDialog(context, provider);
                            },
                          ),
                          const SizedBox(height: 20),

                          // SECTION 1: PERSONAL INFORMATION
                          const ProfileSectionHeader(title: 'Personal Information'),
                          const SizedBox(height: 12),

                          // 1. Name
                          InstagramProfileInput(
                            icon: Icons.person_rounded,
                            label: 'Name',
                            controller: _nameController,
                            focusNode: _nameFocus,
                            hintText: 'Enter your name',
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.words,
                            isInteractive: _isTransitionComplete,
                            onSubmitted: (_) => _saveName(provider),
                          ),

                          // 2. Age
                          InstagramProfileInput(
                            icon: Icons.cake_rounded,
                            label: 'Age',
                            controller: _ageController,
                            focusNode: _ageFocus,
                            hintText: 'Age',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            unitSuffix: 'years',
                            inputWidth: 32,
                            isInteractive: _isTransitionComplete,
                            onSubmitted: (_) => _saveAge(provider),
                          ),

                          // 3. Height
                          if (profile.heightUnit == HeightUnit.cm)
                            InstagramProfileInput(
                              icon: Icons.height_rounded,
                              label: 'Height',
                              controller: _heightController,
                              focusNode: _heightFocus,
                              hintText: 'Height',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              unitSuffix: 'cm',
                              inputWidth: 36,
                              isInteractive: _isTransitionComplete,
                              onSubmitted: (_) => _saveHeight(provider),
                            )
                          else
                            InstagramHeightFtInput(
                              feetController: _feetController,
                              inchesController: _inchesController,
                              feetFocus: _feetFocus,
                              inchesFocus: _inchesFocus,
                              isInteractive: _isTransitionComplete,
                              onSave: () => _saveHeightFt(provider),
                            ),

                          // 4. Weight
                          InstagramProfileInput(
                            icon: Icons.monitor_weight_rounded,
                            label: 'Weight',
                            controller: _weightController,
                            focusNode: _weightFocus,
                            hintText: 'Weight',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            unitSuffix:
                                profile.weightUnit == WeightUnit.kg ? 'kg' : 'lbs',
                            inputWidth: 36,
                            isInteractive: _isTransitionComplete,
                            onSubmitted: (_) => _saveWeight(provider),
                          ),

                          // 5. Gender
                          InstagramDropdown<Gender>(
                            label: 'Gender',
                            selectedValue: profile.gender,
                            dynamicIcon: (g) {
                              switch (g) {
                                case Gender.male:
                                  return Icons.male_rounded;
                                case Gender.female:
                                  return Icons.female_rounded;
                                case Gender.other:
                                  return Icons.transgender_rounded;
                              }
                            },
                            items: const [
                              InstagramDropdownItem(
                                value: Gender.male,
                                label: 'Male',
                                icon: Icons.male_rounded,
                              ),
                              InstagramDropdownItem(
                                value: Gender.female,
                                label: 'Female',
                                icon: Icons.female_rounded,
                              ),
                              InstagramDropdownItem(
                                value: Gender.other,
                                label: 'Prefer not to say',
                                icon: Icons.transgender_rounded,
                              ),
                            ],
                            isOpen: _openDropdownId == 'gender',
                            onToggle: () => _toggleDropdown('gender'),
                            onSelected: (newVal) {
                              if (newVal != profile.gender) {
                                provider.updateProfile(profile.copyWith(gender: newVal));
                              }
                            },
                          ),

                          // 6. Wake Up Time
                          InstagramSelectableField(
                            icon: Icons.wb_sunny_rounded,
                            label: 'Wake Up Time',
                            value: _formatTime(profile.wakeTime),
                            onTap: () {
                              _closeDropdowns();
                              _editTime(context, provider, true);
                            },
                          ),

                          // 7. Sleep Time
                          InstagramSelectableField(
                            icon: Icons.nightlight_round,
                            label: 'Sleep Time',
                            value: _formatTime(profile.sleepTime),
                            onTap: () {
                              _closeDropdowns();
                              _editTime(context, provider, false);
                            },
                          ),

                          const SizedBox(height: 22),

                          // SECTION 2: ADDITIONAL INFORMATION
                          const ProfileSectionHeader(title: 'Additional Information'),
                          const SizedBox(height: 12),

                          // 1. Activity Level
                          InstagramDropdown<ActivityLevel>(
                            label: 'Activity Level',
                            selectedValue: profile.activityLevel,
                            dynamicIcon: (level) {
                              switch (level) {
                                case ActivityLevel.low:
                                  return Icons.weekend_rounded;
                                case ActivityLevel.moderate:
                                  return Icons.directions_walk_rounded;
                                case ActivityLevel.high:
                                  return Icons.directions_run_rounded;
                                case ActivityLevel.athlete:
                                  return Icons.fitness_center_rounded;
                              }
                            },
                            items: const [
                              InstagramDropdownItem(
                                value: ActivityLevel.low,
                                label: 'Low Activity',
                                subtitle: 'Sedentary lifestyle, mainly sitting',
                                icon: Icons.weekend_rounded,
                              ),
                              InstagramDropdownItem(
                                value: ActivityLevel.moderate,
                                label: 'Moderate Activity',
                                subtitle: 'Light daily movement or casual exercise',
                                icon: Icons.directions_walk_rounded,
                              ),
                              InstagramDropdownItem(
                                value: ActivityLevel.high,
                                label: 'High Activity',
                                subtitle: 'Regular intense workouts or active job',
                                icon: Icons.directions_run_rounded,
                              ),
                              InstagramDropdownItem(
                                value: ActivityLevel.athlete,
                                label: 'Athlete',
                                subtitle: 'Extreme physical training or sports',
                                icon: Icons.fitness_center_rounded,
                              ),
                            ],
                            isOpen: _openDropdownId == 'activity',
                            onToggle: () => _toggleDropdown('activity'),
                            onSelected: (newVal) {
                              if (newVal != profile.activityLevel) {
                                provider.updateProfile(profile.copyWith(activityLevel: newVal));
                              }
                            },
                          ),

                          // 2. Climate
                          InstagramDropdown<Climate>(
                            label: 'Climate',
                            selectedValue: profile.climate,
                            dynamicIcon: (c) {
                              switch (c) {
                                case Climate.cool:
                                  return Icons.ac_unit_rounded;
                                case Climate.moderate:
                                  return Icons.wb_cloudy_rounded;
                                case Climate.hot:
                                  return Icons.wb_sunny_rounded;
                              }
                            },
                            items: const [
                              InstagramDropdownItem(
                                value: Climate.cool,
                                label: 'Cool',
                                subtitle: 'Cold outside, or mostly air-conditioned',
                                icon: Icons.ac_unit_rounded,
                              ),
                              InstagramDropdownItem(
                                value: Climate.moderate,
                                label: 'Moderate',
                                subtitle: 'Mild, average comfortable temperatures',
                                icon: Icons.wb_cloudy_rounded,
                              ),
                              InstagramDropdownItem(
                                value: Climate.hot,
                                label: 'Hot',
                                subtitle: 'High temperatures, humid, or sunny',
                                icon: Icons.wb_sunny_rounded,
                              ),
                            ],
                            isOpen: _openDropdownId == 'climate',
                            onToggle: () => _toggleDropdown('climate'),
                            onSelected: (newVal) {
                              if (newVal != profile.climate) {
                                provider.updateProfile(profile.copyWith(climate: newVal));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    },
  );
}
}
