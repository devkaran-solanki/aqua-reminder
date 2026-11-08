import 'reminder_alarm.dart';

enum MeasureUnit { ml, oz }

enum WeightUnit { kg, lbs }

enum HeightUnit { cm, ft }

enum Gender { male, female, other }

enum ActivityLevel { low, moderate, high, athlete }

enum Climate { cool, moderate, hot }

class UserProfile {
  final String name;
  final MeasureUnit unit;
  final WeightUnit weightUnit;
  final HeightUnit heightUnit;
  final double heightCm; // stored in cm internally
  final double weightKg; // stored in kg internally
  final int age;
  final String wakeTime;
  final String sleepTime;
  final bool onboardingComplete;
  
  // Advanced variables
  final Gender gender;
  final ActivityLevel activityLevel;
  final Climate climate;
  final ReminderMode reminderMode;

  const UserProfile({
    this.name = '',
    this.unit = MeasureUnit.ml,
    this.weightUnit = WeightUnit.kg,
    this.heightUnit = HeightUnit.cm,
    this.heightCm = 170,
    this.weightKg = 70,
    this.age = 25,
    this.wakeTime = '07:00',
    this.sleepTime = '23:00',
    this.onboardingComplete = false,
    this.gender = Gender.other,
    this.activityLevel = ActivityLevel.moderate,
    this.climate = Climate.moderate,
    this.reminderMode = ReminderMode.auto,
  });

  UserProfile copyWith({
    String? name,
    MeasureUnit? unit,
    WeightUnit? weightUnit,
    HeightUnit? heightUnit,
    double? heightCm,
    double? weightKg,
    int? age,
    String? wakeTime,
    String? sleepTime,
    bool? onboardingComplete,
    Gender? gender,
    ActivityLevel? activityLevel,
    Climate? climate,
    ReminderMode? reminderMode,
  }) {
    return UserProfile(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      weightUnit: weightUnit ?? this.weightUnit,
      heightUnit: heightUnit ?? this.heightUnit,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      wakeTime: wakeTime ?? this.wakeTime,
      sleepTime: sleepTime ?? this.sleepTime,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      climate: climate ?? this.climate,
      reminderMode: reminderMode ?? this.reminderMode,
    );
  }

  /// Calculate recommended daily water intake in ml
  /// Formula: ~30-35ml per kg body weight, adjusted for age
  int get recommendedIntakeMl {
    double base = weightKg * 33; // 33ml per kg baseline

    // Age adjustments
    if (age < 18) {
      base *= 1.1; // younger people need slightly more per kg
    } else if (age > 55) {
      base *= 0.9; // older adults slightly less
    }

    // Gender adjustments (men generally need ~15% more baseline roughly)
    if (gender == Gender.male) {
      base *= 1.15;
    } else if (gender == Gender.female) {
      base *= 1.0; 
    }

    // Height factor (taller people tend to need more)
    if (heightCm > 180) {
      base += 200;
    } else if (heightCm > 170) {
      base += 100;
    }

    // Activity Levels
    switch (activityLevel) {
      case ActivityLevel.low:
        break; // Baseline
      case ActivityLevel.moderate:
        base += 400;
        break;
      case ActivityLevel.high:
        base += 800;
        break;
      case ActivityLevel.athlete:
        base += 1200;
        break;
    }

    // Climate Adjustments
    switch (climate) {
      case Climate.cool:
        break; // Baseline
      case Climate.moderate:
        base += 200;
        break;
      case Climate.hot:
        base += 600;
        break;
    }

    // Round to nearest 50
    return ((base / 50).round() * 50).clamp(1500, 6000);
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'unit': unit.name,
    'weightUnit': weightUnit.name,
    'heightUnit': heightUnit.name,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'age': age,
    'wakeTime': wakeTime,
    'sleepTime': sleepTime,
    'onboardingComplete': onboardingComplete,
    'gender': gender.name,
    'activityLevel': activityLevel.name,
    'climate': climate.name,
    'reminderMode': reminderMode.name,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] as String? ?? '',
    unit: MeasureUnit.values.firstWhere(
      (u) => u.name == json['unit'],
      orElse: () => MeasureUnit.ml,
    ),
    weightUnit: WeightUnit.values.firstWhere(
      (u) => u.name == json['weightUnit'],
      orElse: () => WeightUnit.kg,
    ),
    heightUnit: HeightUnit.values.firstWhere(
      (u) => u.name == json['heightUnit'],
      orElse: () => HeightUnit.cm,
    ),
    heightCm: (json['heightCm'] as num?)?.toDouble() ?? 170,
    weightKg: (json['weightKg'] as num?)?.toDouble() ?? 70,
    age: json['age'] as int? ?? 25,
    wakeTime: json['wakeTime'] as String? ?? '07:00',
    sleepTime: json['sleepTime'] as String? ?? '23:00',
    onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    gender: Gender.values.firstWhere(
      (g) => g.name == json['gender'],
      orElse: () => Gender.other,
    ),
    activityLevel: ActivityLevel.values.firstWhere(
      (a) => a.name == json['activityLevel'],
      orElse: () => ActivityLevel.moderate,
    ),
    climate: Climate.values.firstWhere(
      (c) => c.name == json['climate'],
      orElse: () => Climate.moderate,
    ),
    reminderMode: ReminderMode.values.firstWhere(
      (m) => m.name == json['reminderMode'],
      orElse: () => ReminderMode.auto,
    ),
  );
}

/// Utility to convert between ml and oz
class UnitConverter {
  static const double mlPerOz = 29.5735;

  static double mlToOz(double ml) => ml / mlPerOz;
  static double ozToMl(double oz) => oz * mlPerOz;

  static String formatAmount(int ml, MeasureUnit unit) {
    if (unit == MeasureUnit.oz) {
      final oz = mlToOz(ml.toDouble());
      if (oz >= 33.814) {
        // 1 liter
        return '${oz.round()} oz';
      }
      return '${oz.round()} oz';
    }
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(2)} L';
    }
    return '$ml ml';
  }

  static String formatAmountShort(int ml, MeasureUnit unit) {
    if (unit == MeasureUnit.oz) {
      return '${mlToOz(ml.toDouble()).round()} oz';
    }
    return '$ml ml';
  }

  static String unitLabel(MeasureUnit unit) {
    return unit == MeasureUnit.oz ? 'oz' : 'ml';
  }

  // Weight conversions
  static const double lbsPerKg = 2.20462;
  static double kgToLbs(double kg) => kg * lbsPerKg;
  static double lbsToKg(double lbs) => lbs / lbsPerKg;

  // Height conversions
  static const double cmPerInch = 2.54;
  static const int inchesPerFoot = 12;

  static double cmToInches(double cm) => cm / cmPerInch;
  static double inchesToCm(double inches) => inches * cmPerInch;

  static String formatHeight(double cm, HeightUnit unit) {
    if (unit == HeightUnit.cm) {
      return '${cm.round()} cm';
    } else {
      final totalInches = cmToInches(cm).round();
      final feet = totalInches ~/ inchesPerFoot;
      final inches = totalInches % inchesPerFoot;
      return '$feet\'$inches"';
    }
  }

  static String formatWeight(double kg, WeightUnit unit) {
    if (unit == WeightUnit.kg) {
      return '${kg.round()} kg';
    } else {
      return '${kgToLbs(kg).round()} lbs';
    }
  }
}
