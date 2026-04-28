import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/user_profile.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_time_picker.dart';

import 'package:aqua_reminder/widgets/fade_indexed_stack.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  // Form values
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  final FocusNode _goalFocusNode = FocusNode();
  MeasureUnit _unit = MeasureUnit.ml;
  WeightUnit _weightUnit = WeightUnit.kg;
  HeightUnit _heightUnit = HeightUnit.cm;
  Gender _gender = Gender.other;

  // Schedule times
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);

  // Selected values in native units for scroll wheels
  int _heightValue = 175; // cm or inches
  int _weightValue = 65; // kg or lbs
  int _age = 25;
  int? _suggestedGoal;
  int? _customGoal;
  bool _isGoalEditing = false;

  // Scroll controllers for pickers
  late FixedExtentScrollController _ageScrollController;
  late FixedExtentScrollController _heightScrollController;
  late FixedExtentScrollController _weightScrollController;

  // Ranges
  static const int _ageMin = 10;
  static const int _ageMax = 80;

  @override
  void initState() {
    super.initState();
    // Default values for pickers based on unit
    _ageScrollController = FixedExtentScrollController(
      initialItem: _age - _ageMin,
    );
    // Use initial default based on the default unit (cm/kg)
    _heightScrollController = FixedExtentScrollController(
      initialItem: _heightValue - _currentHeightMin,
    );
    _weightScrollController = FixedExtentScrollController(
      initialItem: _weightValue - _currentWeightMin,
    );
  }

  // Helper getters for bounds based on unit
  int get _currentHeightMin =>
      _heightUnit == HeightUnit.cm ? 120 : 48; // 48 inches = 4ft
  int get _currentHeightMax =>
      _heightUnit == HeightUnit.cm ? 220 : 86; // 86 inches = ~7'2"
  int get _currentWeightMin =>
      _weightUnit == WeightUnit.kg ? 30 : 66; // 66 lbs = ~30kg
  int get _currentWeightMax =>
      _weightUnit == WeightUnit.kg ? 200 : 440; // 440 lbs = ~200kg

  @override
  void dispose() {
    _goalFocusNode.dispose();
    _nameController.dispose();
    _ageScrollController.dispose();
    _heightScrollController.dispose();
    _weightScrollController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(bool isWake) async {
    // Unfocus keyword to avoid layout overflow briefly when the dialog pops up
    FocusScope.of(context).unfocus();
    
    final TimeOfDay initialTime = isWake ? _wakeTime : _sleepTime;
    TimeOfDay? picked;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        TimeOfDay tempPicked = initialTime;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.xl * 1.2),
              border: Border.all(
                color: AppColors.surfaceLight,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl * 1.2),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                  right: -30,
                  child: Icon(
                    isWake ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                    size: 180,
                    color: (isWake ? AppColors.warning : AppColors.primary)
                        .withValues(alpha: 0.05),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isWake
                                  ? Icons.wb_sunny_rounded
                                  : Icons.nights_stay_rounded,
                              color: isWake
                                  ? AppColors.warning
                                  : AppColors.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isWake ? 'Wake Up Time' : 'Sleep Time',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Set your personal daily schedule',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.8),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Custom Time Picker
                        CustomTimePicker(
                          initialTime: initialTime,
                          onChanged: (TimeOfDay newTime) {
                            tempPicked = newTime;
                          },
                        ),
                        const SizedBox(height: 36),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                    border: Border.all(
                                      color: AppColors.surfaceLight,
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  picked = tempPicked;
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Save',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.background,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isWake) {
          _wakeTime = picked!;
        } else {
          _sleepTime = picked!;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final String hour = time.hourOfPeriod == 0
        ? '12'
        : time.hourOfPeriod.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    final String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatTimeForStorage(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _syncScrollControllers() {
    final oldAge = _ageScrollController;
    final oldHeight = _heightScrollController;
    final oldWeight = _weightScrollController;

    _ageScrollController = FixedExtentScrollController(
      initialItem: _age - _ageMin,
    );
    _heightScrollController = FixedExtentScrollController(
      initialItem: _heightValue - _currentHeightMin,
    );
    _weightScrollController = FixedExtentScrollController(
      initialItem: _weightValue - _currentWeightMin,
    );

    oldAge.dispose();
    oldHeight.dispose();
    oldWeight.dispose();
  }

  void _nextPage() {
    if (_currentPage == 2) {
      setState(() {
        _syncScrollControllers();
      });
    }

    if (_currentPage == 3) {
      // Calculate suggested goal before showing the goal page
      final double heightCm = _heightUnit == HeightUnit.cm
          ? _heightValue.toDouble()
          : UnitConverter.inchesToCm(_heightValue.toDouble());
      final double weightKg = _weightUnit == WeightUnit.kg
          ? _weightValue.toDouble()
          : UnitConverter.lbsToKg(_weightValue.toDouble());

      final profile = UserProfile(
        heightCm: heightCm,
        weightKg: weightKg,
        age: _age,
        gender: _gender,
      );
      _suggestedGoal = profile.recommendedIntakeMl;
      _customGoal = _suggestedGoal;

      // Prefill text input
      final displayVal = _unit == MeasureUnit.oz
          ? UnitConverter.mlToOz(_customGoal!.toDouble()).round()
          : _customGoal!;
      _goalController.text = displayVal.toString();
    }

    // Dismiss keyboard when moving between pages
    FocusScope.of(context).unfocus();
    _isGoalEditing = false;

    if (_currentPage < 4) {
      setState(() {
        _currentPage++;
      });
      
      // Auto-focus goal textfield when arriving at the goal page
      if (_currentPage == 4) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _goalFocusNode.requestFocus();
          }
        });
      }
    }
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    _isGoalEditing = false;

    if (_currentPage == 4) {
      setState(() {
        _syncScrollControllers();
      });
    }

    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  Future<void> _complete() async {
    final provider = context.read<WaterProvider>();

    final double heightCm = _heightUnit == HeightUnit.cm
        ? _heightValue.toDouble()
        : UnitConverter.inchesToCm(_heightValue.toDouble());
    final double weightKg = _weightUnit == WeightUnit.kg
        ? _weightValue.toDouble()
        : UnitConverter.lbsToKg(_weightValue.toDouble());

    // Parse manual input from user
    int finalGoalMl = _suggestedGoal ?? WaterDefaults.dailyGoalMl;
    final int? userVal = int.tryParse(_goalController.text);
    if (userVal != null && userVal > 0) {
      if (_unit == MeasureUnit.oz) {
        finalGoalMl = UnitConverter.ozToMl(userVal.toDouble()).round();
      } else {
        finalGoalMl = userVal;
      }
    }

    await provider.completeOnboarding(
      name: _nameController.text.trim().isEmpty
          ? 'Hydrator'
          : _nameController.text.trim(),
      unit: _unit,
      weightUnit: _weightUnit,
      heightUnit: _heightUnit,
      heightCm: heightCm,
      weightKg: weightKg,
      age: _age,
      dailyGoalMl: finalGoalMl,
      wakeTime: _formatTimeForStorage(_wakeTime),
      sleepTime: _formatTimeForStorage(_sleepTime),
      gender: _gender,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false, // Prevents layout snapping during swiping lag when keyboard dismisses
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primary
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: FadeIndexedStack(
                index: _currentPage,
                alignment: Alignment.center,
                duration: const Duration(milliseconds: 250),
                children: [
                  _buildWelcomePage(),
                  _buildNameUnitPage(),
                  _buildGenderPage(),
                  _buildBodyInfoPage(),
                  _buildGoalPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: _currentPage > 0
                        ? Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: _prevPage,
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(
                                    color: AppColors.surfaceLight.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(width: 0),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _currentPage == 4 ? _complete() : _nextPage();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _currentPage == 4 ? 'Get Started' : 'Continue',
                            key: ValueKey(_currentPage == 4 ? 'Get Started' : 'Continue'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page 1: Welcome
  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dynamic Artwork Header
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Background glowing blob
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight.withValues(alpha: 0.5)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 80,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
                // Main Water Drop Logo Center
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.8), width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/images/logo_white.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Floating Badge 1: Goal
                const Positioned(
                  top: 20,
                  right: 0,
                  child: _FloatingBadge(
                    icon: Icons.auto_graph_rounded,
                    text: 'Smart Tracking',
                  ),
                ),
                // Floating Badge 2: Hydration
                const Positioned(
                  bottom: 50,
                  left: -10,
                  child: _FloatingBadge(
                    icon: Icons.health_and_safety_rounded,
                    text: 'Build Habits',
                  ),
                ),
                // Floating Badge 3: Notifications
                const Positioned(
                  bottom: 15,
                  right: 15,
                  child: _FloatingBadge(
                    icon: Icons.notifications_active_rounded,
                    text: 'Timely Alerts',
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 56),
          
          // Typography
          const Text(
            'Master Your\nHabits',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -1.0,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Achieve your daily water goals with intelligent reminders and beautiful visual tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Page 2: Name & Unit
  Widget _buildNameUnitPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'What\'s your name?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'ll use this to personalize your experience.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Your name',
              hintStyle: TextStyle(
                color: AppColors.textTertiary.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: AppColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.surfaceLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Daily Schedule',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TimeSelector(
                  label: 'Wake Up',
                  time: _formatTime(_wakeTime),
                  icon: Icons.wb_sunny_rounded,
                  iconColor: AppColors.warning,
                  onTap: () => _selectTime(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeSelector(
                  label: 'Sleep',
                  time: _formatTime(_sleepTime),
                  icon: Icons.nights_stay_rounded,
                  iconColor: AppColors.primary,
                  onTap: () => _selectTime(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Text(
            'Liquid unit',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _UnitOption(
                  label: 'Milliliters',
                  subtitle: 'ml',
                  isSelected: _unit == MeasureUnit.ml,
                  onTap: () => setState(() => _unit = MeasureUnit.ml),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UnitOption(
                  label: 'Ounces',
                  subtitle: 'oz',
                  isSelected: _unit == MeasureUnit.oz,
                  onTap: () => setState(() => _unit = MeasureUnit.oz),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Height unit',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _UnitOption(
                  label: 'Centimeters',
                  subtitle: 'cm',
                  isSelected: _heightUnit == HeightUnit.cm,
                  onTap: () {
                    if (_heightUnit != HeightUnit.cm) {
                      setState(() {
                        _heightUnit = HeightUnit.cm;
                        _heightValue = UnitConverter.inchesToCm(
                          _heightValue.toDouble(),
                        ).round().clamp(120, 220);

                        final oldController = _heightScrollController;
                        _heightScrollController = FixedExtentScrollController(
                          initialItem: _heightValue - _currentHeightMin,
                        );
                        oldController.dispose();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UnitOption(
                  label: 'Feet/Inches',
                  subtitle: 'ft',
                  isSelected: _heightUnit == HeightUnit.ft,
                  onTap: () {
                    if (_heightUnit != HeightUnit.ft) {
                      setState(() {
                        _heightUnit = HeightUnit.ft;
                        _heightValue = UnitConverter.cmToInches(
                          _heightValue.toDouble(),
                        ).round().clamp(48, 86);

                        final oldController = _heightScrollController;
                        _heightScrollController = FixedExtentScrollController(
                          initialItem: _heightValue - _currentHeightMin,
                        );
                        oldController.dispose();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Weight unit',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _UnitOption(
                  label: 'Kilograms',
                  subtitle: 'kg',
                  isSelected: _weightUnit == WeightUnit.kg,
                  onTap: () {
                    if (_weightUnit != WeightUnit.kg) {
                      setState(() {
                        _weightUnit = WeightUnit.kg;
                        _weightValue = UnitConverter.lbsToKg(
                          _weightValue.toDouble(),
                        ).round().clamp(30, 200);

                        final oldController = _weightScrollController;
                        _weightScrollController = FixedExtentScrollController(
                          initialItem: _weightValue - _currentWeightMin,
                        );
                        oldController.dispose();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UnitOption(
                  label: 'Pounds',
                  subtitle: 'lbs',
                  isSelected: _weightUnit == WeightUnit.lbs,
                  onTap: () {
                    if (_weightUnit != WeightUnit.lbs) {
                      setState(() {
                        _weightUnit = WeightUnit.lbs;
                        _weightValue = UnitConverter.kgToLbs(
                          _weightValue.toDouble(),
                        ).round().clamp(66, 440);

                        final oldController = _weightScrollController;
                        _weightScrollController = FixedExtentScrollController(
                          initialItem: _weightValue - _currentWeightMin,
                        );
                        oldController.dispose();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  // Page 3: Gender
  Widget _buildGenderPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'What is your gender?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us calculate a more accurate hydration goal for your body.',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          
          Column(
            children: [
              _GenderOption(
                icon: Icons.male,
                label: 'Male',
                isSelected: _gender == Gender.male,
                onTap: () => setState(() => _gender = Gender.male),
              ),
              const SizedBox(height: 16),
              _GenderOption(
                icon: Icons.female,
                label: 'Female',
                isSelected: _gender == Gender.female,
                onTap: () => setState(() => _gender = Gender.female),
              ),
              const SizedBox(height: 16),
              _GenderOption(
                icon: Icons.lock_outline,
                label: 'Prefer not to say',
                isSelected: _gender == Gender.other,
                onTap: () => setState(() => _gender = Gender.other),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Page 4: Body info with scroll wheel pickers
  Widget _buildBodyInfoPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Tell us about you',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scroll to select. This helps us calculate your ideal water intake.',
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),

          // Three pickers side by side
          Expanded(
            child: Row(
              children: [
                // Age picker
                Expanded(
                  child: _WheelPicker(
                    label: 'Age',
                    unit: 'yrs',
                    icon: Icons.cake_outlined,
                    itemCount: _ageMax - _ageMin + 1,
                    controller: _ageScrollController,
                    itemBuilder: (index) => '${index + _ageMin}',
                    onChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _age = index + _ageMin);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Height picker
                Expanded(
                  child: _WheelPicker(
                    key: ValueKey('height_$_heightUnit'),
                    label: 'Height',
                    unit: _heightUnit == HeightUnit.cm ? 'cm' : 'ft\'in"',
                    icon: Icons.height,
                    itemCount: _currentHeightMax - _currentHeightMin + 1,
                    controller: _heightScrollController,
                    itemBuilder: (index) {
                      final val = index + _currentHeightMin;
                      if (_heightUnit == HeightUnit.ft) {
                        final feet = val ~/ 12;
                        final inches = val % 12;
                        return '$feet\'$inches"';
                      }
                      return '$val';
                    },
                    onChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _heightValue = index + _currentHeightMin);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Weight picker
                Expanded(
                  child: _WheelPicker(
                    key: ValueKey('weight_$_weightUnit'),
                    label: 'Weight',
                    unit: _weightUnit == WeightUnit.kg ? 'kg' : 'lbs',
                    icon: Icons.monitor_weight_outlined,
                    itemCount: _currentWeightMax - _currentWeightMin + 1,
                    controller: _weightScrollController,
                    itemBuilder: (index) => '${index + _currentWeightMin}',
                    onChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _weightValue = index + _currentWeightMin);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Display selected values
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SelectedValue(label: 'Age', value: '$_age yrs'),
                Container(height: 24, width: 1, color: AppColors.surfaceLight),
                _SelectedValue(
                  label: 'Height',
                  value: _heightUnit == HeightUnit.cm
                      ? '$_heightValue cm'
                      : '${_heightValue ~/ 12}\'${_heightValue % 12}"',
                ),
                Container(height: 24, width: 1, color: AppColors.surfaceLight),
                _SelectedValue(
                  label: 'Weight',
                  value: _weightUnit == WeightUnit.kg
                      ? '$_weightValue kg'
                      : '$_weightValue lbs',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Page 4: Custom goal text input
  Widget _buildGoalPage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text(
            'Your Daily Goal',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on your body profile, we recommend:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Suggested badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Suggested: ${_unit == MeasureUnit.oz ? UnitConverter.mlToOz((_suggestedGoal ?? WaterDefaults.dailyGoalMl).toDouble()).round() : (_suggestedGoal ?? WaterDefaults.dailyGoalMl)} ${_unit == MeasureUnit.oz ? 'oz' : 'ml'}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Main Input Card (Premium Glass Design)
          GestureDetector(
            onTap: () {
              if (!_isGoalEditing) {
                setState(() => _isGoalEditing = true);
                Future.delayed(const Duration(milliseconds: 50), () {
                  SystemChannels.textInput.invokeMethod('TextInput.show');
                });
              } else {
                _goalFocusNode.requestFocus();
                SystemChannels.textInput.invokeMethod('TextInput.show');
              }
            },
            child: Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl * 1.5),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative background icon
                Positioned(
                  top: -20,
                  right: -30,
                  child: Icon(
                    Icons.water_drop,
                    size: 220,
                    color: AppColors.primary.withValues(alpha: 0.04),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          IntrinsicWidth(
                            child: TextField(
                              controller: _goalController,
                              focusNode: _goalFocusNode,
                              keyboardType: TextInputType.number,
                              showCursor: true,
                              readOnly: !_isGoalEditing,
                              onTap: () {
                                if (!_isGoalEditing) {
                                  setState(() => _isGoalEditing = true);
                                  Future.delayed(const Duration(milliseconds: 50), () {
                                    SystemChannels.textInput.invokeMethod('TextInput.show');
                                  });
                                }
                              },
                              cursorColor: AppColors.primary,
                              cursorWidth: 3,
                              cursorHeight: 60,
                              cursorRadius: const Radius.circular(2),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              textAlign: TextAlign.center,
                              onChanged: (val) => setState(() {}),
                              style: TextStyle(
                                fontSize: 68,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -2,
                                shadows: [
                                  Shadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _unit == MeasureUnit.oz ? 'oz' : 'ml',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Unit label
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Text(
                          _unit == MeasureUnit.oz
                              ? 'ounces per day'
                              : 'milliliters per day',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Estimation
                      Builder(
                        builder: (context) {
                          final parsed =
                              int.tryParse(_goalController.text) ?? 0;
                          final glasses = _unit == MeasureUnit.oz
                              ? (parsed / 8).round()
                              : (parsed / 250).round();

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.local_cafe_outlined,
                                size: 20,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                parsed == 0
                                    ? 'Enter a valid amount'
                                    : '≈ $glasses regular glasses',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ), // Closing GestureDetector

          const SizedBox(height: 48),

          // Reset to suggested
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              final displayVal = _unit == MeasureUnit.oz
                  ? UnitConverter.mlToOz(
                      (_suggestedGoal ?? WaterDefaults.dailyGoalMl).toDouble(),
                    ).round()
                  : (_suggestedGoal ?? WaterDefaults.dailyGoalMl);

              _goalController.text = displayVal.toString();
              setState(() {
                _customGoal = _suggestedGoal;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, color: AppColors.secondary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Reset to suggested',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Info note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.waterBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.waterBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.waterBlue.withValues(alpha: 0.8),
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'You can always change your daily goal later in the Profile tab.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 100,
          ), // Additional padding for scrolling and keyboard
        ],
      ),
    );
  }
}

// ΓöÇΓöÇΓöÇ Reusable Widgets ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ

class _TimeSelector extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _TimeSelector({
    required this.label,
    required this.time,
    required this.icon,
    required this.iconColor,
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.surfaceLight.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _UnitOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitOption({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surfaceLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.8)
                      : AppColors.textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
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
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Scroll wheel picker column with label, icon, and unit
class _WheelPicker extends StatelessWidget {
  final String label;
  final String unit;
  final IconData icon;
  final int itemCount;
  final FixedExtentScrollController controller;
  final String Function(int index) itemBuilder;
  final ValueChanged<int> onChanged;

  const _WheelPicker({
    super.key,
    required this.label,
    required this.unit,
    required this.icon,
    required this.itemCount,
    required this.controller,
    required this.itemBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label with icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary.withValues(alpha: 0.6),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Wheel container with glassmorphism
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection highlight bar ΓÇö glowing
                Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.12),
                        AppColors.primary.withValues(alpha: 0.06),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Scroll wheel
                ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 48,
                  perspective: 0.003,
                  diameterRatio: 1.6,
                  physics: const FixedExtentScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  overAndUnderCenterOpacity: 0.6,
                  onSelectedItemChanged: onChanged,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: itemCount,
                    builder: (context, index) {
                      final selectedIndex = controller.selectedItem;
                      final isSelected = index == selectedIndex;
                      return Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: isSelected ? 24 : 16,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary.withValues(
                                    alpha: 0.7,
                                  ),
                            letterSpacing: isSelected ? -0.5 : 0,
                          ),
                          child: Text(itemBuilder(index)),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.background,
                            AppColors.background.withValues(alpha: 0.6),
                            AppColors.background.withValues(alpha: 0),
                          ],
                          stops: const [0, 0.5, 1],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            AppColors.background,
                            AppColors.background.withValues(alpha: 0.6),
                            AppColors.background.withValues(alpha: 0),
                          ],
                          stops: const [0, 0.5, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),
        // Unit label
        Text(
          unit,
          style: TextStyle(
            color: AppColors.primary.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _SelectedValue extends StatelessWidget {
  final String label;
  final String value;

  const _SelectedValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
        ),
      ],
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FloatingBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.surfaceLight.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumShimmerLogo extends StatelessWidget {
  const _PremiumShimmerLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 200, // Reduced height to crop out white space
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withValues(alpha: 0.15),
            blurRadius: 100,
            spreadRadius: 20,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 60,
            spreadRadius: -10,
          ),
        ],
      ),
      child: SvgPicture.asset(
        'assets/images/icon_cyan.svg',
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }
}

