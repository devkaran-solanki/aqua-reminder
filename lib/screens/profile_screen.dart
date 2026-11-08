import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../models/reminder_alarm.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import '../widgets/profile_inputs.dart';
import 'personal_info_screen.dart';
import 'reminder_schedule_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _goalController;
  late final FocusNode _goalFocus;

  String? _openDropdownId;

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
    _goalController = TextEditingController();
    _goalFocus = FocusNode();

    _goalFocus.addListener(() {
      if (_goalFocus.hasFocus) _closeDropdowns();
      if (!_goalFocus.hasFocus && mounted) {
        final provider = Provider.of<WaterProvider>(context, listen: false);
        _saveGoal(provider);
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<WaterProvider>(context, listen: true);
    final profile = provider.profile;

    if (!_goalFocus.hasFocus) {
      final isOz = profile.unit == MeasureUnit.oz;
      final currentDisplay = isOz
          ? UnitConverter.mlToOz(provider.dailyGoalMl.toDouble()).round()
          : provider.dailyGoalMl;
      final gStr = currentDisplay.toString();
      if (_goalController.text != gStr) {
        _goalController.text = gStr;
      }
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    _goalFocus.dispose();
    super.dispose();
  }

  void _saveGoal(WaterProvider provider) {
    final text = _goalController.text.trim();
    final val = int.tryParse(text);
    final isOz = provider.profile.unit == MeasureUnit.oz;
    if (val != null && val > 0) {
      final mlVal = isOz ? UnitConverter.ozToMl(val.toDouble()).round() : val;
      if (mlVal != provider.dailyGoalMl) {
        provider.setDailyGoal(mlVal);
      }
    } else {
      final currentDisplay = isOz
          ? UnitConverter.mlToOz(provider.dailyGoalMl.toDouble()).round()
          : provider.dailyGoalMl;
      _goalController.text = currentDisplay.toString();
    }
  }

  void _onLiquidUnitChanged(WaterProvider provider, MeasureUnit newUnit) {
    if (provider.profile.unit == newUnit) return;
    HapticFeedback.selectionClick();
    _saveGoal(provider);
    provider.updateProfile(provider.profile.copyWith(unit: newUnit));
    final newDisplay = newUnit == MeasureUnit.oz
        ? UnitConverter.mlToOz(provider.dailyGoalMl.toDouble()).round()
        : provider.dailyGoalMl;
    _goalController.text = newDisplay.toString();
    setState(() {});
  }

  void _onWeightUnitChanged(WaterProvider provider, WeightUnit newUnit) {
    if (provider.profile.weightUnit == newUnit) return;
    HapticFeedback.lightImpact();
    provider.updateProfile(provider.profile.copyWith(weightUnit: newUnit));
    setState(() {});
  }

  void _onHeightUnitChanged(WaterProvider provider, HeightUnit newUnit) {
    if (provider.profile.heightUnit == newUnit) return;
    HapticFeedback.lightImpact();
    provider.updateProfile(provider.profile.copyWith(heightUnit: newUnit));
    setState(() {});
  }

  String _buildBiometricSummary(UserProfile profile) {
    final List<String> parts = [];
    if (profile.age > 0) {
      parts.add('${profile.age} yrs');
    }
    if (profile.gender == Gender.male) {
      parts.add('Male');
    } else if (profile.gender == Gender.female) {
      parts.add('Female');
    } else if (profile.gender == Gender.other) {
      parts.add('Other');
    }

    if (profile.weightKg > 0) {
      final isKg = profile.weightUnit == WeightUnit.kg;
      final w = isKg
          ? '${profile.weightKg.round()} kg'
          : '${UnitConverter.kgToLbs(profile.weightKg).round()} lbs';
      parts.add(w);
    } else if (profile.heightCm > 0) {
      if (profile.heightUnit == HeightUnit.cm) {
        parts.add('${profile.heightCm.round()} cm');
      } else {
        final totalInches = UnitConverter.cmToInches(profile.heightCm).round();
        final feet = totalInches ~/ UnitConverter.inchesPerFoot;
        final inches = totalInches % UnitConverter.inchesPerFoot;
        parts.add("$feet'$inches\"");
      }
    }

    if (parts.isEmpty) {
      return 'Physical profile & routine';
    }
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaterProvider>(
      builder: (context, provider, child) {
        final profile = provider.profile;

        return RepaintBoundary(
          child: SafeArea(
            child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                FocusScope.of(context).unfocus();
                _closeDropdowns();
              },
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
                  const SizedBox(height: 20),

                  // Personal Information Banner (Matching the exact card aesthetic of the app)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _closeDropdowns();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalInfoScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.borderSubtle,
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Left: "PERSONAL INFORMATION"
                          const Text(
                            'PERSONAL INFORMATION',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppColors.cyanBright,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Main Row: Avatar + Name / Biometric Info + Middle Right Chevron
                          Row(
                            children: [
                              // Avatar Squircle Housing
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.cardElevated,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.borderSubtle,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    profile.name.isNotEmpty
                                        ? profile.name[0].toUpperCase()
                                        : 'H',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.cyanBright,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Name & Biometric stats summary
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      profile.name.isNotEmpty
                                          ? profile.name
                                          : 'Hydrator',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.4,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _buildBiometricSummary(profile),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Middle Right Chevron Arrow
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textMuted,
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Recalculate Recommended Goal Button
                  RecalculateGoalButton(
                    onTap: () {
                      _closeDropdowns();
                      showRecalculateGoalDialog(
                        context,
                        provider,
                        onGoalApplied: () {
                          final isOz = provider.profile.unit == MeasureUnit.oz;
                          final newDisplay = isOz
                              ? UnitConverter.mlToOz(provider.dailyGoalMl.toDouble()).round()
                              : provider.dailyGoalMl;
                          _goalController.text = newDisplay.toString();
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Preferences Section
                  const ProfileSectionHeader(title: 'Preferences'),
                  const SizedBox(height: 12),

                  // 1. Daily Goal on top (Instagram-style subtle inline input)
                  InstagramProfileInput(
                    icon: Icons.flag_rounded,
                    label: 'Daily Goal',
                    controller: _goalController,
                    focusNode: _goalFocus,
                    hintText: 'Goal',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    unitSuffix: profile.unit == MeasureUnit.ml ? 'ml' : 'oz',
                    inputWidth: 48,
                    onSubmitted: (_) => _saveGoal(provider),
                  ),

                  // 2. Liquid Unit (Premium Cyber Dropdown)
                  InstagramDropdown<MeasureUnit>(
                    label: 'Liquid Unit',
                    selectedValue: profile.unit,
                    icon: Icons.science_rounded,
                    showOptionIcons: false,
                    items: const [
                      InstagramDropdownItem(
                        value: MeasureUnit.ml,
                        label: 'Milliliters (ml)',
                      ),
                      InstagramDropdownItem(
                        value: MeasureUnit.oz,
                        label: 'Fluid Ounces (oz)',
                      ),
                    ],
                    isOpen: _openDropdownId == 'liquid',
                    onToggle: () => _toggleDropdown('liquid'),
                    onSelected: (newVal) => _onLiquidUnitChanged(provider, newVal),
                  ),

                  // 3. Weight Unit (Premium Cyber Dropdown)
                  InstagramDropdown<WeightUnit>(
                    label: 'Weight Unit',
                    selectedValue: profile.weightUnit,
                    icon: Icons.scale_rounded,
                    showOptionIcons: false,
                    items: const [
                      InstagramDropdownItem(
                        value: WeightUnit.kg,
                        label: 'Kilograms (kg)',
                      ),
                      InstagramDropdownItem(
                        value: WeightUnit.lbs,
                        label: 'Pounds (lbs)',
                      ),
                    ],
                    isOpen: _openDropdownId == 'weight',
                    onToggle: () => _toggleDropdown('weight'),
                    onSelected: (newVal) => _onWeightUnitChanged(provider, newVal),
                  ),

                  // 4. Height Unit (Premium Cyber Dropdown)
                  InstagramDropdown<HeightUnit>(
                    label: 'Height Unit',
                    selectedValue: profile.heightUnit,
                    icon: Icons.straighten_rounded,
                    showOptionIcons: false,
                    items: const [
                      InstagramDropdownItem(
                        value: HeightUnit.cm,
                        label: 'Centimeters (cm)',
                      ),
                      InstagramDropdownItem(
                        value: HeightUnit.ft,
                        label: 'Feet/Inches (ft/in)',
                      ),
                    ],
                    isOpen: _openDropdownId == 'height',
                    onToggle: () => _toggleDropdown('height'),
                    onSelected: (newVal) => _onHeightUnitChanged(provider, newVal),
                  ),

                  const SizedBox(height: 24),

                  // Reminders Section
                  const ProfileSectionHeader(title: 'Reminders'),
                  const SizedBox(height: 12),

                  // Reminder Mode Selectable Field (routes to ReminderScheduleScreen)
                  InstagramSelectableField(
                    icon: profile.reminderMode == ReminderMode.manual
                        ? Icons.alarm_rounded
                        : Icons.auto_awesome_rounded,
                    label: 'Reminder Mode',
                    value: profile.reminderMode == ReminderMode.manual
                        ? 'Manual Schedule (${provider.customAlarms.where((a) => a.isEnabled).length} active)'
                        : 'Smart Adaptive',
                    onTap: () {
                      _closeDropdowns();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReminderScheduleScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 124),
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
