import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'AQUÉA';
  static const String appDescription = 'AQUÉA - Elite Obsidian & Electric Cyan Hydration Tracker';
}

class AppColors {
  // Atmospheric Backgrounds
  static const Color background = Color(0xFF000000); // Pure OLED black primary background canvas
  static const Color backgroundSecondary = Color(0xFF000000); // Secondary section background (pitch black)
  static const Color canvasFrame = Color(0xFF000000); // Outer desktop/tablet bounding frame

  // Card & Surface Elevation Hierarchy (Pure Neutral Charcoal, 0% green)
  static const Color card = Color(0xFF111111); // Neutral charcoal card surface (matches cancel button)
  static const Color cardElevated = Color(0xFF111111); // Elevated badges, icon containers, floating controls
  static const Color cardLight = Color(0xFF111111); // Input fields, table row cells, sub-containers
  static const Color surface = Color(0xFF111111); // Backward-compatible surface alias
  static const Color cardHover = Color(0xFF161616); // Pressed / active state for dark cards
  static const Color surfaceLight = Color(0xFF111111); // Backward-compatible alias (points to cardElevated)

  // Vibrant Electric Cyan & Radiant Aqua Accents (from the new Logo)
  static const Color cyanPrimary = Color(0xFF00D2FF); // Radiant Sky Aqua (from logo body, charts, labels)
  static const Color cyanBright = Color(0xFF00F2FE); // Electric Neon Cyan (from logo luminous curve, CTA, active checkmarks)
  static const Color cyanDark = Color(0xFF004D61); // Deep oceanic teal shadow (radial gradient base)
  static const Color cyanGlow = Color(0x2900F2FE); // rgba(0, 242, 254, 0.16) Ambient backdrop for stat icons
  static const Color cyanSurface = Color(0xFF0E1A1E); // Subtle aqua-tinted container

  // Emerald aliases (for seamless backward-compatibility across all widgets)
  static const Color emeraldPrimary = cyanPrimary;
  static const Color emeraldBright = cyanBright;
  static const Color emeraldDark = cyanDark;
  static const Color emeraldGlow = cyanGlow;
  static const Color emeraldSurface = cyanSurface;

  // Primary & Water aliases (backward compatible with existing widgets)
  static const Color primary = cyanPrimary;
  static const Color primaryLight = cyanBright;
  static const Color primaryDark = cyanDark;
  static const Color secondary = cyanPrimary;
  static const Color secondaryLight = cyanBright;
  static const Color waterBlue = cyanPrimary;
  static const Color waterBlueDark = cyanDark;

  // Hairline Borders & Dividers
  static const Color borderSubtle = Color(0x1AFFFFFF); // rgba(255, 255, 255, 0.10) Translucent titanium hairline
  static const Color borderSubtleGreen = Color(0x1F00D2FF); // rgba(0, 210, 255, 0.12) Subtle aqua hairline
  static const Color borderSubtleCyan = Color(0x1F00D2FF);
  static const Color borderActive = Color(0x6600F2FE); // rgba(0, 242, 254, 0.40) Glowing active perimeter
  static const Color divider = Color(0xFF161616); // Clean horizontal rules between list items

  // High-Contrast Titanium Typography
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50 - Ultra-crisp titanium white
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400 - Steel gray
  static const Color textMuted = Color(0xFF64748B); // Slate 500 - Titanium slate zinc (units, overlines, hints)
  static const Color textTertiary = Color(0xFF64748B); // Backward-compatible alias for textMuted

  // Semantic Status Accents
  static const Color warmup = Color(0xFFF59E0B); // Warmup sets, flame streaks (Amber)
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color drop = Color(0xFFA855F7); // Drop sets (Violet)
  static const Color failure = Color(0xFFEF4444); // Failure, deletions, errors (Crimson)
  static const Color error = Color(0xFFEF4444); // Crimson
  static const Color success = cyanBright; // Radiant cyan success

  // Gradients
  // Primary Hero Call-To-Action Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [cyanBright, cyanPrimary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroCtaGradient = LinearGradient(
    colors: [Color(0xFF00F2FE), Color(0xFF00D2FF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardElevated, card],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient waterGradient = LinearGradient(
    colors: [cyanBright, cyanPrimary, Color(0xFF22D3EE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [cyanBright, cyanPrimary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Radial Lighting Recipes (Oceanic teal atmospheric orbs matching logo)
  static RadialGradient get topCenterAmbientOrb => RadialGradient(
        center: Alignment.center,
        colors: [
          const Color(0xFF00D2FF).withValues(alpha: 0.12), // 12% alpha radiant aqua
          const Color(0xFF004D61).withValues(alpha: 0.05), // 5% alpha oceanic teal
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      );

  static RadialGradient get bottomLeftAmbientOrb => RadialGradient(
        center: Alignment.center,
        colors: [
          const Color(0xFF004D61).withValues(alpha: 0.08), // 8% deep oceanic teal shadow
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      );

  // Hero CTA Box Shadow
  static List<BoxShadow> get heroCtaShadow => [
        BoxShadow(
          color: const Color(0xFF00F2FE).withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 2),
        ),
      ];

  // Inverted White Pill Box Shadow (from Fortify Spec Section 3.C)
  static List<BoxShadow> get whitePillShadow => [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.20),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
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
  static const List<int> presetSizes = [100, 250, 500];
  static const int defaultSelectedSize = 250;
}
