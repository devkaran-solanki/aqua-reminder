import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/water_provider.dart';
import '../utils/constants.dart';
import '../widgets/custom_time_picker.dart';
import '../widgets/atmospheric_background.dart';
import '../widgets/fade_indexed_stack.dart';

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
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (BuildContext context) {
        TimeOfDay tempPicked = initialTime;
        final themeColor = isWake ? AppColors.warning : AppColors.cyanBright;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF070707),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: themeColor.withValues(alpha: 0.22),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Subtle atmospheric radial glow at top
                  Positioned(
                    top: -60,
                    left: 0,
                    right: 0,
                    height: 160,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topCenter,
                            radius: 1.0,
                            colors: [
                              themeColor.withValues(alpha: 0.12),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Header with squircle badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF111111),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: themeColor.withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeColor.withValues(alpha: 0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isWake
                                    ? Icons.wb_sunny_rounded
                                    : Icons.nights_stay_rounded,
                                color: themeColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isWake ? 'Wake Up Time' : 'Sleep Time',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 2.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(1),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          themeColor,
                                          themeColor,
                                          themeColor.withValues(alpha: 0.75),
                                          themeColor.withValues(alpha: 0.35),
                                          themeColor.withValues(alpha: 0.08),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.50, 0.72, 0.88, 0.97, 1.0],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 2. Custom Time Picker (single box layout, no inner box border)
                        CustomTimePicker(
                          initialTime: initialTime,
                          showBorder: false,
                          backgroundColor: Colors.transparent,
                          fadeColor: const Color(0xFF070707),
                          accentColor: themeColor,
                          onChanged: (TimeOfDay newTime) {
                            tempPicked = newTime;
                          },
                        ),
                        const SizedBox(height: 16),

                        // 3. Action Buttons
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
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF111111),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                    border: Border.all(
                                      color: AppColors.borderSubtle,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  picked = tempPicked;
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isWake
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFFFBBF24),
                                              Color(0xFFF59E0B),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : AppColors.heroCtaGradient,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                    boxShadow: isWake
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFF59E0B)
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 16,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : AppColors.heroCtaShadow,
                                  ),
                                  child: const Text(
                                    'Save',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
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
      body: AtmosphericBackground(
        child: SafeArea(
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
                              ? AppColors.emeraldBright
                              : AppColors.cardLight,
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
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(16),
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
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            // Fortify Hero CTA Button Recipe (Section 3.B)
                            gradient: AppColors.heroCtaGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.heroCtaShadow,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _currentPage == 4 ? 'Get Started' : 'Continue',
                              key: ValueKey(_currentPage == 4 ? 'Get Started' : 'Continue'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
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
          // Main Water Drop Center Lens with Cyan Light Ring (195x195)
          Container(
            width: 195,
            height: 195,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  Color(0xFF0F1E22), // Deep obsidian with subtle oceanic depth
                  AppColors.background, // Seamless obsidian perimeter matching app background
                ],
              ),
              border: Border.all(
                color: AppColors.cyanBright, // Bright variant cyan light border
                width: 2.2,
              ),
              boxShadow: [
                // Cyan light emission along the ring perimeter
                BoxShadow(
                  color: AppColors.cyanBright.withValues(alpha: 0.65),
                  blurRadius: 16,
                  spreadRadius: 2.0,
                ),
                BoxShadow(
                  color: AppColors.cyanBright.withValues(alpha: 0.25),
                  blurRadius: 32,
                  spreadRadius: 4.0,
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Center(
                  child: Transform.scale(
                    scale: 1.08, // Scaled in direct proportion to the enlarged circle
                    child: Image.asset(
                      'assets/images/icon_no_glow.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 50),

          // Headline
          const Text(
            'Hydrate Right,\nEvery Time!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -1.0,
              height: 1.15,
            ),
          ),
          
          const SizedBox(height: 22),

          // Badges placed side-by-side just below the headline
          const FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FloatingBadge(
                  icon: Icons.auto_graph_rounded,
                  text: 'Smart Tracking',
                ),
                SizedBox(width: 12),
                _FloatingBadge(
                  icon: Icons.notifications_active_rounded,
                  text: 'Timely Alerts',
                ),
              ],
            ),
          ),

          const SizedBox(height: 34),

          // Subtitle description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Achieve your daily water goals with intelligent reminders and beautiful visual tracking.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
              fillColor: AppColors.card,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
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
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.borderSubtle,
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SelectedValue(label: 'Age', value: '$_age yrs'),
                Container(height: 24, width: 1, color: AppColors.borderSubtle),
                _SelectedValue(
                  label: 'Height',
                  value: _heightUnit == HeightUnit.cm
                      ? '$_heightValue cm'
                      : '${_heightValue ~/ 12}\'${_heightValue % 12}"',
                ),
                Container(height: 24, width: 1, color: AppColors.borderSubtle),
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
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative background icon
                  Positioned(
                    top: -20,
                    right: -30,
                    child: Icon(
                      Icons.water_drop_rounded,
                      size: 220,
                      color: AppColors.emeraldPrimary.withValues(alpha: 0.04),
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
                                cursorColor: AppColors.emeraldBright,
                                cursorWidth: 3,
                                cursorHeight: 60,
                                cursorRadius: const Radius.circular(2),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                textAlign: TextAlign.center,
                                onChanged: (val) => setState(() {}),
                                style: const TextStyle(
                                  fontSize: 68,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -2,
                                  fontFeatures: [FontFeature.tabularFigures()],
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
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textMuted,
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
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            _unit == MeasureUnit.oz
                                ? 'ounces per day'
                                : 'milliliters per day',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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
                                  Icons.local_cafe_rounded,
                                  size: 18,
                                  color: AppColors.emeraldBright,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  parsed == 0
                                      ? 'Enter a valid amount'
                                      : '≈ $glasses regular glasses',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
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

          const SizedBox(height: 36),

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
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: AppColors.borderSubtleCyan,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: AppColors.emeraldBright, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Reset to suggested',
                    style: TextStyle(
                      color: AppColors.emeraldBright,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderSubtle,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.emeraldBright,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
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
    final timeParts = time.trim().split(' ');
    final timeValue = timeParts.isNotEmpty ? timeParts[0] : time;
    final timePeriod = timeParts.length > 1 ? timeParts[1] : '';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.borderSubtle,
                      width: 1.0,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    timeValue,
                    style: const TextStyle(
                      fontSize: 19,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (timePeriod.isNotEmpty) ...[
                    const SizedBox(width: 5),
                    Text(
                      timePeriod,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? Colors.white : AppColors.borderSubtle,
            width: 1.0,
          ),
          boxShadow: isSelected ? AppColors.whitePillShadow : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 16,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black87 : AppColors.textMuted,
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
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.emeraldPrimary : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.emeraldBright : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.emeraldBright : AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.emeraldBright, size: 20),
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

        // Wheel container with Fortify card surface & hairline border
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Selection highlight bar with subtle emerald perimeter
                Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.borderSubtleCyan,
                      width: 1.0,
                    ),
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
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.emeraldBright
                                : AppColors.textMuted,
                            letterSpacing: isSelected ? -0.5 : 0,
                            fontFeatures: const [FontFeature.tabularFigures()],
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
                            AppColors.card,
                            AppColors.card.withValues(alpha: 0.6),
                            AppColors.card.withValues(alpha: 0),
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
                            AppColors.card,
                            AppColors.card.withValues(alpha: 0.6),
                            AppColors.card.withValues(alpha: 0),
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
          style: const TextStyle(
            color: AppColors.emeraldBright,
            fontSize: 13,
            fontWeight: FontWeight.w700,
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
            color: AppColors.emeraldBright,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.cyanBright.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8.5),
            decoration: BoxDecoration(
              color: AppColors.card.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: AppColors.borderSubtle,
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: AppColors.cyanBright),
                const SizedBox(width: 7),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

