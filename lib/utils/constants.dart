import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Deep ocean blues
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF111638);
  static const Color surfaceLight = Color(0xFF1A1F4A);
  static const Color card = Color(0xFF161B40);

  // Accent - Vibrant cyan/teal
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryLight = Color(0xFF00F5C8);
  static const Color primaryDark = Color(0xFF00A383);

  // Secondary accent
  static const Color secondary = Color(0xFF5B6CF7);
  static const Color secondaryLight = Color(0xFF7B8AFF);

  // Water blue for charts and indicators
  static const Color waterBlue = Color(0xFF4FC3F7);
  static const Color waterBlueDark = Color(0xFF0288D1);

  // Text colors
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B8D1);
  static const Color textTertiary = Color(0xFF6C7293);

  // Status colors
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB40);
  static const Color error = Color(0xFFFF5252);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient waterGradient = LinearGradient(
    colors: [waterBlue, Color(0xFF29B6F6), Color(0xFF0288D1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1F4A), Color(0xFF111638)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF4FC3F7), Color(0xFF5B6CF7)],
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pill = 100;
}

class WaterDefaults {
  static const int dailyGoalMl = 2500;
  static const List<int> presetSizes = [100, 150, 250, 350, 500, 750];
  static const int defaultSelectedSize = 250;
}
